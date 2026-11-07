import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService;

  SettingsProvider(this._settingsService);

  double get elecPrice => _settingsService.elecPrice;
  double get waterPrice => _settingsService.waterPrice;
  double get serviceFee => _settingsService.serviceFee;

  String get bankCode => _settingsService.bankCode;
  String get accountNo => _settingsService.accountNo;
  String get accountHolder => _settingsService.accountHolder;

  String get languageCode => _settingsService.languageCode;
  Locale get locale => Locale(_settingsService.languageCode);

  bool get isDarkMode => _settingsService.isDarkMode;
  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    await setDarkMode(!isDarkMode);
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_settingsService.isDarkMode == isDark) return;
    await _settingsService.setDarkMode(isDark);
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    if (_settingsService.languageCode == languageCode) return;
    await _settingsService.setLanguageCode(languageCode);
    notifyListeners();
  }

  Future<void> updateSettings({
    required double elecPrice,
    required double waterPrice,
    required double serviceFee,
    required String bankCode,
    required String accountNo,
    required String accountHolder,
  }) async {
    await _settingsService.saveSettings(
      elecPrice: elecPrice,
      waterPrice: waterPrice,
      serviceFee: serviceFee,
      bankCode: bankCode,
      accountNo: accountNo,
      accountHolder: accountHolder,
    );
    notifyListeners();
  }
}
