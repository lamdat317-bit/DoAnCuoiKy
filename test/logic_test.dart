import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:do_an_cuoiky/models/invoice_model.dart';
import 'package:do_an_cuoiky/models/parse_utils.dart';
import 'package:do_an_cuoiky/providers/auth_provider.dart';

void main() {
  group('AuthProvider', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('Email chưa đăng ký không đăng nhập được', () async {
      final auth = AuthProvider(await SharedPreferences.getInstance());
      final err = await auth.login('nguoila@gmail.com', '123456');
      expect(err, isNotNull);
      expect(auth.isLoggedIn, false);
    });

    test('Tài khoản đăng ký được lưu lại & giữ phiên sau khi mở lại app',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final auth = AuthProvider(prefs);
      expect(await auth.register('Lan', 'lan@gmail.com', 'matkhau1'), isNull);

      // Giả lập mở lại app
      final reopened = AuthProvider(prefs);
      expect(reopened.isLoggedIn, true);
      expect(reopened.userName, 'Lan');

      await reopened.logout();
      expect(await AuthProvider(prefs).login('lan@gmail.com', 'sai'),
          'err_wrong_password');
      expect(await AuthProvider(prefs).login('lan@gmail.com', 'matkhau1'),
          isNull);
    });

    test('Đổi mật khẩu được lưu lại', () async {
      final prefs = await SharedPreferences.getInstance();
      final auth = AuthProvider(prefs);
      await auth.login('admin@gmail.com', '123456');
      expect(await auth.changePassword('123456', 'moi12345'), isNull);
      await auth.logout();

      final again = AuthProvider(prefs);
      expect(await again.login('admin@gmail.com', '123456'), isNotNull);
      expect(await again.login('admin@gmail.com', 'moi12345'), isNull);
    });
  });

  group('Đọc dữ liệu từ Supabase', () {
    test('parseDate giữ nguyên giờ đã lưu dù có múi giờ', () {
      final d = parseDate('2026-11-10T09:30:00+00:00')!;
      expect([d.year, d.month, d.day, d.hour, d.minute], [2026, 11, 10, 9, 30]);
      expect(d.isUtc, false);
    });

    test('Invoice.fromMap chấp nhận số dạng double / chuỗi', () {
      final inv = Invoice.fromMap({
        'id': 'inv_1',
        'room_id': 'room_101',
        'room_name': 'P.101',
        'tenant_name': 'An',
        'room_price': 3500000,
        'old_elec': 100.0,
        'new_elec': '150',
        'elec_price': 3500,
        'old_water': 10,
        'new_water': 12,
        'water_price': 20000,
        'service_fee': 150000,
        'created_at': '2026-11-10T09:30:00',
        'status': 'pending',
        'paid_at': null,
      });
      expect(inv.elecUsage, 50);
      expect(inv.totalAmount, 3500000 + 50 * 3500 + 2 * 20000 + 150000);
    });
  });
}
