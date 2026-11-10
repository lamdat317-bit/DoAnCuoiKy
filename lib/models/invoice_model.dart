import 'parse_utils.dart';

enum InvoiceStatus {
  pending,
  paid;

  String get displayName {
    switch (this) {
      case InvoiceStatus.pending:
        return 'Chưa thanh toán';
      case InvoiceStatus.paid:
        return 'Đã thanh toán';
    }
  }
}

class Invoice {
  final String id;
  final String roomId;
  final String roomName;
  final String tenantName;
  final double roomPrice;
  final int oldElec;
  final int newElec;
  final double elecPrice;
  final int oldWater;
  final int newWater;
  final double waterPrice;
  final double serviceFee;
  final DateTime createdAt;
  final InvoiceStatus status;
  final DateTime? paidAt;

  Invoice({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.tenantName,
    required this.roomPrice,
    required this.oldElec,
    required this.newElec,
    required this.elecPrice,
    required this.oldWater,
    required this.newWater,
    required this.waterPrice,
    required this.serviceFee,
    required this.createdAt,
    this.status = InvoiceStatus.pending,
    this.paidAt,
  });

  bool get isPaid => status == InvoiceStatus.paid;

  int get elecUsage => newElec > oldElec ? newElec - oldElec : 0;
  double get elecTotal => elecUsage * elecPrice;

  int get waterUsage => newWater > oldWater ? newWater - oldWater : 0;
  double get waterTotal => waterUsage * waterPrice;

  double get totalAmount => roomPrice + elecTotal + waterTotal + serviceFee;

  Invoice copyWith({
    String? id,
    String? roomId,
    String? roomName,
    String? tenantName,
    double? roomPrice,
    int? oldElec,
    int? newElec,
    double? elecPrice,
    int? oldWater,
    int? newWater,
    double? waterPrice,
    double? serviceFee,
    DateTime? createdAt,
    InvoiceStatus? status,
    DateTime? paidAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      tenantName: tenantName ?? this.tenantName,
      roomPrice: roomPrice ?? this.roomPrice,
      oldElec: oldElec ?? this.oldElec,
      newElec: newElec ?? this.newElec,
      elecPrice: elecPrice ?? this.elecPrice,
      oldWater: oldWater ?? this.oldWater,
      newWater: newWater ?? this.newWater,
      waterPrice: waterPrice ?? this.waterPrice,
      serviceFee: serviceFee ?? this.serviceFee,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'room_name': roomName,
      'tenant_name': tenantName,
      'room_price': roomPrice,
      'old_elec': oldElec,
      'new_elec': newElec,
      'elec_price': elecPrice,
      'old_water': oldWater,
      'new_water': newWater,
      'water_price': waterPrice,
      'service_fee': serviceFee,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'paid_at': paidAt?.toIso8601String(),
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      roomId: map['room_id'],
      roomName: map['room_name'],
      tenantName: map['tenant_name'],
      roomPrice: parseDouble(map['room_price']),
      oldElec: parseInt(map['old_elec']),
      newElec: parseInt(map['new_elec']),
      elecPrice: parseDouble(map['elec_price']),
      oldWater: parseInt(map['old_water']),
      newWater: parseInt(map['new_water']),
      waterPrice: parseDouble(map['water_price']),
      serviceFee: parseDouble(map['service_fee']),
      createdAt: parseDate(map['created_at']) ?? DateTime.now(),
      status: map['status'] == 'paid' ? InvoiceStatus.paid : InvoiceStatus.pending,
      paidAt: parseDate(map['paid_at']),
    );
  }
}
