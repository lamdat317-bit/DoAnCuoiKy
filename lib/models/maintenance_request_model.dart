/// ============================================================================
/// ENUM: Trạng Thái Xử Lý Sự Cố Bảo Trì
/// ============================================================================
enum MaintenanceStatus {
  pending, // Chờ xử lý
  inProgress, // Đang sửa
  completed, // Đã xong
  cancelled; // Đã hủy

  String get displayName {
    switch (this) {
      case MaintenanceStatus.pending:
        return 'Chờ xử lý';
      case MaintenanceStatus.inProgress:
        return 'Đang sửa';
      case MaintenanceStatus.completed:
        return 'Đã xong';
      case MaintenanceStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

/// ============================================================================
/// MODEL: Yêu Cầu Bảo Trì & Sự Cố Thiết Bị (MaintenanceRequest)
/// ============================================================================
/// Quản lý dữ liệu thông tin sự cố hỏng hóc thiết bị trong phòng trọ.
/// ============================================================================
class MaintenanceRequest {
  final String id;
  final String roomId;
  final String roomName;
  final String title; // Tên sự cố (VD: Hỏng máy lạnh, Nghẹt nước)
  final String? description; // Mô tả chi tiết
  final double repairCost; // Chi phí sửa chữa (VNĐ)
  final MaintenanceStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  MaintenanceRequest({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.title,
    this.description,
    this.repairCost = 0.0,
    this.status = MaintenanceStatus.pending,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  MaintenanceRequest copyWith({
    String? id,
    String? roomId,
    String? roomName,
    String? title,
    String? description,
    double? repairCost,
    MaintenanceStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return MaintenanceRequest(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      title: title ?? this.title,
      description: description ?? this.description,
      repairCost: repairCost ?? this.repairCost,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'room_name': roomName,
      'title': title,
      'description': description,
      'repair_cost': repairCost,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory MaintenanceRequest.fromMap(Map<String, dynamic> map) {
    return MaintenanceRequest(
      id: map['id'],
      roomId: map['room_id'],
      roomName: map['room_name'],
      title: map['title'],
      description: map['description'],
      repairCost: (map['repair_cost'] as num).toDouble(),
      status: MaintenanceStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => MaintenanceStatus.pending,
      ),
      createdAt: DateTime.parse(map['created_at']),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
    );
  }
}
