import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:do_an_cuoiky/main.dart';
import 'package:do_an_cuoiky/providers/auth_provider.dart';
import 'package:do_an_cuoiky/providers/rental_provider.dart';
import 'package:do_an_cuoiky/providers/settings_provider.dart';
import 'package:do_an_cuoiky/services/settings_service.dart';

void main() {
  testWidgets('App smoke test - Login screen renders initially', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settingsService = await SettingsService.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => RentalProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider(settingsService)),
        ],
        child: const RentalManagementApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('QUẢN LÝ PHÒNG TRỌ'), findsOneWidget);
    expect(find.text('ĐĂNG NHẬP'), findsOneWidget);
  });

  testWidgets('Multi-language test - Switch to English and Chinese', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settingsService = await SettingsService.init();
    final settingsProvider = SettingsProvider(settingsService);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => RentalProvider()),
          ChangeNotifierProvider.value(value: settingsProvider),
        ],
        child: const RentalManagementApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Default is Vietnamese
    expect(find.text('QUẢN LÝ PHÒNG TRỌ'), findsOneWidget);
    expect(find.text('ĐĂNG NHẬP'), findsOneWidget);

    // Switch to English
    await settingsProvider.setLocale('en');
    await tester.pumpAndSettle();

    expect(find.text('RENTAL ROOM MANAGEMENT'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);

    // Switch to Chinese (Tiếng Trung)
    await settingsProvider.setLocale('zh');
    await tester.pumpAndSettle();

    expect(find.text('房屋出租管理系统'), findsOneWidget);
    expect(find.text('登录'), findsAtLeastNWidgets(1));
  });

  testWidgets('Theme test - Toggle light and dark mode', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settingsService = await SettingsService.init();
    final settingsProvider = SettingsProvider(settingsService);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => RentalProvider()),
          ChangeNotifierProvider.value(value: settingsProvider),
        ],
        child: const RentalManagementApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(settingsProvider.isDarkMode, false);

    // Toggle dark mode
    await settingsProvider.toggleTheme();
    await tester.pumpAndSettle();

    expect(settingsProvider.isDarkMode, true);

    // Toggle back to light mode
    await settingsProvider.toggleTheme();
    await tester.pumpAndSettle();

    expect(settingsProvider.isDarkMode, false);
  });
}
