import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  String _userName = 'Chủ trọ Admin';
  final String _userRole = 'Chủ trọ';

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String get userName => _userName;
  String get userRole => _userRole;

  // Mock users database
  final Map<String, String> _users = {
    'admin@gmail.com': '123456',
    'chutro@gmail.com': '123456',
  };

  final Map<String, String> _userNames = {
    'admin@gmail.com': 'Chủ trọ Admin',
    'chutro@gmail.com': 'Nguyễn Văn Quyền',
  };

  /// Log in with email and password. Returns null on success, or an error message on failure.
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
    if (cleanPassword.length < 6) {
      return 'Mật khẩu phải chứa ít nhất 6 ký tự';
    }

    // If existing user, check password match
    if (_users.containsKey(cleanEmail)) {
      if (_users[cleanEmail] != cleanPassword) {
        return 'Mật khẩu không chính xác';
      }
    }

    _isLoggedIn = true;
    _userEmail = cleanEmail;

    if (_userNames.containsKey(cleanEmail)) {
      _userName = _userNames[cleanEmail]!;
    } else {
      String namePart = cleanEmail.split('@').first;
      if (namePart.isNotEmpty) {
        _userName = namePart[0].toUpperCase() + namePart.substring(1);
      } else {
        _userName = 'Chủ trọ';
      }
      _userNames[cleanEmail] = _userName;
      _users[cleanEmail] = cleanPassword;
    }

    notifyListeners();
    return null;
  }

  /// Register a new user. Returns null on success, or an error message on failure.
  Future<String?> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanName.isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return 'Vui lòng nhập địa chỉ Email hợp lệ';
    }
    if (cleanPassword.length < 6) {
      return 'Mật khẩu phải từ 6 ký tự trở lên';
    }

    if (_users.containsKey(cleanEmail)) {
      return 'Email này đã được đăng ký tài khoản';
    }

    _users[cleanEmail] = cleanPassword;
    _userNames[cleanEmail] = cleanName;

    _isLoggedIn = true;
    _userEmail = cleanEmail;
    _userName = cleanName;

    notifyListeners();
    return null;
  }

  /// Change password for currently logged-in user
  Future<String?> changePassword(String oldPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_userEmail == null) return 'Chưa đăng nhập';

    if (_users[_userEmail] != oldPassword) {
      return 'Mật khẩu hiện tại không đúng';
    }

    if (newPassword.length < 6) {
      return 'Mật khẩu mới phải từ 6 ký tự trở lên';
    }

    _users[_userEmail!] = newPassword;
    notifyListeners();
    return null;
  }

  void logout() {
    _isLoggedIn = false;
    _userEmail = null;
    notifyListeners();
  }
}
