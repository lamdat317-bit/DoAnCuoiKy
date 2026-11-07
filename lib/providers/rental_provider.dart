import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/invoice_model.dart';
import '../models/maintenance_request_model.dart';
import '../models/room_member_model.dart';
import '../models/room_model.dart';
import '../services/database_helper.dart';

/// ============================================================================
/// PROVIDER: Quản Lý Trạng Thái Và Nghiệp Vụ Cho Thuê Trọ (RentalProvider)
/// ============================================================================
/// Đây là trung tâm quản lý State và Business Logic chính của ứng dụng.
/// Phân chia 5 nhóm chức năng lớn:
/// 1. Tải & Thống kê Dữ liệu Tổng quan (Dashboard Analytics)
/// 2. Quản lý Phòng trọ (CRUD Room & Trạng thái Phòng)
/// 3. Quản lý Hóa đơn & Gạch nợ (Invoices & Debt Payment)
/// 4. Quản lý Cư dân & CCCD/CMND (Room Members & CCCD Registry)
/// 5. Quản lý Sự cố & Bảo trì Thiết bị (Maintenance Requests)
/// ============================================================================
class RentalProvider extends ChangeNotifier {
  List<Room> _rooms = [];
  List<Invoice> _invoices = [];
  List<MaintenanceRequest> _maintenanceRequests = [];
  final Map<String, List<RoomMember>> _roomMembersMap = {};
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  UnmodifiableListView<Room> get rooms => UnmodifiableListView(_rooms);
  UnmodifiableListView<Invoice> get invoices => UnmodifiableListView(_invoices);
  UnmodifiableListView<MaintenanceRequest> get maintenanceRequests =>
      UnmodifiableListView(_maintenanceRequests);

  RentalProvider() {
    loadData();
  }

  // ===========================================================================
  // 1. TẢI DỮ LIỆU & BÁO CÁO THỐNG KÊ (DASHBOARD ANALYTICS)
  // ===========================================================================

  /// Tải toàn bộ dữ liệu phòng trọ, hóa đơn & sự cố bảo trì từ SQLite
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _rooms = await DatabaseHelper.getRooms();
      _invoices = await DatabaseHelper.getInvoices();
      _maintenanceRequests = await DatabaseHelper.getMaintenanceRequests();
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu SQLite: $e');
    } finally {
      _isLoading = false;
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

  /// Doanh thu dự kiến tháng (Tổng tiền thuê của các phòng đang cho thuê)
  double get totalExpectedRevenue => _rooms
      .where((room) => room.status == RoomStatus.occupied)
      .fold(0.0, (sum, room) => sum + room.basePrice);

  /// Tổng công nợ chưa thu (Tổng tiền của các hóa đơn chưa thanh toán)
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

  /// Tổng chi phí sửa chữa bảo trì
  double get totalMaintenanceCost => _maintenanceRequests.fold(
      0.0, (sum, req) => sum + req.repairCost);

  // ===========================================================================
  // 2. QUẢN LÝ PHÒNG TRỌ (ROOM MANAGEMENT)
  // ===========================================================================

  /// Thêm một phòng trọ mới vào danh sách & lưu SQLite
  Future<void> addRoom(Room room) async {
    _rooms.add(room);
    notifyListeners();
    await DatabaseHelper.insertRoom(room);
  }

  /// Cập nhật thông tin phòng trọ (Giá thuê, Ảnh, Trạng thái, v.v.)
  Future<void> updateRoom(Room updatedRoom) async {
    final index = _rooms.indexWhere((r) => r.id == updatedRoom.id);
    if (index != -1) {
      _rooms[index] = updatedRoom;
      notifyListeners();
      await DatabaseHelper.updateRoom(updatedRoom);
    }
  }

  /// Xóa phòng trọ khỏi hệ thống
  Future<void> deleteRoom(String roomId) async {
    _rooms.removeWhere((r) => r.id == roomId);
    _roomMembersMap.remove(roomId);
    notifyListeners();
    await DatabaseHelper.deleteRoom(roomId);
  }

  /// Đổi trạng thái phòng (Trống / Đã thuê / Bảo trì)
  Future<void> updateRoomStatus(String roomId, RoomStatus status) async {
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      _rooms[index] = _rooms[index].copyWith(
        status: status,
        tenantName: status == RoomStatus.occupied ? _rooms[index].tenantName : null,
        phone: status == RoomStatus.occupied ? _rooms[index].phone : null,
      );
      notifyListeners();
      await DatabaseHelper.updateRoom(_rooms[index]);
    }
  }

  // ===========================================================================
  // 3. QUẢN LÝ HÓA ĐƠN & QUYẾT TOÁN (INVOICES & CHECKOUT)
  // ===========================================================================

  /// Tạo hóa đơn tính tiền mới & cập nhật chỉ số điện/nước mới cho phòng
  Future<void> createInvoiceAndRecord(Invoice invoice) async {
    _invoices.insert(0, invoice);

    final index = _rooms.indexWhere((r) => r.id == invoice.roomId);
    if (index != -1) {
      _rooms[index] = _rooms[index].copyWith(
        oldElectricity: invoice.newElec,
        oldWater: invoice.newWater,
      );
      await DatabaseHelper.updateRoom(_rooms[index]);
    }

    notifyListeners();
    await DatabaseHelper.insertInvoice(invoice);
  }

  /// Xác nhận thu tiền / Gạch nợ cho hóa đơn (Chuyển sang Đã thanh toán)
  Future<void> markInvoiceAsPaid(String invoiceId) async {
    final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
    if (index != -1) {
      final now = DateTime.now();
      _invoices[index] = _invoices[index].copyWith(
        status: InvoiceStatus.paid,
        paidAt: now,
      );
      notifyListeners();
      await DatabaseHelper.updateInvoiceStatus(invoiceId, InvoiceStatus.paid, now);
    }
  }

  /// Trả phòng & Thanh lý hợp đồng (Khấu trừ cọc và đưa phòng về trạng thái Trống)
  Future<void> checkoutRoom(String roomId, int lastElec, int lastWater) async {
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      _rooms[index] = _rooms[index].copyWith(
        status: RoomStatus.available,
        tenantName: null,
        phone: null,
        oldElectricity: lastElec,
        oldWater: lastWater,
        occupantCount: 1,
        checkInDate: null,
        checkOutDate: null,
        depositAmount: 0.0,
      );
      _roomMembersMap.remove(roomId);
      await DatabaseHelper.deleteMembersForRoom(roomId);
      notifyListeners();
      await DatabaseHelper.updateRoom(_rooms[index]);
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
    await DatabaseHelper.insertRoomMember(member);
    await _refreshRoomMembersAndSync(member.roomId);
  }

  /// Cập nhật thông tin CCCD của thành viên
  Future<void> updateRoomMember(RoomMember member) async {
    await DatabaseHelper.updateRoomMember(member);
    await _refreshRoomMembersAndSync(member.roomId);
  }

  /// Xóa thành viên khỏi phòng
  Future<void> deleteRoomMember(String memberId, String roomId) async {
    await DatabaseHelper.deleteRoomMember(memberId);
    await _refreshRoomMembersAndSync(roomId);
  }

  /// Tải lại danh sách thành viên & Tự động đồng bộ số người ở + tên đại diện phòng
  Future<void> _refreshRoomMembersAndSync(String roomId) async {
    final members = await DatabaseHelper.getRoomMembers(roomId);
    _roomMembersMap[roomId] = members;

    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      final room = _rooms[index];
      final occupantCount = members.isNotEmpty ? members.length : room.occupantCount;

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
      );
      notifyListeners();
      await DatabaseHelper.updateMaintenanceRequest(_maintenanceRequests[index]);
    }
  }

  /// Chỉnh sửa toàn bộ thông tin sự cố
  Future<void> updateMaintenanceRequest(MaintenanceRequest updatedReq) async {
    final index = _maintenanceRequests.indexWhere((r) => r.id == updatedReq.id);
    if (index != -1) {
      _maintenanceRequests[index] = updatedReq;
      notifyListeners();
      await DatabaseHelper.updateMaintenanceRequest(updatedReq);
    }
  }

  /// Xóa thông báo sự cố bảo trì
  Future<void> deleteMaintenanceRequest(String reqId) async {
    _maintenanceRequests.removeWhere((r) => r.id == reqId);
    notifyListeners();
    await DatabaseHelper.deleteMaintenanceRequest(reqId);
  }
}
