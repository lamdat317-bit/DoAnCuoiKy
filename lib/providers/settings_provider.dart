import 'dart:async';

import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/supabase_service.dart';

/// Cài đặt của app.
/// - Giá điện, giá nước, phí dịch vụ, thông tin ngân hàng: DÙNG CHUNG mọi máy,
///   đồng bộ với bảng `cai_dat` trên Supabase.
/// - Ngôn ngữ, giao diện tối: riêng từng máy, chỉ lưu trên máy.
class SettingsProvider extends ChangeNotifier {
  static const String _cloudTable = 'settings';

  final SettingsService _settingsService;

  /// Tăng mỗi lần người dùng lưu cài đặt — để không ghi đè bằng bản Cloud cũ
  int _localWriteVersion = 0;
  bool _isSyncing = false;

  SettingsProvider(this._settingsService) {
    syncWithCloud();
  }

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
    _localWriteVersion++;
    await _settingsService.saveSettings(
      elecPrice: elecPrice,
      waterPrice: waterPrice,
      serviceFee: serviceFee,
      bankCode: bankCode,
      accountNo: accountNo,
      accountHolder: accountHolder,
    );
    notifyListeners();

    // Đẩy lên Cloud ở nền (lỗi mạng → nằm trong hàng đợi, gửi lại sau)
    unawaited(
        SupabaseService.upsert(_cloudTable, _settingsService.toSyncRow()));
  }

  /// Đồng bộ cài đặt dùng chung với Supabase:
  /// 1. Gửi thay đổi còn tồn đọng lên trước.
  /// 2. Cloud đã có cài đặt → áp dụng vào máy này.
  ///    Cloud chưa có → đẩy cài đặt của máy này lên.
  Future<bool> syncWithCloud() async {
    if (!SupabaseService.isInitialized || _isSyncing) return false;
    _isSyncing = true;
    try {
      final writeVersionAtStart = _localWriteVersion;
      if (!await SupabaseService.flushQueue()) return false;

      final result =
          await SupabaseService.fetchSettings(SettingsService.cloudId);
      if (!result.ok) return false;

      // Người dùng vừa lưu cài đặt trong lúc đang tải → giữ bản trên máy
      if (_localWriteVersion != writeVersionAtStart ||
          SupabaseService.hasPending(_cloudTable)) {
        return false;
      }

      final row = result.row;
      if (row == null) {
        await SupabaseService.upsert(
            _cloudTable, _settingsService.toSyncRow());
        return true;
      }
      if (await _settingsService.applySyncRow(row)) notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi đồng bộ cài đặt Supabase: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }
}
