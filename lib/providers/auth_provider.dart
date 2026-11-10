import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================================
/// PROVIDER: Xác Thực Tài Khoản Chủ Trọ (AuthProvider)
/// ============================================================================
/// - Tài khoản (email, mật khẩu, họ tên) lưu bằng SharedPreferences nên
///   không bị mất khi tắt app.
/// - Chỉ tài khoản ĐÃ ĐĂNG KÝ mới đăng nhập được.
/// - Ghi nhớ phiên đăng nhập: mở lại app không cần đăng nhập lại.
/// ============================================================================
class AuthProvider extends ChangeNotifier {
  static const String _keyUsers = 'auth_users';
  static const String _keySession = 'auth_session_email';

  final SharedPreferences _prefs;

  bool _isLoggedIn = false;
  String? _userEmail;
  String _userName = 'Chủ trọ Admin';
  final String _userRole = 'Chủ trọ';

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String get userName => _userName;
  String get userRole => _userRole;

  /// Tài khoản demo có sẵn
  static const Map<String, Map<String, String>> _defaultUsers = {
    'admin@gmail.com': {'password': '123456', 'name': 'Chủ trọ Admin'},
    'chutro@gmail.com': {'password': '123456', 'name': 'Nguyễn Văn Quyền'},
  };

  /// email → {password, name}
  late final Map<String, Map<String, String>> _users;

  AuthProvider(this._prefs) {
    _users = _loadUsers();

    // Khôi phục phiên đăng nhập trước đó
    final sessionEmail = _prefs.getString(_keySession);
    if (sessionEmail != null && _users.containsKey(sessionEmail)) {
      _isLoggedIn = true;
      _userEmail = sessionEmail;
      _userName = _users[sessionEmail]!['name'] ?? _userName;
    }
  }

  Map<String, Map<String, String>> _loadUsers() {
    final users = <String, Map<String, String>>{
      for (final e in _defaultUsers.entries) e.key: Map.of(e.value),
    };
    final raw = _prefs.getString(_keyUsers);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        decoded.forEach((email, info) {
          users[email] = Map<String, String>.from(info as Map);
        });
      } catch (e) {
        debugPrint('Lỗi đọc danh sách tài khoản: $e');
      }
    }
    return users;
  }

  Future<void> _saveUsers() => _prefs.setString(_keyUsers, jsonEncode(_users));

  /// Đăng nhập. Trả về null nếu thành công, hoặc thông báo lỗi.
  Future<String?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty) {
      return 'Vui lòng nhập Email hoặc tên đăng nhập';
    }
    if (cleanPassword.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    final user = _users[cleanEmail];
    if (user == null) {
      return 'Tài khoản không tồn tại. Vui lòng đăng ký trước.';
    }
    if (user['password'] != cleanPassword) {
      return 'Mật khẩu không chính xác';
    }

    _isLoggedIn = true;
    _userEmail = cleanEmail;
    _userName = user['name'] ?? 'Chủ trọ';
    await _prefs.setString(_keySession, cleanEmail);

    notifyListeners();
    return null;
  }

  /// Đăng ký tài khoản mới. Trả về null nếu thành công, hoặc thông báo lỗi.
  Future<String?> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanName.isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(cleanEmail)) {
      return 'Vui lòng nhập địa chỉ Email hợp lệ';
    }
    if (cleanPassword.length < 6) {
      return 'Mật khẩu phải từ 6 ký tự trở lên';
    }
    if (_users.containsKey(cleanEmail)) {
      return 'Email này đã được đăng ký tài khoản';
    }

    _users[cleanEmail] = {'password': cleanPassword, 'name': cleanName};
    await _saveUsers();

    _isLoggedIn = true;
    _userEmail = cleanEmail;
    _userName = cleanName;
    await _prefs.setString(_keySession, cleanEmail);

    notifyListeners();
    return null;
  }

  /// Đổi mật khẩu cho tài khoản đang đăng nhập
  Future<String?> changePassword(String oldPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final email = _userEmail;
    if (email == null || !_users.containsKey(email)) return 'Chưa đăng nhập';

    if (_users[email]!['password'] != oldPassword.trim()) {
      return 'Mật khẩu hiện tại không đúng';
    }
    if (newPassword.trim().length < 6) {
      return 'Mật khẩu mới phải từ 6 ký tự trở lên';
    }

    _users[email]!['password'] = newPassword.trim();
    await _saveUsers();
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userEmail = null;
    await _prefs.remove(_keySession);
    notifyListeners();
  }
}
