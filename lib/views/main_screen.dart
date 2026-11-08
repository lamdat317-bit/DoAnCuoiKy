/// ============================================================================
/// FILE: views/main_screen.dart
/// UI SCREEN: Màn Hình Chính Chứa Thanh Điều Hướng BottomNavigationBar (MainScreen)
/// CHỨC NĂNG CHÍNH:
/// - Khung điều hướng chuyển đổi 3 Tab chính: Dashboard, Phòng trọ, Hóa đơn.
/// - AppBar tích hợp nút Nút Báo bảo trì, Chuyển Dark/Light Mode, Chọn Ngôn ngữ.
/// - Popup Menu hiển thị Thông tin cá nhân, Đổi mật khẩu & Đăng xuất tài khoản.
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import 'dashboard_tab.dart';
import 'invoice_list_tab.dart';
import 'maintenance_screen.dart';
import 'room_list_tab.dart';
import 'widgets/language_selector.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    DashboardTab(),
    RoomListTab(),
    InvoiceListTab(),
  ];

  String _getTitle(int index, AppLocalizations loc) {
    switch (index) {
      case 0:
        return loc.titleDashboard;
      case 1:
        return loc.titleRooms;
      case 2:
        return loc.titleInvoices;
      default:
        return loc.appTitle;
    }
  }

  void _showAccountDialog(BuildContext context, AuthProvider auth) {
    final loc = context.loc;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF3F51B5),
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(loc.accountInfo),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.badge, color: Color(0xFF3F51B5)),
              title: Text(loc.fullName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              subtitle: Text(
                auth.userName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email, color: Color(0xFF3F51B5)),
              title: Text(loc.loginEmail, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              subtitle: Text(
                auth.userEmail ?? 'Chưa cập nhật',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF3F51B5)),
              title: Text(loc.systemRole, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              subtitle: Text(
                auth.userRole == 'Chủ trọ' ? loc.roleLandlord : auth.userRole,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.close),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade800,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showChangePasswordDialog(context, auth);
            },
            icon: const Icon(Icons.key, size: 18, color: Colors.white),
            label: Text(loc.changePassword, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthProvider auth) {
    final loc = context.loc;
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(loc.changePassword),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPassController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: loc.currentPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return loc.enterCurrentPass;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPassController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: loc.newPassword,
                  prefixIcon: const Icon(Icons.key_outlined),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return loc.enterNewPass;
                  }
                  if (val.length < 6) {
                    return loc.passMinLength;
                  }
                  return null;
                },
              ),
            ],
          ),
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
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final error = await auth.changePassword(
                  oldPassController.text,
                  newPassController.text,
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.passChangeSuccess),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              }
            },
            child: Text(loc.update, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    final loc = context.loc;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 8),
            Text(loc.logoutConfirmTitle),
          ],
        ),
        content: Text(loc.logoutConfirmMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.loggedOutSuccess),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(loc.logout, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = context.loc;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentIndex, loc)),
        actions: [
          IconButton(
            icon: const Icon(Icons.build_circle_outlined, color: Colors.orange),
            tooltip: 'Quản lý Bảo trì Sự cố',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MaintenanceScreen()),
              );
            },
          ),
          const ThemeToggleActionItem(),
          const LanguagePickerActionItem(),
          const SizedBox(width: 4),

          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: loc.notifications,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.noNotifications),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            tooltip: loc.accountInfo,
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFF3F51B5),
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                _showAccountDialog(context, auth);
              } else if (value == 'change_pass') {
                _showChangePasswordDialog(context, auth);
              } else if (value == 'logout') {
                _confirmLogout(context, auth);
              }
            },
            itemBuilder: (BuildContext ctx) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      auth.userEmail ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 20, color: Color(0xFF3F51B5)),
                    const SizedBox(width: 10),
                    Text(loc.accountInfo),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'change_pass',
                child: Row(
                  children: [
                    const Icon(Icons.key_outlined, size: 20, color: Colors.amber),
                    const SizedBox(width: 10),
                    Text(loc.changePassword),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20, color: Colors.red),
                    const SizedBox(width: 10),
                    Text(loc.logout, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: loc.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.meeting_room_outlined),
            selectedIcon: const Icon(Icons.meeting_room),
            label: loc.navRooms,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: loc.navInvoices,
          ),
        ],
      ),
    );
  }
}
