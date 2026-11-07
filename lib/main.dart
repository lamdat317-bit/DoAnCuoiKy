import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/rental_provider.dart';
import 'providers/settings_provider.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';
import 'views/login_screen.dart';
import 'views/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsService = await SettingsService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RentalProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider(settingsService)),
      ],
      child: const RentalManagementApp(),
    ),
  );
}

class RentalManagementApp extends StatelessWidget {
  const RentalManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Quản lý Phòng trọ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoggedIn) {
            return const MainScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
