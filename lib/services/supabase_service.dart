import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cloud_mapping.dart';

/// ============================================================================
/// SERVICE: Đồng Bộ Cơ Sở Dữ Liệu Đám Mây Supabase (SupabaseService)
/// ============================================================================
/// Mô hình "Offline-first":
/// - Ứng dụng luôn đọc/ghi SQLite trước (chạy được cả khi mất mạng).
/// - Mỗi thao tác ghi (thêm/sửa/xóa) được đẩy lên Supabase ngay sau đó.
/// - Nếu đẩy thất bại (mất mạng, lỗi server) → thao tác được lưu vào
///   HÀNG ĐỢI (SharedPreferences) và gửi lại ở lần đồng bộ tiếp theo.
/// - Khi mở app / kéo để làm mới: gửi hết hàng đợi → tải dữ liệu Cloud về
///   ghi đè SQLite (Cloud là nguồn dữ liệu chuẩn giữa các thiết bị).
/// ============================================================================
class SupabaseService {
  static const String supabaseUrl = 'https://lxhywbwcmwqpvqcjiisb.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_tWXp9K8hKE5k6HbQp4Kw0A_fKwNuf5V';

  /// Các bảng SQLite được đồng bộ (tên bảng tiếng Việt trên Cloud: xem cloud_mapping.dart)
  static const List<String> syncedTables = [
    'rooms',
    'invoices',
    'room_members',
    'maintenance_requests',
  ];

  static const String _queueKey = 'supabase_pending_ops';
  // v2: bảng tiếng Việt mới → đẩy lại dữ liệu máy này lên lần đầu
  static const String _initialSyncKey = 'supabase_initial_sync_done_v2';

  static bool _isInitialized = false;
  static SharedPreferences? _prefs;

  /// Lượt gửi hàng đợi đang chạy (nếu có)
  static Future<bool>? _flushing;

  static bool get isInitialized => _isInitialized;
  static SupabaseClient get client => Supabase.instance.client;

  /// Khởi tạo kết nối Supabase Cloud
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint('✅ Khởi tạo kết nối Supabase Cloud thành công!');
    } catch (e) {
      debugPrint('⚠️ Không thể khởi tạo Supabase (chạy Offline SQLite): $e');
    }
  }

  // ===========================================================================
  // GHI DỮ LIỆU LÊN CLOUD (có hàng đợi khi lỗi)
  // ===========================================================================

  /// Thêm mới / cập nhật một dòng trên Cloud
  static Future<void> upsert(String table, Map<String, dynamic> data) =>
      _enqueueAndFlush({'op': 'upsert', 'table': table, 'data': data});

  /// Xóa các dòng trên Cloud có `column = value`
  static Future<void> delete(String table, String column, String value) =>
      _enqueueAndFlush(
          {'op': 'delete', 'table': table, 'column': column, 'value': value});

  static Future<bool> _enqueueAndFlush(Map<String, dynamic> op) {
    final queue = _readQueue()..add(op);
    _saveQueue(queue);
    return flushQueue();
  }

  /// Gửi lần lượt các thao tác đang chờ. Trả về true nếu gửi hết.
  /// Chỉ một lượt gửi chạy tại một thời điểm (tránh gửi trùng / mất thao tác).
  static Future<bool> flushQueue() {
    final previous = _flushing ?? Future.value(true);
    final next = previous.then((_) => _flush(), onError: (_) => _flush());
    _flushing = next;
    return next;
  }

  static Future<bool> _flush() async {
    if (!_isInitialized) return false;
    var queue = _readQueue();
    while (queue.isNotEmpty) {
      final op = queue.first;
      try {
        final localTable = op['table'] as String;
        final table = client.from(cloudTables[localTable]!.name);
        if (op['op'] == 'upsert') {
          await table.upsert(toCloudRow(
              localTable, Map<String, dynamic>.from(op['data'] as Map)));
        } else {
          await table.delete().eq(
              cloudColumn(localTable, op['column'] as String),
              op['value'] as String);
        }
      } on PostgrestException catch (e) {
        if (!isPermanentError(e)) {
          debugPrint('⚠️ Chưa đồng bộ được lên Supabase (sẽ thử lại sau): $e');
          return false;
        }
        // Supabase từ chối hẳn (bảng chưa tạo, sai ràng buộc dữ liệu...):
        // gửi lại cũng lỗi y hệt → bỏ thao tác này, không chặn các thao tác sau.
        debugPrint('❌ Supabase từ chối, bỏ qua thao tác ${op['op']} '
            '${op['table']}: ${e.code} ${e.message}');
      } catch (e) {
        // Lỗi mạng / mất kết nối → giữ trong hàng đợi, thử lại sau
        debugPrint('⚠️ Chưa đồng bộ được lên Supabase (sẽ thử lại sau): $e');
        return false;
      }
      queue = _readQueue()..removeAt(0);
      _saveQueue(queue);
    }
    return true;
  }

  /// Lỗi do dữ liệu/cấu trúc bảng (gửi lại vẫn lỗi), khác lỗi mạng/server tạm thời.
  /// - PGRST2xx: không tìm thấy bảng/cột trên Supabase
  /// - 22xxx: sai kiểu dữ liệu, 23xxx: vi phạm ràng buộc (check, not null...)
  /// - 42xxx: sai cú pháp / thiếu cột / không có quyền
  @visibleForTesting
  static bool isPermanentError(PostgrestException e) {
    final code = e.code ?? '';
    return code.startsWith('PGRST2') ||
        code.startsWith('22') ||
        code.startsWith('23') ||
        code.startsWith('42');
  }

  static int get pendingCount => _readQueue().length;

  static List<Map<String, dynamic>> _readQueue() {
    final raw = _prefs?.getString(_queueKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static void _saveQueue(List<Map<String, dynamic>> queue) {
    _prefs?.setString(_queueKey, jsonEncode(queue));
  }

  // ===========================================================================
  // ĐỌC DỮ LIỆU TỪ CLOUD
  // ===========================================================================

  /// Tải toàn bộ dữ liệu của 4 bảng. Trả về null nếu không kết nối được
  /// (để phân biệt "Cloud trống" với "lỗi mạng").
  static Future<Map<String, List<Map<String, dynamic>>>?> fetchAll() async {
    if (!_isInitialized) return null;
    try {
      final result = <String, List<Map<String, dynamic>>>{};
      for (final table in syncedTables) {
        final rows = await client.from(cloudTables[table]!.name).select();
        result[table] = rows
            .map((r) => fromCloudRow(table, Map<String, dynamic>.from(r)))
            .toList();
      }
      return result;
    } catch (e) {
      debugPrint('⚠️ Không tải được dữ liệu Supabase: $e');
      return null;
    }
  }

  /// Tải dòng cài đặt dùng chung (bảng `cai_dat`).
  /// - `ok = false`: không kết nối được (hoặc chưa tạo bảng) → giữ cài đặt trên máy.
  /// - `ok = true, row = null`: Cloud chưa có cài đặt → máy này đẩy lên.
  static Future<({bool ok, Map<String, dynamic>? row})> fetchSettings(
      String id) async {
    if (!_isInitialized) return (ok: false, row: null);
    try {
      final t = cloudTables['settings']!;
      final row = await client
          .from(t.name)
          .select()
          .eq(t.columns['id']!, id)
          .maybeSingle();
      return (
        ok: true,
        row: row == null
            ? null
            : fromCloudRow('settings', Map<String, dynamic>.from(row)),
      );
    } catch (e) {
      debugPrint('⚠️ Không tải được cài đặt từ Supabase: $e');
      return (ok: false, row: null);
    }
  }

  /// Còn thao tác chưa gửi của bảng này trong hàng đợi không
  static bool hasPending(String table) =>
      _readQueue().any((op) => op['table'] == table);

  /// Lần đồng bộ đầu tiên trên thiết bị này đã hoàn tất chưa
  static bool get initialSyncDone => _prefs?.getBool(_initialSyncKey) ?? false;
  static Future<void> markInitialSyncDone() async =>
      _prefs?.setBool(_initialSyncKey, true);
}
