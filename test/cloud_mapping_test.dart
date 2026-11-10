import 'package:flutter_test/flutter_test.dart';
import 'package:do_an_cuoiky/models/room_model.dart';
import 'package:do_an_cuoiky/models/room_member_model.dart';
import 'package:do_an_cuoiky/services/cloud_mapping.dart';

void main() {
  test('Phòng: đổi sang tên cột & trạng thái tiếng Việt rồi đổi ngược lại', () {
    final room = Room(
      id: 'room_101',
      name: 'P.101',
      basePrice: 3500000,
      status: RoomStatus.occupied,
      tenantName: 'Nguyễn Văn An',
      oldElectricity: 1420,
      oldWater: 85,
    );

    final cloud = toCloudRow('rooms', room.toMap());
    expect(cloud['ma_phong'], 'room_101');
    expect(cloud['ten_phong'], 'P.101');
    expect(cloud['trang_thai'], 'Đã thuê');
    expect(cloud['gia_thue'], 3500000); // số nguyên, không còn ".0"
    expect(cloud.containsKey('status'), false);

    final back = Room.fromMap(fromCloudRow('rooms', {...cloud, 'cot_la': 1}));
    expect(back.status, RoomStatus.occupied);
    expect(back.basePrice, 3500000);
    expect(back.tenantName, 'Nguyễn Văn An');
  });

  test('Cư dân: người đại diện lưu dạng đúng/sai trên Supabase', () {
    final m = RoomMember(
      id: 'm1',
      roomId: 'room_101',
      name: 'An',
      idCard: '034099001234',
      isRepresentative: true,
    );
    final cloud = toCloudRow('room_members', m.toMap());
    expect(cloud['la_dai_dien'], true);
    expect(cloud['so_cccd'], '034099001234');

    final local = fromCloudRow('room_members', cloud);
    expect(local['is_representative'], 1);
    expect(RoomMember.fromMap(local).isRepresentative, true);
  });

  test('Hóa đơn & sự cố: trạng thái tiếng Việt', () {
    expect(toCloudRow('invoices', {'status': 'paid'})['trang_thai'],
        'Đã thanh toán');
    expect(fromCloudRow('maintenance_requests', {'trang_thai': 'Đang sửa'})['status'],
        'inProgress');
  });

  test('Cài đặt: đổi tên cột tiếng Việt 2 chiều cho bảng cai_dat', () {
    final local = {
      'id': 'mac_dinh',
      'elec_price': 3800.0,
      'water_price': 25000.0,
      'service_fee': 150000.0,
      'bank_code': 'VCB',
      'account_no': '0123456789',
      'account_holder': 'NGUYEN VAN QUYEN',
    };
    final cloud = toCloudRow('settings', local);
    expect(cloud['ma_cai_dat'], 'mac_dinh');
    expect(cloud['gia_dien'], 3800);
    expect(cloud['ma_ngan_hang'], 'VCB');
    expect(fromCloudRow('settings', cloud)['water_price'], 25000);
    expect(fromCloudRow('settings', cloud)['account_holder'], 'NGUYEN VAN QUYEN');
  });
}

