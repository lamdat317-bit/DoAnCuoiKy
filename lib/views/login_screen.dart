/// ============================================================================
/// FILE: views/login_screen.dart
/// UI SCREEN: MÀN HÌNH ĐĂNG NHẬP VÀ ĐĂNG KÝ TÀI KHOẢN (LoginScreen)
/// ----------------------------------------------------------------------------
/// NGHỆP VỤ & NÚT THAO TÁC TRÊN MÀN HÌNH NÀY:
/// 1. NÚT CHUYỂN TAB ĐĂNG NHẬP / ĐĂNG KÝ (GestureDetector): Chuyển đổi giữa 2 Form.
/// 2. NÚT "ĐĂNG NHẬP" (ElevatedButton): Gọi AuthProvider.login() xác thực tài khoản.
/// 3. NÚT "ĐĂNG KÝ TÀI KHOẢN" (ElevatedButton): Gọi AuthProvider.register() tạo TK mới.
/// 4. NÚT "Điền nhanh tài khoản Demo" (OutlinedButton): Tự động điền admin@gmail.com / 123456.
/// 5. NÚT "Quên mật khẩu?" (TextButton): Mở Hộp thoại nhập Email khôi phục mật khẩu.
/// 6. NÚT CON MẮT (IconButton): Ẩn / Hiện mật khẩu khi gõ.
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import 'widgets/language_selector.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Key quản lý và kiểm tra dữ liệu Form Đăng nhập & Đăng ký
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Bộ điều khiển nhập dữ liệu (Controllers) Form Đăng nhập
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Bộ điều khiển nhập dữ liệu (Controllers) Form Đăng ký
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  // Các biến trạng thái hiển thị
  bool _isLoginPasswordVisible = false;
  bool _isRegisterPasswordVisible = false;
  bool _rememberMe = true;
  bool _isLoading = false;

  // Chỉ số Tab đang chọn (0 = Đăng nhập, 1 = Đăng ký)
  int _selectedTab = 0;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  /// [NÚT THAO TÁC 4]: Hàm điền nhanh tài khoản mẫu Demo (admin@gmail.com / 123456)
  void _fillDemoAccount() {
    setState(() {
      _selectedTab = 0;
      _loginEmailController.text = 'admin@gmail.com';
      _loginPasswordController.text = '123456';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.loc.demoAccountFilled),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// [NÚT THAO TÁC 2]: Hàm thực thi Đăng nhập tài khoản
  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Gọi AuthProvider để xác thực Email & Mật khẩu
      final authProvider = context.read<AuthProvider>();
      final errorMessage = await authProvider.login(
        _loginEmailController.text,
        _loginPasswordController.text,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (errorMessage != null) {
        // Thông báo lỗi nếu sai mật khẩu hoặc chưa đăng ký
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.loc.t(errorMessage)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Đăng nhập thành công -> AuthProvider tự đổi isLoggedIn thành true -> Tự chuyển sang MainScreen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.loc.loginSuccess),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  /// [NÚT THAO TÁC 3]: Hàm thực thi Đăng ký tài khoản chủ trọ mới
  Future<void> _handleRegister() async {
    if (_registerFormKey.currentState!.validate()) {
      // Kiểm tra mật khẩu xác nhận có khớp không
      if (_registerPasswordController.text !=
          _registerConfirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.loc.passNotMatch),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Gọi AuthProvider để tạo tài khoản mới
      final authProvider = context.read<AuthProvider>();
      final errorMessage = await authProvider.register(
        _registerNameController.text,
        _registerEmailController.text,
        _registerPasswordController.text,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.loc.t(errorMessage)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.loc.registerSuccess),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  /// [NÚT THAO TÁC 5]: Mở Dialog khôi phục mật khẩu khi quên
  void _showForgotPasswordDialog() {
    final loc = context.loc;
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_reset, color: Color(0xFF3F51B5)),
            const SizedBox(width: 8),
            Text(loc.forgotPasswordTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.forgotPasswordDesc,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: loc.loginEmail,
                hintText: loc.recoveryEmailHint,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
            ),
            onPressed: () {
              final email = resetEmailController.text.trim();
              Navigator.pop(ctx);
              if (email.isNotEmpty && email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.recoveryLinkSent),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.enterValidEmail),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(loc.sendRecoveryRequest,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Thanh công cụ trên cùng: Nút Đổi Theme Sáng/Tối & Nút Chọn Ngôn Ngữ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ThemeToggleActionItem(
                    color: isDark ? Colors.amber : const Color(0xFF3F51B5),
                  ),
                  const SizedBox(width: 4),
                  const LanguagePickerActionItem(),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header Logo Ứng dụng
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F51B5).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.apartment,
                          size: 64,
                          color: Color(0xFF3F51B5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.appTitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F51B5),
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.appSubtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const LanguageSegmentedBar(),
                      const SizedBox(height: 20),

                      // Card chứa Form Đăng nhập / Đăng ký
                      Card(
                        elevation: 3,
                        shadowColor: Colors.black.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // [NÚT THAO TÁC 1]: Segmented Tab Bar chuyển giữa Đăng Nhập / Đăng Ký
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2C2C32) : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedTab = 0;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: _selectedTab == 0
                                                ? const Color(0xFF3F51B5)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            loc.login,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: _selectedTab == 0
                                                  ? Colors.white
                                                  : (isDark ? Colors.white70 : Colors.grey.shade700),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedTab = 1;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: _selectedTab == 1
                                                ? const Color(0xFF3F51B5)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            loc.register,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: _selectedTab == 1
                                                  ? Colors.white
                                                  : (isDark ? Colors.white70 : Colors.grey.shade700),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Nội dung Form phụ thuộc vào Tab đang chọn
                              _selectedTab == 0 ? _buildLoginForm() : _buildRegisterForm(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // [NÚT THAO TÁC 4]: Nút "Điền nhanh tài khoản Demo"
                      OutlinedButton.icon(
                        onPressed: _fillDemoAccount,
                        icon: const Icon(Icons.flash_on, size: 18, color: Color(0xFF3F51B5)),
                        label: Text(
                          loc.fillDemoAccount,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF3F51B5)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF3F51B5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [FORM GIAO DIỆN 1]: Form Đăng Nhập
  Widget _buildLoginForm() {
    final loc = context.loc;
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: '${loc.loginEmail} / Email',
              hintText: 'admin@gmail.com',
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return loc.requiredField;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: !_isLoginPasswordVisible,
            decoration: InputDecoration(
              labelText: loc.currentPassword,
              hintText: '••••••',
              prefixIcon: const Icon(Icons.lock_outlined),
              // [NÚT THAO TÁC 6]: Nút Con mắt ẩn/hiện mật khẩu
              suffixIcon: IconButton(
                icon: Icon(
                  _isLoginPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isLoginPasswordVisible = !_isLoginPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return loc.enterCurrentPass;
              }
              if (value.length < 6) {
                return loc.passMinLength;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _rememberMe,
                  activeColor: const Color(0xFF3F51B5),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _rememberMe = val;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                loc.rememberMe,
                style: const TextStyle(fontSize: 13),
              ),
              const Spacer(),
              // [NÚT THAO TÁC 5]: Nút "Quên mật khẩu?"
              TextButton(
                onPressed: _showForgotPasswordDialog,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  loc.forgotPassword,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3F51B5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // [NÚT THAO TÁC 2]: Nút bấm "ĐĂNG NHẬP"
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    loc.login.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// [FORM GIAO DIỆN 2]: Form Đăng Ký Tài Khoản
  Widget _buildRegisterForm() {
    final loc = context.loc;
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _registerNameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: loc.fullName,
              hintText: 'Nguyễn Văn A',
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return loc.requiredField;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: loc.loginEmail,
              hintText: 'chutro@gmail.com',
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return loc.requiredField;
              }
              if (!value.contains('@')) {
                return loc.enterValidEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerPasswordController,
            obscureText: !_isRegisterPasswordVisible,
            decoration: InputDecoration(
              labelText: loc.newPassword,
              hintText: '••••••',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _isRegisterPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isRegisterPasswordVisible = !_isRegisterPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return loc.enterNewPass;
              }
              if (value.length < 6) {
                return loc.passMinLength;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerConfirmPasswordController,
            obscureText: !_isRegisterPasswordVisible,
            decoration: InputDecoration(
              labelText: loc.passConfirm,
              hintText: '••••••',
              prefixIcon: const Icon(Icons.lock_clock_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return loc.requiredField;
              }
              if (value != _registerPasswordController.text) {
                return loc.passNotMatch;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // [NÚT THAO TÁC 3]: Nút bấm "ĐĂNG KÝ TÀI KHOẢN"
          ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    loc.register.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
