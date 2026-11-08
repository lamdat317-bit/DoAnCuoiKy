import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice_model.dart';
import '../models/room_model.dart';

/// ============================================================================
/// SERVICE: Kết Nối Cơ Sở Dữ Liệu Đám Mây Supabase (SupabaseService)
/// ============================================================================
/// Supabase là nền tảng Cloud Database (PostgreSQL) hiện đại, thay thế Firebase
/// với ưu điểm không cần file cấu hình rườm rà.
/// Tự động đồng bộ 2 chiều (Cloud <-> SQLite Local) khi có kết nối mạng.
/// ============================================================================
class SupabaseService {
  // URL và AnonKey mẫu cho Supabase Project (Có thể thay thế bằng của bạn)
  static const String supabaseUrl = 'https://xyzcompany.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5emNvbXBhbnkiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTY3MDAwMDAwMCwiZXhwIjoyMDAwMDAwMDAwfQ.demo_key_supabase';

  static bool _isInitialized = false;

  /// Khởi tạo kết nối Supabase Cloud
  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint('✅ Khởi tạo kết nối Supabase Cloud thành công!');
    } catch (e) {
      debugPrint('⚠️ Không thể kết nối Supabase (Đang chạy chế độ Offline SQLite): $e');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
  static bool get isInitialized => _isInitialized;

  // --- CLOUD SYNC: ROOMS ---
  static Future<List<Room>> fetchCloudRooms() async {
    if (!_isInitialized) return [];
    try {
      final response = await client.from('rooms').select();
      return (response as List).map((map) => Room.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu phòng từ Supabase: $e');
      return [];
    }
  }

  static Future<void> syncRoomToCloud(Room room) async {
    if (!_isInitialized) return;
    try {
      await client.from('rooms').upsert(room.toMap());
    } catch (e) {
      debugPrint('Lỗi đồng bộ phòng lên Supabase: $e');
    }
  }

  static Future<void> deleteCloudRoom(String roomId) async {
    if (!_isInitialized) return;
    try {
      await client.from('rooms').delete().eq('id', roomId);
    } catch (e) {
      debugPrint('Lỗi xóa phòng trên Supabase: $e');
    }
  }

  // --- CLOUD SYNC: INVOICES ---
  static Future<List<Invoice>> fetchCloudInvoices() async {
    if (!_isInitialized) return [];
    try {
      final response =
          await client.from('invoices').select().order('created_at', ascending: false);
      return (response as List).map((map) => Invoice.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Lỗi tải hóa đơn từ Supabase: $e');
      return [];
    }
  }

  static Future<void> syncInvoiceToCloud(Invoice invoice) async {
    if (!_isInitialized) return;
    try {
      await client.from('invoices').upsert(invoice.toMap());
    } catch (e) {
      debugPrint('Lỗi đồng bộ hóa đơn lên Supabase: $e');
    }
  }
}
