import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/invoice_model.dart';
import '../models/maintenance_request_model.dart';
import '../models/room_member_model.dart';
import '../models/room_model.dart';
import '../services/database_helper.dart';
import '../services/supabase_service.dart';

/// ============================================================================
/// PROVIDER: Quản Lý Trạng Thái Và Nghiệp Vụ Cho Thuê Trọ (RentalProvider)
/// ============================================================================
/// Đây là trung tâm quản lý State và Business Logic chính của ứng dụng.
/// Phân chia 5 nhóm chức năng lớn:
/// 1. Tải & Thống kê Dữ liệu Tổng quan (Dashboard Analytics & Revenue Chart)
/// 2. Quản lý Phòng trọ (CRUD Room & Trạng thái Phòng)
/// 3. Quản lý Hóa đơn & Thu tiền (Invoices & Payment)
/// 4. Quản lý Cư dân & CCCD/CMND (Room Members & CCCD Registry)
/// 5. Quản lý Sự cố & Bảo trì Thiết bị (Maintenance Requests)
///
/// Dữ liệu: ghi SQLite trước (offline-first) rồi đồng bộ lên Supabase Cloud.
/// ============================================================================
class RentalProvider extends ChangeNotifier {
  List<Room> _rooms = [];
  List<Invoice> _invoices = [];
  List<MaintenanceRequest> _maintenanceRequests = [];
  final Map<String, List<RoomMember>> _roomMembersMap = {};
  bool _isLoading = true;
  bool _isSyncing = false;
  DateTime? _lastSyncedAt;
  int _localWriteVersion = 0;

  bool get isLoading => _isLoading;

  /// Đang đồng bộ với Supabase Cloud
  bool get isSyncing => _isSyncing;

  /// Thời điểm đồng bộ Cloud thành công gần nhất (null = chưa đồng bộ được)
  DateTime? get lastSyncedAt => _lastSyncedAt;

  /// Số thao tác chưa gửi được lên Cloud (do mất mạng...)
  int get pendingCloudOps => SupabaseService.pendingCount;

  /// Đã cấu hình & khởi tạo được Supabase
  bool get isCloudEnabled => SupabaseService.isInitialized;

  UnmodifiableListView<Room> get rooms => UnmodifiableListView(_rooms);
  UnmodifiableListView<Invoice> get invoices => UnmodifiableListView(_invoices);
  UnmodifiableListView<MaintenanceRequest> get maintenanceRequests =>
      UnmodifiableListView(_maintenanceRequests);

  RentalProvider() {
    loadData();
  }

  // ===========================================================================
  // 1. TẢI DỮ LIỆU, ĐỒNG BỘ CLOUD & BÁO CÁO THỐNG KÊ
  // ===========================================================================

  /// Tải dữ liệu từ SQLite (hiển thị ngay) rồi đồng bộ Supabase Cloud ở nền
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    await _loadFromLocal();
    _isLoading = false;
    notifyListeners();

    await syncWithCloud();
  }

  Future<void> _loadFromLocal() async {
    try {
      _rooms = await DatabaseHelper.getRooms();
      _invoices = await DatabaseHelper.getInvoices();
      _invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _maintenanceRequests = await DatabaseHelper.getMaintenanceRequests();
      _roomMembersMap.clear();
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu SQLite: $e');
    }
  }

  /// Đồng bộ 2 chiều với Supabase:
  /// 1. Gửi các thao tác còn tồn đọng (lúc offline) lên Cloud.
  /// 2. Lần đầu trên máy này: đẩy dữ liệu SQLite chưa có trên Cloud lên.
  /// 3. Tải dữ liệu Cloud về ghi đè SQLite (Cloud là bản chuẩn).
  /// Trả về true nếu đồng bộ thành công.
  Future<bool> syncWithCloud() async {
    if (!SupabaseService.isInitialized || _isSyncing) return false;
    _isSyncing = true;
    notifyListeners();

    try {
      final writeVersionAtStart = _localWriteVersion;
      if (!await SupabaseService.flushQueue()) return false;

      final cloud = await SupabaseService.fetchAll();
      if (cloud == null) return false;

      if (!SupabaseService.initialSyncDone) {
        for (final table in SupabaseService.syncedTables) {
          final cloudIds =
              cloud[table]!.map((r) => r['id'].toString()).toSet();
          for (final row in await DatabaseHelper.getAllRows(table)) {
            if (!cloudIds.contains(row['id'].toString())) {
              SupabaseService.upsert(table, row);
              cloud[table]!.add(row);
            }
          }
        }
        if (!await SupabaseService.flushQueue()) return false;
        await SupabaseService.markInitialSyncDone();
      }

      // Người dùng vừa sửa dữ liệu trong lúc đang tải → bản Cloud vừa tải đã
      // cũ, không ghi đè (thay đổi mới đã nằm trong hàng đợi gửi lên Cloud).
      if (_localWriteVersion != writeVersionAtStart) return false;

      await DatabaseHelper.replaceAllFromCloud(cloud);
      await _loadFromLocal();
      _lastSyncedAt = DateTime.now();
      return true;
    } catch (e) {
      debugPrint('Lỗi đồng bộ Supabase: $e');
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Tổng số lượng phòng trọ trong hệ thống
  int get totalRooms => _rooms.length;

  /// Số phòng đang cho thuê (Occupied)
  int get occupiedCount =>
      _rooms.where((room) => room.status == RoomStatus.occupied).length;

  /// Số phòng trống sẵn sàng cho thuê (Available)
  int get availableCount =>
      _rooms.where((room) => room.status == RoomStatus.available).length;

  /// Số phòng đang bảo trì (Maintenance)
  int get maintenanceCount =>
      _rooms.where((room) => room.status == RoomStatus.maintenance).length;

  static bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  /// Ngày ghi nhận doanh thu của hóa đơn đã thu = ngày xác nhận thu tiền
  /// (dữ liệu cũ thiếu paidAt thì lấy ngày lập hóa đơn).
  static DateTime _revenueDate(Invoice inv) => inv.paidAt ?? inv.createdAt;

  /// Doanh thu dự kiến tháng hiện tại:
  /// - Phòng đã lập hóa đơn trong tháng → lấy đúng tổng tiền hóa đơn
  ///   (gồm tiền phòng + điện + nước + dịch vụ).
  /// - Phòng đang thuê nhưng chưa chốt → tạm tính tiền phòng + phí dịch vụ
  ///   (chưa biết số điện nước).
  double expectedRevenueThisMonth(double serviceFee) {
    final now = DateTime.now();
    final billedThisMonth =
        _invoices.where((inv) => _isSameMonth(inv.createdAt, now)).toList();
    final billedRoomIds = billedThisMonth.map((inv) => inv.roomId).toSet();

    final billedTotal =
        billedThisMonth.fold(0.0, (sum, inv) => sum + inv.totalAmount);
    final unbilledEstimate = _rooms
        .where((room) =>
            room.status == RoomStatus.occupied &&
            !billedRoomIds.contains(room.id))
        .fold(0.0, (sum, room) => sum + room.basePrice + serviceFee);

    return billedTotal + unbilledEstimate;
  }

  /// Số tiền đã thực thu trong tháng hiện tại
  double get collectedThisMonth {
    final now = DateTime.now();
    return _invoices
        .where((inv) => inv.isPaid && _isSameMonth(_revenueDate(inv), now))
        .fold(0.0, (sum, inv) => sum + inv.totalAmount);
  }

  /// Tổng nợ chưa thu (Tổng tiền của các hóa đơn chưa thanh toán)
  double get totalUnpaidDebt => _invoices
      .where((inv) => inv.status == InvoiceStatus.pending)
      .fold(0.0, (sum, inv) => sum + inv.totalAmount);

  /// Số lượng hóa đơn chưa thanh toán
  int get unpaidInvoicesCount =>
      _invoices.where((inv) => inv.status == InvoiceStatus.pending).length;

  /// Tỷ lệ lấp đầy phòng (%)
  double get occupancyRate =>
      totalRooms == 0 ? 0.0 : (occupiedCount / totalRooms) * 100;

  /// Số lượng sự cố bảo trì đang chờ xử lý hoặc đang sửa
  int get pendingMaintenanceCount => _maintenanceRequests
      .where((req) =>
          req.status == MaintenanceStatus.pending ||
          req.status == MaintenanceStatus.inProgress)
      .length;

  /// Tổng chi phí sửa chữa bảo trì (bỏ qua sự cố đã hủy — không phát sinh chi)
  double get totalMaintenanceCost => _maintenanceRequests
      .where((req) => req.status != MaintenanceStatus.cancelled)
      .fold(0.0, (sum, req) => sum + req.repairCost);

  /// Các hóa đơn chưa thu của một phòng
  List<Invoice> unpaidInvoicesOfRoom(String roomId) => _invoices
      .where((inv) => inv.roomId == roomId && !inv.isPaid)
      .toList();

  /// Thống kê doanh thu THỰC THU 6 tháng gần nhất cho biểu đồ fl_chart.
  /// Key = ngày đầu tháng (để giao diện tự hiển thị nhãn theo ngôn ngữ).
  /// Tiền được tính vào tháng mà chủ trọ xác nhận đã thu (paidAt), vì hóa đơn
  /// lập tháng này có thể đến tháng sau khách mới trả.
  Map<DateTime, double> getMonthlyRevenueStats() {
    final now = DateTime.now();
    final Map<DateTime, double> stats = {};

    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      stats[monthDate] = _invoices
          .where((inv) =>
              inv.isPaid && _isSameMonth(_revenueDate(inv), monthDate))
          .fold(0.0, (sum, inv) => sum + inv.totalAmount);
    }

    return stats;
  }

  // ===========================================================================
  // 2. QUẢN LÝ PHÒNG TRỌ (ROOM MANAGEMENT)
  // ===========================================================================

  /// Chuẩn hóa tên phòng để so trùng: bỏ khoảng trắng, không phân biệt hoa
  /// thường ("P.101", "p.101", "P. 101" được coi là cùng một phòng).
  static String _normalizeRoomName(String name) =>
      name.toLowerCase().replaceAll(RegExp(r'\s+'), '');

  /// Tên phòng đã tồn tại chưa. [excludeRoomId] = phòng đang sửa (bỏ qua chính nó).
  bool isRoomNameTaken(String name, {String? excludeRoomId}) {
    final key = _normalizeRoomName(name);
    return _rooms.any((r) =>
        r.id != excludeRoomId && _normalizeRoomName(r.name) == key);
  }

  /// Thêm một phòng trọ mới vào danh sách & lưu SQLite.
  /// Ném [RoomNameTakenException] nếu tên phòng bị trùng.
  Future<void> addRoom(Room room) async {
    if (isRoomNameTaken(room.name)) {
      throw RoomNameTakenException(room.name);
    }
    _rooms.add(room);
    notifyListeners();
    await DatabaseHelper.insertRoom(room);
    _cloudUpsert('rooms', room.toMap());
  }

  /// Cập nhật thông tin phòng trọ (Giá thuê, Ảnh, Trạng thái, v.v.)
  Future<void> updateRoom(Room updatedRoom) async {
    final index = _rooms.indexWhere((r) => r.id == updatedRoom.id);
    // Chỉ kiểm tra khi đổi tên (dữ liệu cũ lỡ trùng vẫn sửa được thông tin khác)
    final renamed = index != -1 &&
        _normalizeRoomName(_rooms[index].name) !=
            _normalizeRoomName(updatedRoom.name);
    if (renamed &&
        isRoomNameTaken(updatedRoom.name, excludeRoomId: updatedRoom.id)) {
      throw RoomNameTakenException(updatedRoom.name);
    }
    if (index != -1) {
      _rooms[index] = updatedRoom;
      notifyListeners();
      await DatabaseHelper.updateRoom(updatedRoom);
      _cloudUpsert('rooms', updatedRoom.toMap());
    }
  }

  /// Xóa phòng trọ khỏi hệ thống, kèm thành viên & sự cố bảo trì của phòng.
  /// - Không cho xóa phòng đang có khách hoặc còn hóa đơn chưa thu
  ///   (ném [RoomDeleteException]).
  /// - GIỮ LẠI hóa đơn đã thu: đó là tiền đã nhận thật, xóa đi sẽ làm sai
  ///   lịch sử doanh thu của các tháng trước (hóa đơn có lưu sẵn tên phòng).
  Future<void> deleteRoom(String roomId) async {
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index == -1) return;
    if (_rooms[index].status == RoomStatus.occupied) {
      throw const RoomDeleteException(RoomDeleteError.occupied);
    }
    if (unpaidInvoicesOfRoom(roomId).isNotEmpty) {
      throw const RoomDeleteException(RoomDeleteError.hasUnpaidInvoices);
    }

    _rooms.removeAt(index);
    _maintenanceRequests.removeWhere((req) => req.roomId == roomId);
    _roomMembersMap.remove(roomId);
    notifyListeners();
    await DatabaseHelper.deleteRoom(roomId);
    for (final table in ['room_members', 'maintenance_requests']) {
      _cloudDelete(table, 'room_id', roomId);
    }
    _cloudDelete('rooms', 'id', roomId);
  }

  /// Đổi trạng thái phòng (Trống / Đã thuê / Bảo trì)
  /// Phòng không còn ai thuê → xóa luôn danh sách cư dân/CCCD của phòng.
  Future<void> updateRoomStatus(String roomId, RoomStatus status) async {
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      final releaseRoom = status != RoomStatus.occupied;
      _rooms[index] = _rooms[index].copyWith(
        status: status,
        clearTenant: releaseRoom,
        occupantCount: releaseRoom ? 1 : null,
      );
      if (releaseRoom) {
        _roomMembersMap.remove(roomId);
        await DatabaseHelper.deleteMembersForRoom(roomId);
        _cloudDelete('room_members', 'room_id', roomId);
      }
      notifyListeners();
      await DatabaseHelper.updateRoom(_rooms[index]);
      _cloudUpsert('rooms', _rooms[index].toMap());
    }
  }

  // ===========================================================================
  // 3. QUẢN LÝ HÓA ĐƠN & QUYẾT TOÁN (INVOICES & CHECKOUT)
  // ===========================================================================

  /// Khách HIỆN TẠI của phòng đã được lập hóa đơn trong tháng này chưa.
  /// Hóa đơn của khách cũ (lập trước ngày khách mới vào ở) không tính, để
  /// phòng trả rồi cho thuê lại trong cùng tháng vẫn lập được hóa đơn.
  bool hasInvoiceThisMonth(String roomId) {
    final now = DateTime.now();
    final room = _rooms.where((r) => r.id == roomId).firstOrNull;
    final checkIn = room?.checkInDate;
    final tenantStart = checkIn == null
        ? null
        : DateTime(checkIn.year, checkIn.month, checkIn.day);
    return _invoices.any((inv) =>
        inv.roomId == roomId &&
        _isSameMonth(inv.createdAt, now) &&
        (tenantStart == null || !inv.createdAt.isBefore(tenantStart)));
  }

  /// Tạo hóa đơn tính tiền mới & cập nhật chỉ số điện/nước mới cho phòng.
  /// Ném [InvoiceException] nếu dữ liệu không hợp lệ.
  Future<void> createInvoiceAndRecord(Invoice invoice) async {
    // Chặn chỉ số mới nhỏ hơn chỉ số cũ (tránh lượng dùng bị tính = 0 âm thầm)
    if (invoice.newElec < invoice.oldElec ||
        invoice.newWater < invoice.oldWater) {
      throw const InvoiceException(InvoiceError.invalidMeter);
    }
    // Mỗi phòng chỉ lập 1 hóa đơn / tháng (lập nhầm thì xóa hóa đơn rồi lập lại)
    if (hasInvoiceThisMonth(invoice.roomId)) {
      throw const InvoiceException(InvoiceError.alreadyBilledThisMonth);
    }
    _invoices.insert(0, invoice);

    final index = _rooms.indexWhere((r) => r.id == invoice.roomId);
    if (index != -1) {
      _rooms[index] = _rooms[index].copyWith(
        oldElectricity: invoice.newElec,
        oldWater: invoice.newWater,
      );
      await DatabaseHelper.updateRoom(_rooms[index]);
      _cloudUpsert('rooms', _rooms[index].toMap());
    }

    notifyListeners();
    await DatabaseHelper.insertInvoice(invoice);
    _cloudUpsert('invoices', invoice.toMap());
  }

  /// Xác nhận thu tiền cho hóa đơn (Chuyển sang Đã thanh toán)
  Future<void> markInvoiceAsPaid(String invoiceId) async {
    final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
    if (index != -1) {
      final now = DateTime.now();
      _invoices[index] = _invoices[index].copyWith(
        status: InvoiceStatus.paid,
        paidAt: now,
      );
      notifyListeners();
      await DatabaseHelper.updateInvoiceStatus(
          invoiceId, InvoiceStatus.paid, now);
      _cloudUpsert('invoices', _invoices[index].toMap());
    }
  }

  /// Xóa hóa đơn khỏi hệ thống.
  /// Nếu đó là hóa đơn mới nhất của phòng → trả chỉ số điện/nước của phòng về
  /// chỉ số cũ của hóa đơn, để lập lại hóa đơn không bị tính thiếu.
  Future<void> deleteInvoice(String invoiceId) async {
    final invIndex = _invoices.indexWhere((inv) => inv.id == invoiceId);
    if (invIndex == -1) return;
    final invoice = _invoices.removeAt(invIndex);

    final isLatestOfRoom = !_invoices.any((inv) =>
        inv.roomId == invoice.roomId &&
        inv.createdAt.isAfter(invoice.createdAt));
    final roomIndex = _rooms.indexWhere((r) => r.id == invoice.roomId);
    if (isLatestOfRoom && roomIndex != -1) {
      final room = _rooms[roomIndex];
      if (room.oldElectricity == invoice.newElec &&
          room.oldWater == invoice.newWater) {
        _rooms[roomIndex] = room.copyWith(
          oldElectricity: invoice.oldElec,
          oldWater: invoice.oldWater,
        );
        await DatabaseHelper.updateRoom(_rooms[roomIndex]);
        _cloudUpsert('rooms', _rooms[roomIndex].toMap());
      }
    }

    notifyListeners();
    await DatabaseHelper.deleteInvoice(invoiceId);
    _cloudDelete('invoices', 'id', invoiceId);
  }

  /// Trả phòng & Thanh lý hợp đồng (Khấu trừ cọc và đưa phòng về trạng thái Trống)
  Future<void> checkoutRoom(String roomId, int lastElec, int lastWater) async {
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      // Còn nợ hóa đơn thì phải xử lý trước, tránh trả cọc xong mới phát hiện
      if (unpaidInvoicesOfRoom(roomId).isNotEmpty) {
        throw StateError('unpaid_invoices');
      }
      if (lastElec < _rooms[index].oldElectricity ||
          lastWater < _rooms[index].oldWater) {
        throw ArgumentError('Chỉ số cuối không được nhỏ hơn chỉ số cũ');
      }
      _rooms[index] = _rooms[index].copyWith(
        status: RoomStatus.available,
        oldElectricity: lastElec,
        oldWater: lastWater,
        occupantCount: 1,
        depositAmount: 0.0,
        clearTenant: true,
      );
      _roomMembersMap.remove(roomId);
      await DatabaseHelper.deleteMembersForRoom(roomId);
      _cloudDelete('room_members', 'room_id', roomId);
      notifyListeners();
      await DatabaseHelper.updateRoom(_rooms[index]);
      _cloudUpsert('rooms', _rooms[index].toMap());
    }
  }

  // ===========================================================================
  // 4. QUẢN LÝ CƯ DÂN & ĐĂNG KÝ CCCD/CMND (ROOM MEMBERS REGISTRY)
  // ===========================================================================

  /// Tải danh sách thành viên đăng ký CCCD/CMND của phòng từ SQLite
  Future<List<RoomMember>> getRoomMembers(String roomId) async {
    final members = await DatabaseHelper.getRoomMembers(roomId);
    _roomMembersMap[roomId] = members;
    notifyListeners();
    return members;
  }

  /// Lấy danh sách thành viên bộ nhớ đệm
  List<RoomMember> getCachedRoomMembers(String roomId) {
    return _roomMembersMap[roomId] ?? [];
  }

  /// Thêm một thành viên CCCD mới vào phòng
  Future<void> addRoomMember(RoomMember member) async {
    await _clearOtherRepresentatives(member);
    await DatabaseHelper.insertRoomMember(member);
    _cloudUpsert('room_members', member.toMap());
    await _refreshRoomMembersAndSync(member.roomId);
  }

  /// Cập nhật thông tin CCCD của thành viên
  Future<void> updateRoomMember(RoomMember member) async {
    await _clearOtherRepresentatives(member);
    await DatabaseHelper.updateRoomMember(member);
    _cloudUpsert('room_members', member.toMap());
    await _refreshRoomMembersAndSync(member.roomId);
  }

  /// Mỗi phòng chỉ có 1 người đại diện hợp đồng: chọn người mới làm đại diện
  /// thì bỏ đánh dấu đại diện của những người còn lại.
  Future<void> _clearOtherRepresentatives(RoomMember member) async {
    if (!member.isRepresentative) return;
    final members = await DatabaseHelper.getRoomMembers(member.roomId);
    for (final m in members) {
      if (m.id != member.id && m.isRepresentative) {
        final demoted = m.copyWith(isRepresentative: false);
        await DatabaseHelper.updateRoomMember(demoted);
        _cloudUpsert('room_members', demoted.toMap());
      }
    }
  }

  /// Xóa thành viên khỏi phòng
  Future<void> deleteRoomMember(String memberId, String roomId) async {
    await DatabaseHelper.deleteRoomMember(memberId);
    _cloudDelete('room_members', 'id', memberId);
    await _refreshRoomMembersAndSync(roomId);
  }

  /// Tải lại danh sách thành viên & Tự động đồng bộ số người ở + tên đại diện phòng
  Future<void> _refreshRoomMembersAndSync(String roomId) async {
    final members = await DatabaseHelper.getRoomMembers(roomId);
    _roomMembersMap[roomId] = members;

    final index = _rooms.indexWhere((r) => r.id == roomId);
    // Phòng trống / bảo trì không có khách → không ghi tên khách lên phòng
    if (index != -1 && _rooms[index].status == RoomStatus.occupied) {
      final room = _rooms[index];
      final occupantCount =
          members.isNotEmpty ? members.length : room.occupantCount;

      RoomMember? repMember;
      if (members.isNotEmpty) {
        repMember = members.firstWhere(
          (m) => m.isRepresentative,
          orElse: () => members.first,
        );
      }

      final updatedTenantName = repMember?.name ?? room.tenantName;
      final updatedPhone = repMember?.phone ?? room.phone;

      _rooms[index] = room.copyWith(
        occupantCount: occupantCount,
        tenantName: updatedTenantName,
        phone: updatedPhone,
      );
      await DatabaseHelper.updateRoom(_rooms[index]);
      _cloudUpsert('rooms', _rooms[index].toMap());
    }

    notifyListeners();
  }

  // ===========================================================================
  // 5. QUẢN LÝ SỰ CỐ & BẢO TRÌ THIẾT BỊ (MAINTENANCE REQUESTS)
  // ===========================================================================

  /// Báo cáo sự cố bảo trì thiết bị mới
  Future<void> addMaintenanceRequest(MaintenanceRequest req) async {
    _maintenanceRequests.insert(0, req);
    notifyListeners();
    await DatabaseHelper.insertMaintenanceRequest(req);
    _cloudUpsert('maintenance_requests', req.toMap());
  }

  /// Cập nhật trạng thái xử lý & chi phí sửa chữa sự cố
  Future<void> updateMaintenanceStatus(
    String reqId,
    MaintenanceStatus status,
    double repairCost,
  ) async {
    final index = _maintenanceRequests.indexWhere((r) => r.id == reqId);
    if (index != -1) {
      final now = DateTime.now();
      _maintenanceRequests[index] = _maintenanceRequests[index].copyWith(
        status: status,
        repairCost: repairCost,
        completedAt: status == MaintenanceStatus.completed ? now : null,
        clearCompletedAt: status != MaintenanceStatus.completed,
      );
      notifyListeners();
      await DatabaseHelper.updateMaintenanceRequest(
          _maintenanceRequests[index]);
      _cloudUpsert(
          'maintenance_requests', _maintenanceRequests[index].toMap());
    }
  }

  /// Chỉnh sửa toàn bộ thông tin sự cố
  Future<void> updateMaintenanceRequest(MaintenanceRequest updatedReq) async {
    final index = _maintenanceRequests.indexWhere((r) => r.id == updatedReq.id);
    if (index != -1) {
      _maintenanceRequests[index] = updatedReq;
      notifyListeners();
      await DatabaseHelper.updateMaintenanceRequest(updatedReq);
      _cloudUpsert('maintenance_requests', updatedReq.toMap());
    }
  }

  /// Xóa thông báo sự cố bảo trì
  Future<void> deleteMaintenanceRequest(String reqId) async {
    _maintenanceRequests.removeWhere((r) => r.id == reqId);
    notifyListeners();
    await DatabaseHelper.deleteMaintenanceRequest(reqId);
    _cloudDelete('maintenance_requests', 'id', reqId);
  }

  // ===========================================================================
  // HỖ TRỢ ĐỒNG BỘ CLOUD
  // ===========================================================================

  /// Đẩy dữ liệu lên Cloud ở nền (không chặn giao diện). Lỗi mạng được
  /// SupabaseService đưa vào hàng đợi để gửi lại ở lần đồng bộ sau.
  void _cloudUpsert(String table, Map<String, dynamic> data) {
    _localWriteVersion++;
    SupabaseService.upsert(table, data).then((_) => notifyListeners());
  }

  void _cloudDelete(String table, String column, String value) {
    _localWriteVersion++;
    SupabaseService.delete(table, column, value).then((_) => notifyListeners());
  }
}

/// Lỗi khi xóa phòng
enum RoomDeleteError { occupied, hasUnpaidInvoices }

class RoomDeleteException implements Exception {
  final RoomDeleteError error;
  const RoomDeleteException(this.error);

  @override
  String toString() => 'RoomDeleteException($error)';
}

/// Lỗi trùng tên phòng khi thêm / sửa phòng
class RoomNameTakenException implements Exception {
  final String name;
  const RoomNameTakenException(this.name);

  @override
  String toString() => 'RoomNameTakenException($name)';
}

/// Các lỗi nghiệp vụ khi lập hóa đơn
enum InvoiceError { invalidMeter, alreadyBilledThisMonth }

class InvoiceException implements Exception {
  final InvoiceError error;
  const InvoiceException(this.error);

  @override
  String toString() => 'InvoiceException($error)';
}
