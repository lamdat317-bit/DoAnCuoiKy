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

  /// Dùng chung SharedPreferences cho các provider khác (vd: AuthProvider)
  SharedPreferences get prefs => _prefs;

  static Future<SettingsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  double get elecPrice => _prefs.getDouble(_keyElecPrice) ?? 3500.0;
  double get waterPrice => _prefs.getDouble(_keyWaterPrice) ?? 20000.0;
  double get serviceFee => _prefs.getDouble(_keyServiceFee) ?? 150000.0;

  String get bankCode => _prefs.getString(_keyBankCode) ?? 'TCB';
  String get accountNo => _prefs.getString(_keyAccountNo) ?? '19037202589016';
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

  /// Mã dòng cài đặt dùng chung trên Supabase (bảng `cai_dat`)
  static const String cloudId = 'mac_dinh';

  /// Cài đặt dùng chung (giá điện nước, ngân hàng) dạng dòng dữ liệu để
  /// gửi lên Supabase. Ngôn ngữ & giao diện tối là riêng từng máy → không gửi.
  Map<String, dynamic> toSyncRow() => {
        'id': cloudId,
        'elec_price': elecPrice,
        'water_price': waterPrice,
        'service_fee': serviceFee,
        'bank_code': bankCode,
        'account_no': accountNo,
        'account_holder': accountHolder,
        'updated_at': DateTime.now().toIso8601String(),
      };

  /// Ghi cài đặt tải từ Supabase vào máy. Trả về true nếu có thay đổi.
  Future<bool> applySyncRow(Map<String, dynamic> row) async {
    double? num_(Object? v) => v is num ? v.toDouble() : double.tryParse('$v');
    String? str(Object? v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    final elec = num_(row['elec_price']) ?? elecPrice;
    final water = num_(row['water_price']) ?? waterPrice;
    final service = num_(row['service_fee']) ?? serviceFee;
    final bank = str(row['bank_code']) ?? bankCode;
    final account = str(row['account_no']) ?? accountNo;
    final holder = str(row['account_holder']) ?? accountHolder;

    final changed = elec != elecPrice ||
        water != waterPrice ||
        service != serviceFee ||
        bank.toUpperCase() != bankCode ||
        account != accountNo ||
        holder.toUpperCase() != accountHolder;
    if (!changed) return false;

    await saveSettings(
      elecPrice: elec,
      waterPrice: water,
      serviceFee: service,
      bankCode: bank,
      accountNo: account,
      accountHolder: holder,
    );
    return true;
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
