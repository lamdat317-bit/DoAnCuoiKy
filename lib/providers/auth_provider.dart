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

  /// Đăng nhập. Trả về null nếu thành công, hoặc KEY ngôn ngữ của lỗi (dịch bằng loc.t).
  Future<String?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty) {
      return 'err_enter_email';
    }
    if (cleanPassword.isEmpty) {
      return 'err_enter_password';
    }

    final user = _users[cleanEmail];
    if (user == null) {
      return 'err_account_not_found';
    }
    if (user['password'] != cleanPassword) {
      return 'err_wrong_password';
    }

    _isLoggedIn = true;
    _userEmail = cleanEmail;
    _userName = user['name'] ?? 'Chủ trọ';
    await _prefs.setString(_keySession, cleanEmail);

    notifyListeners();
    return null;
  }

  /// Đăng ký tài khoản mới. Trả về null nếu thành công, hoặc KEY ngôn ngữ của lỗi (dịch bằng loc.t).
  Future<String?> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanName.isEmpty) {
      return 'err_enter_name';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(cleanEmail)) {
      return 'enter_valid_email';
    }
    if (cleanPassword.length < 6) {
      return 'pass_min_length';
    }
    if (_users.containsKey(cleanEmail)) {
      return 'err_email_taken';
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
    if (email == null || !_users.containsKey(email)) return 'err_not_logged_in';

    if (_users[email]!['password'] != oldPassword.trim()) {
      return 'err_current_pass_wrong';
    }
    if (newPassword.trim().length < 6) {
      return 'pass_min_length';
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
