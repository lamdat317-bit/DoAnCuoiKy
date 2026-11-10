import 'parse_utils.dart';

enum RoomStatus {
  available,
  occupied,
  maintenance;

  String get displayName {
    switch (this) {
      case RoomStatus.available:
        return 'Trống';
      case RoomStatus.occupied:
        return 'Đã thuê';
      case RoomStatus.maintenance:
        return 'Bảo trì';
    }
  }
}

class Room {
  final String id;
  final String name;
  final double basePrice;
  final RoomStatus status;
  final String? tenantName;
  final String? phone;
  final DateTime? contractEnd;
  final int oldElectricity;
  final int oldWater;
  final String? imageUrl;
  final int occupantCount;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final double depositAmount;

  Room({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.status,
    this.tenantName,
    this.phone,
    this.contractEnd,
    required this.oldElectricity,
    required this.oldWater,
    this.imageUrl,
    this.occupantCount = 1,
    this.checkInDate,
    this.checkOutDate,
    this.depositAmount = 0.0,
  });

  Room copyWith({
    String? id,
    String? name,
    double? basePrice,
    RoomStatus? status,
    String? tenantName,
    String? phone,
    DateTime? contractEnd,
    int? oldElectricity,
    int? oldWater,
    String? imageUrl,
    int? occupantCount,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    double? depositAmount,
    bool clearTenant = false,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      basePrice: basePrice ?? this.basePrice,
      status: status ?? this.status,
      tenantName: clearTenant ? tenantName : (tenantName ?? this.tenantName),
      phone: clearTenant ? phone : (phone ?? this.phone),
      contractEnd: clearTenant ? contractEnd : (contractEnd ?? this.contractEnd),
      oldElectricity: oldElectricity ?? this.oldElectricity,
      oldWater: oldWater ?? this.oldWater,
      imageUrl: imageUrl ?? this.imageUrl,
      occupantCount: occupantCount ?? this.occupantCount,
      checkInDate: clearTenant ? checkInDate : (checkInDate ?? this.checkInDate),
      checkOutDate: clearTenant ? checkOutDate : (checkOutDate ?? this.checkOutDate),
      depositAmount: depositAmount ?? this.depositAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'base_price': basePrice,
      'status': status.name,
      'tenant_name': tenantName,
      'phone': phone,
      'contract_end': contractEnd?.toIso8601String(),
      'old_electricity': oldElectricity,
      'old_water': oldWater,
      'image_url': imageUrl,
      'occupant_count': occupantCount,
      'check_in_date': checkInDate?.toIso8601String(),
      'check_out_date': checkOutDate?.toIso8601String(),
      'deposit_amount': depositAmount,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'],
      name: map['name'],
      basePrice: parseDouble(map['base_price']),
      status: RoomStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => RoomStatus.available,
      ),
      tenantName: map['tenant_name'],
      phone: map['phone'],
      contractEnd: parseDate(map['contract_end']),
      oldElectricity: parseInt(map['old_electricity']),
      oldWater: parseInt(map['old_water']),
      imageUrl: map['image_url'],
      occupantCount: parseInt(map['occupant_count'], 1),
      checkInDate: parseDate(map['check_in_date']),
      checkOutDate: parseDate(map['check_out_date']),
      depositAmount: parseDouble(map['deposit_amount']),
    );
  }
}
