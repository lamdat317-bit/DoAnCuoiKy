import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyElecPrice = 'elec_price';
  static const String _keyWaterPrice = 'water_price';
  static const String _keyServiceFee = 'service_fee';
  static const String _keyBankCode = 'bank_code';
  static const String _keyAccountNo = 'account_no';
  static const String _keyAccountHolder = 'account_holder';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyIsDarkMode = 'is_dark_mode';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static Future<SettingsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  double get elecPrice => _prefs.getDouble(_keyElecPrice) ?? 3500.0;
  double get waterPrice => _prefs.getDouble(_keyWaterPrice) ?? 20000.0;
  double get serviceFee => _prefs.getDouble(_keyServiceFee) ?? 150000.0;

  String get bankCode => _prefs.getString(_keyBankCode) ?? 'MB';
  String get accountNo => _prefs.getString(_keyAccountNo) ?? '0901234567';
  String get accountHolder =>
      _prefs.getString(_keyAccountHolder) ?? 'CHUYEN KHOAN TRO';
  String get languageCode => _prefs.getString(_keyLanguageCode) ?? 'vi';
  bool get isDarkMode => _prefs.getBool(_keyIsDarkMode) ?? false;

  Future<void> setLanguageCode(String code) async {
    await _prefs.setString(_keyLanguageCode, code);
  }

  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(_keyIsDarkMode, isDark);
  }

  Future<void> saveSettings({
    required double elecPrice,
    required double waterPrice,
    required double serviceFee,
    required String bankCode,
    required String accountNo,
    required String accountHolder,
  }) async {
    await _prefs.setDouble(_keyElecPrice, elecPrice);
    await _prefs.setDouble(_keyWaterPrice, waterPrice);
    await _prefs.setDouble(_keyServiceFee, serviceFee);
    await _prefs.setString(_keyBankCode, bankCode.trim().toUpperCase());
    await _prefs.setString(_keyAccountNo, accountNo.trim());
    await _prefs.setString(_keyAccountHolder, accountHolder.trim().toUpperCase());
  }
}
