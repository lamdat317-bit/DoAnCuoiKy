import 'parse_utils.dart';

/// ============================================================================
/// MODEL: Thành Viên & Số CCCD/CMND Của Phòng Trọ (RoomMember)
/// ============================================================================
class RoomMember {
  final String id;
  final String roomId;
  final String name;
  final String idCard; // Số CCCD / CMND
  final String? phone;
  final DateTime? dateOfBirth;
  final String? hometown; // Quê quán / Thường trú
  final bool isRepresentative; // Là người đại diện hợp đồng
  final DateTime createdAt;

  RoomMember({
    required this.id,
    required this.roomId,
    required this.name,
    required this.idCard,
    this.phone,
    this.dateOfBirth,
    this.hometown,
    this.isRepresentative = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  RoomMember copyWith({
    String? id,
    String? roomId,
    String? name,
    String? idCard,
    String? phone,
    DateTime? dateOfBirth,
    String? hometown,
    bool? isRepresentative,
    DateTime? createdAt,
  }) {
    return RoomMember(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      idCard: idCard ?? this.idCard,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      hometown: hometown ?? this.hometown,
      isRepresentative: isRepresentative ?? this.isRepresentative,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'name': name,
      'id_card': idCard,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'hometown': hometown,
      'is_representative': isRepresentative ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RoomMember.fromMap(Map<String, dynamic> map) {
    return RoomMember(
      id: map['id'],
      roomId: map['room_id'],
      name: map['name'],
      idCard: map['id_card'],
      phone: map['phone'],
      dateOfBirth: parseDate(map['date_of_birth']),
      hometown: map['hometown'],
      isRepresentative: parseBool(map['is_representative']),
      createdAt: parseDate(map['created_at']),
    );
  }
}
