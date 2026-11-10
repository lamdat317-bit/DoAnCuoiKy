import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import '../models/room_model.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const List<Locale> supportedLocales = [
    Locale('vi', 'VN'),
    Locale('en', 'US'),
    Locale('zh', 'CN'),
  ];

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get languageCode => locale.languageCode;

  // Helper dictionary lookup
  static final Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      // General
      'app_title': 'Quản lý Phòng trọ',
      'app_subtitle': 'Ứng dụng Quản lý Căn hộ Dịch vụ & Phòng trọ',
      'save': 'Lưu',
      'cancel': 'Hủy',
      'close': 'Đóng',
      'delete': 'Xóa',
      'edit': 'Sửa',
      'update': 'Cập nhật',
      'confirm': 'Xác nhận',
      'all': 'Tất cả',
      'month': 'tháng',
      'people': 'người',
      'share': 'Chia sẻ',
      'share_zalo': 'Gửi Zalo',
      'notifications': 'Thông báo',
      'no_notifications': 'Không có thông báo mới',
      'search': 'Tìm kiếm',
      'language': 'Ngôn ngữ',
      'lang_vi': 'Tiếng Việt',
      'lang_en': 'English',
      'lang_zh': '中文',
      'theme_section_title': 'Chế độ hiển thị Giao diện',
      'theme_light': 'Chế độ Sáng',
      'theme_dark': 'Chế độ Tối',
      'required_field': 'Vui lòng không để trống',
      'invalid_number': 'Vui lòng nhập số hợp lệ',
      'must_be_positive': 'Giá trị phải lớn hơn hoặc bằng 0',

      // Navigation & Tabs
      'nav_dashboard': 'Tổng quan',
      'nav_rooms': 'Phòng trọ',
      'nav_invoices': 'Hóa đơn',
      'title_dashboard': 'Tổng quan Quản lý',
      'title_rooms': 'Danh sách Phòng trọ',
      'title_invoices': 'Lịch sử Hóa đơn',

      // Auth & Account
      'login': 'Đăng Nhập',
      'register': 'Đăng Ký',
      'logout': 'Đăng xuất',
      'logout_confirm_title': 'Đăng Xuất',
      'logout_confirm_msg': 'Bạn có chắc chắn muốn đăng xuất khỏi hệ thống không?',
      'logged_out_success': 'Đã đăng xuất thành công',
      'account_info': 'Thông tin tài khoản',
      'full_name': 'Họ và tên',
      'login_email': 'Email đăng nhập',
      'system_role': 'Vai trò hệ thống',
      'role_landlord': 'Chủ trọ',
      'change_password': 'Đổi Mật Khẩu',
      'current_password': 'Mật khẩu hiện tại',
      'new_password': 'Mật khẩu mới',
      'enter_current_pass': 'Vui lòng nhập mật khẩu hiện tại',
      'enter_new_pass': 'Vui lòng nhập mật khẩu mới',
      'pass_min_length': 'Mật khẩu phải từ 6 ký tự trở lên',
      'pass_change_success': 'Đổi mật khẩu thành công!',
      'pass_confirm': 'Xác nhận mật khẩu',
      'pass_not_match': 'Mật khẩu xác nhận không trùng khớp',
      'forgot_password': 'Quên mật khẩu?',
      'forgot_password_title': 'Quên Mật Khẩu',
      'forgot_password_desc': 'Nhập địa chỉ Email của bạn để nhận hướng dẫn khôi phục mật khẩu:',
      'recovery_email_hint': 'admin@gmail.com',
      'send_recovery_request': 'Gửi yêu cầu',
      'recovery_link_sent': 'Đã gửi liên kết khôi phục mật khẩu. Vui lòng kiểm tra hộp thư.',
      'enter_valid_email': 'Vui lòng nhập Email hợp lệ',
      'fill_demo_account': 'Tài khoản mẫu: admin@gmail.com / 123456',
      'demo_account_filled': 'Đã điền tài khoản mẫu: admin@gmail.com / 123456',
      'remember_me': 'Ghi nhớ đăng nhập',
      'login_success': 'Đăng nhập thành công!',
      'register_success': 'Đăng ký tài khoản thành công!',
      'already_have_account': 'Đã có tài khoản? Đăng nhập ngay',
      'no_account': 'Chưa có tài khoản? Đăng ký ngay',

      // Dashboard
      'expected_revenue': 'DOANH THU DỰ KIẾN THÁNG',
      'based_on_rented_rooms': 'Dựa trên các phòng đang cho thuê',
      'total_unpaid_debt': 'TỔNG CÔNG NỢ CHƯA THU',
      'unpaid_invoices_count': 'Hiện có {count} hóa đơn chưa thanh toán',
      'stat_available': 'Phòng trống',
      'stat_occupied': 'Đang thuê',
      'stat_occupancy': 'Lấp đầy',
      'rooms_need_billing': 'Phòng cần chốt điện nước tháng này',
      'no_rented_rooms': 'Hiện chưa có phòng nào đang thuê',
      'recent_invoices': 'Hóa đơn vừa lập gần đây',
      'modal_available_rooms': 'Danh sách Phòng trống',
      'modal_occupied_rooms': 'Danh sách Phòng đang thuê',
      'modal_occupancy_rooms': 'Tỷ lệ Lấp đầy & Toàn bộ phòng',
      'no_empty_rooms_msg': 'Hiện không có phòng nào đang trống',
      'no_rented_rooms_msg': 'Hiện chưa có phòng nào đang thuê',
      'no_rooms_data': 'Chưa có dữ liệu phòng',
      'billing_action': 'Tính tiền',
      'checkout_action': 'Trả phòng',

      // Room List & Card
      'search_room_hint': 'Tìm theo tên phòng, tên khách, số điện thoại...',
      'filter_all': 'Tất cả',
      'filter_available': 'Trống',
      'filter_occupied': 'Đang thuê',
      'filter_maintenance': 'Bảo trì',
      'no_rooms_found': 'Không tìm thấy phòng nào phù hợp',
      'add_new_room': 'Thêm phòng mới',
      'edit_room_info': 'Sửa thông tin & ảnh',
      'checkout_and_deposit': 'Trả phòng & Quyết toán cọc',
      'change_checkout_date': 'Đổi ngày check-out',
      'change_status': 'Đổi trạng thái',
      'delete_room': 'Xóa phòng',
      'delete_room_confirm_title': 'Xóa phòng trọ',
      'delete_room_confirm_msg': 'Bạn có chắc chắn muốn xóa {room}? Dữ liệu phòng trọ này sẽ bị xóa vĩnh viễn khỏi hệ thống.',
      'delete_room_success': 'Đã xóa {room} thành công',
      'delete_now': 'Xóa ngay',
      'delete_invoice': 'Xóa hóa đơn',
      'delete_invoice_confirm_title': 'Xóa hóa đơn',
      'delete_invoice_confirm_msg': 'Bạn có chắc chắn muốn xóa hóa đơn của {room}? Bản ghi này sẽ bị xóa vĩnh viễn khỏi hệ thống.',
      'delete_invoice_success': 'Đã xóa hóa đơn thành công',
      'delete_member_title': 'Xóa thành viên',
      'delete_member_confirm_msg': 'Bạn có chắc chắn muốn xóa thành viên "{name}" (CCCD: {idCard}) khỏi {room} không?',
      'delete_member_success': 'Đã xóa thành viên {name}',
      'price_per_month': 'Giá thuê',
      'tenant_representative': 'Đại diện',
      'unknown_tenant': 'Chưa rõ',
      'occupant_count': 'Số người ở',
      'deposit': 'Cọc',
      'check_in': 'Vào ở',
      'check_out': 'Out',
      'pick_date': 'Chọn',
      'checkout_date_updated': 'Đã cập nhật ngày check-out thành công',
      'add_room_image': 'Thêm hình ảnh cho phòng',

      // Room Add/Edit Dialog
      'dialog_add_room': 'Thêm Phòng Trọ Mới',
      'dialog_edit_room': 'Cập Nhật Phòng Trọ',
      'room_name_label': 'Tên phòng / Số phòng',
      'room_name_hint': 'VD: P.101, Phòng VIP 2...',
      'base_price_label': 'Giá thuê cơ bản (VNĐ / tháng)',
      'room_status_label': 'Trạng thái phòng',
      'initial_elec_label': 'Chỉ số điện ban đầu (kWh)',
      'initial_water_label': 'Chỉ số nước ban đầu (m³)',
      'tenant_info_header': 'Thông tin khách thuê (Nếu đang cho thuê)',
      'tenant_name_label': 'Họ và tên khách đại diện',
      'tenant_phone_label': 'Số điện thoại liên hệ',
      'occupant_count_label': 'Số lượng người ở',
      'deposit_label': 'Tiền đặt cọc (VNĐ)',
      'check_in_date_label': 'Ngày bắt đầu thuê (Check-in)',
      'check_out_date_label': 'Ngày kết thúc / dự kiến out (Check-out)',
      'not_selected': 'Chưa chọn',
      'select_photo_source': 'Chọn nguồn ảnh',
      'take_photo': 'Chụp ảnh từ Camera',
      'choose_from_gallery': 'Chọn ảnh từ Thư viện máy',
      'sample_photos': 'Hoặc chọn ảnh phòng mẫu có sẵn:',
      'save_room_btn': 'Lưu Phòng Trọ',
      'room_saved_success': 'Lưu phòng trọ thành công!',

      // Billing Bottom Sheet
      'billing_for_room': 'LẬP HÓA ĐƠN TIỀN NHÀ - {room}',
      'electricity_billing': 'Chỉ số Điện (kWh)',
      'water_billing': 'Chỉ số Nước (m³)',
      'old_index': 'Chỉ số cũ',
      'new_index': 'Chỉ số mới',
      'consumption': 'Tiêu thụ',
      'unit_price': 'Đơn giá',
      'bill_summary': 'Tóm tắt chi phí hóa đơn',
      'service_fee': 'Phí dịch vụ',
      'wifi_trash': 'Wifi + Rác',
      'total_due': 'TỔNG CẦN THANH TOÁN',
      'create_invoice_btn': 'Xác Nhận & Tạo Hóa Đơn',
      'invoice_created_success': 'Đã tạo hóa đơn cho {room} thành công!',
      'new_index_cannot_be_less': 'Chỉ số mới không được nhỏ hơn chỉ số cũ',
      'already_billed_this_month': 'Phòng {room} đã được lập hóa đơn trong tháng này. Nếu lập nhầm, hãy xóa hóa đơn cũ rồi lập lại.',
      'billed_this_month': 'Đã chốt',
      'cloud_synced': 'Đã đồng bộ Cloud lúc {time}',
      'cloud_syncing': 'Đang đồng bộ Cloud...',
      'cloud_offline': 'Chưa kết nối được Cloud — dữ liệu vẫn lưu trên máy',
      'cloud_pending': '{count} thay đổi chờ gửi lên Cloud',
      'sync_now': 'Đồng bộ ngay',

      // Checkout Dialog
      'checkout_room_title': 'Trả phòng {room}',
      'checkout_instructions': 'Kiểm tra chỉ số điện nước cuối cùng và các chi phí phát sinh để quyết toán tiền cọc cho khách thuê.',
      'final_electricity': 'Chỉ số điện chốt trả phòng',
      'final_water': 'Chỉ số nước chốt trả phòng',
      'damage_fee_label': 'Chi phí đền bù / Hư hại (nếu có)',
      'damage_fee_hint': '0',
      'settlement_summary': 'Bảng quyết toán tiền cọc',
      'tenant_deposit': 'Tiền cọc của khách:',
      'final_elec_cost': 'Tiền điện chốt:',
      'final_water_cost': 'Tiền nước chốt:',
      'final_damage_cost': 'Phí hư hại/khấu trừ:',
      'total_deductions': 'Tổng khấu trừ:',
      'refund_to_tenant': 'SỐ TIỀN HOÀN TRẢ KHÁCH:',
      'tenant_must_pay_more': 'KHÁCH CẦN ĐÓNG THÊM:',
      'confirm_checkout_btn': 'Xác Nhận Trả Phòng',
      'checkout_success_msg': 'Đã hoàn tất trả phòng {room}!',

      // Invoices Tab & Details
      'unpaid_count': 'Chưa thu',
      'paid_count': 'Đã thu',
      'no_invoices': 'Chưa có hóa đơn nào',
      'invoice_title': 'Hóa đơn {room}',
      'created_date': 'Ngày lập',
      'room_charge': 'Tiền phòng',
      'electricity_charge': 'Điện',
      'water_charge': 'Nước',
      'total_amount': 'Tổng cộng',
      'auto_vietqr': 'MÃ VIETQR CHUYỂN KHOẢN TỰ ĐỘNG',
      'cannot_load_qr': 'Không thể tải VietQR. Vui lòng kiểm tra kết nối mạng.',
      'mark_as_paid': 'Đã thanh toán',
      'paid_recorded': 'Đã xác nhận thu tiền thành công!',
      'invoice_share_subject': 'Hóa đơn tiền nhà {room}',
      'invoice_notice': 'THÔNG BÁO TÍNH TIỀN PHÒNG {room}',
      'tenant': 'Khách thuê',
      'thank_you': 'Xin cảm ơn!',

      // Settings Screen
      'settings_title': 'Cài đặt Biểu phí & VietQR',
      'language_section_title': 'Ngôn ngữ hiển thị (Language)',
      'fee_section_title': 'Biểu phí Mặc định (Tự động tính hóa đơn)',
      'elec_price_label': 'Đơn giá Điện (VNĐ / kWh)',
      'water_price_label': 'Đơn giá Nước (VNĐ / m³)',
      'service_fee_label': 'Phí Dịch vụ cố định / phòng (Wifi, Rác, VS)',
      'vietqr_section_title': 'Cấu hình Tài khoản Ngân hàng (VietQR)',
      'bank_code_label': 'Ngân hàng nhận chuyển khoản',
      'account_no_label': 'Số tài khoản ngân hàng',
      'account_holder_label': 'Tên chủ tài khoản (In hoa không dấu)',
      'save_settings_btn': 'Lưu Tất Cả Cài Đặt',
      'settings_saved_success': 'Lưu cài đặt biểu phí & ngôn ngữ thành công!',

      // Statuses
      'status_available': 'Trống',
      'status_occupied': 'Đang thuê',
      'status_maintenance': 'Bảo trì',
      'status_pending': 'Chưa thanh toán',
      'status_paid': 'Đã thanh toán',
    },
    'en': {
      // General
      'app_title': 'Rental Room Management',
      'app_subtitle': 'Serviced Apartments & Rental Management App',
      'save': 'Save',
      'cancel': 'Cancel',
      'close': 'Close',
      'delete': 'Delete',
      'edit': 'Edit',
      'update': 'Update',
      'confirm': 'Confirm',
      'all': 'All',
      'month': 'month',
      'people': 'people',
      'share': 'Share',
      'share_zalo': 'Share Bill',
      'notifications': 'Notifications',
      'no_notifications': 'No new notifications',
      'search': 'Search',
      'language': 'Language',
      'lang_vi': 'Tiếng Việt',
      'lang_en': 'English',
      'lang_zh': '中文',
      'theme_section_title': 'Theme Appearance',
      'theme_light': 'Light Mode',
      'theme_dark': 'Dark Mode',
      'required_field': 'This field is required',
      'invalid_number': 'Please enter a valid number',
      'must_be_positive': 'Value must be greater than or equal to 0',

      // Navigation & Tabs
      'nav_dashboard': 'Dashboard',
      'nav_rooms': 'Rooms',
      'nav_invoices': 'Invoices',
      'title_dashboard': 'Management Overview',
      'title_rooms': 'Rental Rooms List',
      'title_invoices': 'Invoice History',

      // Auth & Account
      'login': 'Login',
      'register': 'Register',
      'logout': 'Log Out',
      'logout_confirm_title': 'Log Out',
      'logout_confirm_msg': 'Are you sure you want to log out from the system?',
      'logged_out_success': 'Successfully logged out',
      'account_info': 'Account Information',
      'full_name': 'Full Name',
      'login_email': 'Login Email',
      'system_role': 'System Role',
      'role_landlord': 'Landlord',
      'change_password': 'Change Password',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'enter_current_pass': 'Please enter current password',
      'enter_new_pass': 'Please enter new password',
      'pass_min_length': 'Password must be at least 6 characters',
      'pass_change_success': 'Password changed successfully!',
      'pass_confirm': 'Confirm Password',
      'pass_not_match': 'Confirmation password does not match',
      'forgot_password': 'Forgot password?',
      'forgot_password_title': 'Forgot Password',
      'forgot_password_desc': 'Enter your registered email address to receive password recovery instructions:',
      'recovery_email_hint': 'admin@gmail.com',
      'send_recovery_request': 'Send Request',
      'recovery_link_sent': 'Password reset instructions have been sent to your email.',
      'enter_valid_email': 'Please enter a valid email address',
      'fill_demo_account': 'Demo account: admin@gmail.com / 123456',
      'demo_account_filled': 'Filled demo account: admin@gmail.com / 123456',
      'remember_me': 'Remember Me',
      'login_success': 'Login successful!',
      'register_success': 'Account registered successfully!',
      'already_have_account': 'Already have an account? Log in',
      'no_account': "Don't have an account? Sign up",

      // Dashboard
      'expected_revenue': 'EXPECTED MONTHLY REVENUE',
      'based_on_rented_rooms': 'Based on currently rented rooms',
      'total_unpaid_debt': 'TOTAL UNPAID RECEIVABLES',
      'unpaid_invoices_count': '{count} unpaid invoices remaining',
      'stat_available': 'Available',
      'stat_occupied': 'Occupied',
      'stat_occupancy': 'Occupancy',
      'rooms_need_billing': 'Rooms Due for Meter Reading & Billing',
      'no_rented_rooms': 'No rooms currently rented',
      'recent_invoices': 'Recent Invoices',
      'modal_available_rooms': 'Available Rooms List',
      'modal_occupied_rooms': 'Occupied Rooms List',
      'modal_occupancy_rooms': 'Occupancy Rate & All Rooms',
      'no_empty_rooms_msg': 'There are currently no empty rooms',
      'no_rented_rooms_msg': 'There are currently no rented rooms',
      'no_rooms_data': 'No room data available',
      'billing_action': 'Calculate',
      'checkout_action': 'Check-out',

      // Room List & Card
      'search_room_hint': 'Search by room name, tenant, phone...',
      'filter_all': 'All',
      'filter_available': 'Available',
      'filter_occupied': 'Occupied',
      'filter_maintenance': 'Maintenance',
      'no_rooms_found': 'No matching rooms found',
      'add_new_room': 'Add New Room',
      'edit_room_info': 'Edit Info & Photo',
      'checkout_and_deposit': 'Check-out & Deposit Settlement',
      'change_checkout_date': 'Change Check-out Date',
      'change_status': 'Change Status',
      'delete_room': 'Delete Room',
      'delete_room_confirm_title': 'Delete Rental Room',
      'delete_room_confirm_msg': 'Are you sure you want to delete {room}? This room data will be permanently removed.',
      'delete_room_success': 'Successfully deleted {room}',
      'delete_now': 'Delete Now',
      'delete_invoice': 'Delete Invoice',
      'delete_invoice_confirm_title': 'Delete Invoice',
      'delete_invoice_confirm_msg': 'Are you sure you want to delete the invoice for {room}? This record will be permanently removed.',
      'delete_invoice_success': 'Invoice deleted successfully',
      'delete_member_title': 'Delete Member',
      'delete_member_confirm_msg': 'Are you sure you want to delete member "{name}" (ID: {idCard}) from {room}?',
      'delete_member_success': 'Successfully deleted member {name}',
      'price_per_month': 'Rent Price',
      'tenant_representative': 'Tenant',
      'unknown_tenant': 'Unknown',
      'occupant_count': 'Occupants',
      'deposit': 'Deposit',
      'check_in': 'Check-in',
      'check_out': 'Check-out',
      'pick_date': 'Select',
      'checkout_date_updated': 'Check-out date updated successfully',
      'add_room_image': 'Add room image',

      // Room Add/Edit Dialog
      'dialog_add_room': 'Add New Room',
      'dialog_edit_room': 'Edit Room Details',
      'room_name_label': 'Room Name / Number',
      'room_name_hint': 'e.g. Room 101, VIP Room 2...',
      'base_price_label': 'Base Rent Price (VND / month)',
      'room_status_label': 'Room Status',
      'initial_elec_label': 'Initial Electricity Reading (kWh)',
      'initial_water_label': 'Initial Water Reading (m³)',
      'tenant_info_header': 'Tenant Information (If currently rented)',
      'tenant_name_label': 'Primary Tenant Name',
      'tenant_phone_label': 'Contact Phone Number',
      'occupant_count_label': 'Number of Occupants',
      'deposit_label': 'Deposit Amount (VND)',
      'check_in_date_label': 'Check-in Date',
      'check_out_date_label': 'Expected Check-out Date',
      'not_selected': 'Not selected',
      'select_photo_source': 'Select Photo Source',
      'take_photo': 'Take Photo with Camera',
      'choose_from_gallery': 'Choose from Device Gallery',
      'sample_photos': 'Or select a sample room photo:',
      'save_room_btn': 'Save Room',
      'room_saved_success': 'Room saved successfully!',

      // Billing Bottom Sheet
      'billing_for_room': 'GENERATE RENT BILL - {room}',
      'electricity_billing': 'Electricity Reading (kWh)',
      'water_billing': 'Water Reading (m³)',
      'old_index': 'Previous',
      'new_index': 'Current',
      'consumption': 'Usage',
      'unit_price': 'Unit Price',
      'bill_summary': 'Bill Summary',
      'service_fee': 'Service Fee',
      'wifi_trash': 'Wifi + Trash',
      'total_due': 'TOTAL AMOUNT DUE',
      'create_invoice_btn': 'Confirm & Create Invoice',
      'invoice_created_success': 'Invoice for {room} created successfully!',
      'new_index_cannot_be_less': 'New reading cannot be lower than previous reading',
      'already_billed_this_month': 'Room {room} has already been billed this month. If it was a mistake, delete the old invoice and create it again.',
      'billed_this_month': 'Billed',
      'cloud_synced': 'Cloud synced at {time}',
      'cloud_syncing': 'Syncing with Cloud...',
      'cloud_offline': 'Cloud not reachable — data is still saved on this device',
      'cloud_pending': '{count} changes waiting to upload',
      'sync_now': 'Sync now',

      // Checkout Dialog
      'checkout_room_title': 'Check-out {room}',
      'checkout_instructions': 'Verify final utility readings and damages to settle the tenant deposit.',
      'final_electricity': 'Final Electricity Reading',
      'final_water': 'Final Water Reading',
      'damage_fee_label': 'Damages / Repair Costs (if any)',
      'damage_fee_hint': '0',
      'settlement_summary': 'Deposit Settlement Summary',
      'tenant_deposit': 'Tenant Deposit:',
      'final_elec_cost': 'Electricity Fee:',
      'final_water_cost': 'Water Fee:',
      'final_damage_cost': 'Damage / Deductions:',
      'total_deductions': 'Total Deductions:',
      'refund_to_tenant': 'REFUND TO TENANT:',
      'tenant_must_pay_more': 'TENANT MUST PAY EXTRA:',
      'confirm_checkout_btn': 'Confirm Check-out',
      'checkout_success_msg': 'Check-out completed for {room}!',

      // Invoices Tab & Details
      'unpaid_count': 'Unpaid',
      'paid_count': 'Paid',
      'no_invoices': 'No invoices yet',
      'invoice_title': 'Invoice {room}',
      'created_date': 'Issued Date',
      'room_charge': 'Room Rent',
      'electricity_charge': 'Electricity',
      'water_charge': 'Water',
      'total_amount': 'Total',
      'auto_vietqr': 'AUTOMATIC VIETQR BANK TRANSFER',
      'cannot_load_qr': 'Unable to load VietQR. Please check internet connection.',
      'mark_as_paid': 'Mark as Paid',
      'paid_recorded': 'Payment verified & cleared successfully!',
      'invoice_share_subject': 'Rent Invoice for {room}',
      'invoice_notice': 'RENT PAYMENT NOTICE FOR {room}',
      'tenant': 'Tenant',
      'thank_you': 'Thank you!',

      // Settings Screen
      'settings_title': 'Rates & VietQR Settings',
      'language_section_title': 'Display Language',
      'fee_section_title': 'Default Rates (Auto Calculation)',
      'elec_price_label': 'Electricity Rate (VND / kWh)',
      'water_price_label': 'Water Rate (VND / m³)',
      'service_fee_label': 'Fixed Service Fee / room (Wifi, Trash, Cleaning)',
      'vietqr_section_title': 'Bank Account Configuration (VietQR)',
      'bank_code_label': 'Receiving Bank',
      'account_no_label': 'Bank Account Number',
      'account_holder_label': 'Account Holder Name (UPPERCASE)',
      'save_settings_btn': 'Save All Settings',
      'settings_saved_success': 'Settings saved successfully!',

      // Statuses
      'status_available': 'Available',
      'status_occupied': 'Occupied',
      'status_maintenance': 'Maintenance',
      'status_pending': 'Unpaid',
      'status_paid': 'Paid',
    },
    'zh': {
      // General
      'app_title': '房屋出租管理系统',
      'app_subtitle': '酒店式公寓与房屋租赁管理系统',
      'save': '保存',
      'cancel': '取消',
      'close': '关闭',
      'delete': '删除',
      'edit': '编辑',
      'update': '更新',
      'confirm': '确认',
      'all': '全部',
      'month': '月',
      'people': '人',
      'share': '分享',
      'share_zalo': '发送账单',
      'notifications': '通知',
      'no_notifications': '暂无新通知',
      'search': '搜索',
      'language': '语言设置',
      'lang_vi': 'Tiếng Việt',
      'lang_en': 'English',
      'lang_zh': '中文',
      'theme_section_title': '界面外观模式',
      'theme_light': '浅色模式',
      'theme_dark': '深色模式',
      'required_field': '此项不能为空',
      'invalid_number': '请输入有效数字',
      'must_be_positive': '数值必须大于或等于0',

      // Navigation & Tabs
      'nav_dashboard': '概览',
      'nav_rooms': '房源',
      'nav_invoices': '账单',
      'title_dashboard': '管理总览',
      'title_rooms': '房屋列表',
      'title_invoices': '账单历史',

      // Auth & Account
      'login': '登录',
      'register': '注册',
      'logout': '退出登录',
      'logout_confirm_title': '退出登录',
      'logout_confirm_msg': '您确定要退出当前系统吗？',
      'logged_out_success': '已成功退出登录',
      'account_info': '账户信息',
      'full_name': '姓名',
      'login_email': '登录邮箱',
      'system_role': '系统角色',
      'role_landlord': '房东',
      'change_password': '修改密码',
      'current_password': '当前密码',
      'new_password': '新密码',
      'enter_current_pass': '请输入当前密码',
      'enter_new_pass': '请输入新密码',
      'pass_min_length': '密码至少需要6位字符',
      'pass_change_success': '密码修改成功！',
      'pass_confirm': '确认密码',
      'pass_not_match': '两次输入的密码不一致',
      'forgot_password': '忘记密码？',
      'forgot_password_title': '找回密码',
      'forgot_password_desc': '请输入您的注册邮箱以接收重置密码链接：',
      'recovery_email_hint': 'admin@gmail.com',
      'send_recovery_request': '发送请求',
      'recovery_link_sent': '重置链接已发送到您的邮箱，请查收。',
      'enter_valid_email': '请输入有效的邮箱地址',
      'fill_demo_account': '演示账户: admin@gmail.com / 123456',
      'demo_account_filled': '已填入演示账户: admin@gmail.com / 123456',
      'remember_me': '记住登录状态',
      'login_success': '登录成功！',
      'register_success': '账户注册成功！',
      'already_have_account': '已有账户？立即登录',
      'no_account': '还没有账户？立即注册',

      // Dashboard
      'expected_revenue': '本月预计总收入',
      'based_on_rented_rooms': '基于当前在租房源统计',
      'total_unpaid_debt': '待收账单总额',
      'unpaid_invoices_count': '当前共有 {count} 笔待缴账单',
      'stat_available': '空闲房源',
      'stat_occupied': '已出租',
      'stat_occupancy': '入住率',
      'rooms_need_billing': '本月待结算水电房源',
      'no_rented_rooms': '当前暂无在租房源',
      'recent_invoices': '最近生成账单',
      'modal_available_rooms': '空闲房源列表',
      'modal_occupied_rooms': '在租房源列表',
      'modal_occupancy_rooms': '入住率与全部房源',
      'no_empty_rooms_msg': '当前没有空闲房源',
      'no_rented_rooms_msg': '当前没有已租房源',
      'no_rooms_data': '暂无房源数据',
      'billing_action': '计费',
      'checkout_action': '退房',

      // Room List & Card
      'search_room_hint': '搜索房间号、租客姓名或电话...',
      'filter_all': '全部',
      'filter_available': '空闲',
      'filter_occupied': '已租',
      'filter_maintenance': '维护中',
      'no_rooms_found': '未找到符合条件的房源',
      'add_new_room': '新增房源',
      'edit_room_info': '修改信息与照片',
      'checkout_and_deposit': '退房与押金清算',
      'change_checkout_date': '修改退房日期',
      'change_status': '更改状态',
      'delete_room': '删除房源',
      'delete_room_confirm_title': '删除房源',
      'delete_room_confirm_msg': '您确定要删除 {room} 吗？该房源数据将从系统中永久删除。',
      'delete_room_success': '已成功删除 {room}',
      'delete_now': '静止删除',
      'delete_invoice': '删除账单',
      'delete_invoice_confirm_title': '删除账单',
      'delete_invoice_confirm_msg': '您确定要删除 {room} 的账单吗？该记录将被永久删除。',
      'delete_invoice_success': '已成功删除账单',
      'delete_member_title': '删除成员',
      'delete_member_confirm_msg': '您确定要从 {room} 中删除成员 "{name}"（身份证：{idCard}）吗？',
      'delete_member_success': '已成功删除成员 {name}',
      'price_per_month': '月租金',
      'tenant_representative': '承租人',
      'unknown_tenant': '未知',
      'occupant_count': '入住人数',
      'deposit': '押金',
      'check_in': '入住日期',
      'check_out': '退房日期',
      'pick_date': '选择',
      'checkout_date_updated': '退房日期已成功更新',
      'add_room_image': '添加房间照片',

      // Room Add/Edit Dialog
      'dialog_add_room': '新增出租房源',
      'dialog_edit_room': '编辑房源信息',
      'room_name_label': '房间名称 / 房间号',
      'room_name_hint': '例如：101号房、VIP套房2...',
      'base_price_label': '基础月租金 (越南盾/月)',
      'room_status_label': '房屋状态',
      'initial_elec_label': '初始电表底数 (kWh)',
      'initial_water_label': '初始水表底数 (m³)',
      'tenant_info_header': '租客信息 (若当前已出租)',
      'tenant_name_label': '承租人姓名',
      'tenant_phone_label': '联系电话',
      'occupant_count_label': '实际入住人数',
      'deposit_label': '押金金额 (越南盾)',
      'check_in_date_label': '入住起始日期 (Check-in)',
      'check_out_date_label': '合同到期 / 预计退房日期 (Check-out)',
      'not_selected': '未选择',
      'select_photo_source': '选择照片来源',
      'take_photo': '拍照上传',
      'choose_from_gallery': '从手机相册选择',
      'sample_photos': '或选择系统精选样板照片：',
      'save_room_btn': '保存房源',
      'room_saved_success': '房源保存成功！',

      // Billing Bottom Sheet
      'billing_for_room': '生成租金账单 - {room}',
      'electricity_billing': '电表读数 (kWh)',
      'water_billing': '水表读数 (m³)',
      'old_index': '上期读数',
      'new_index': '本期读数',
      'consumption': '本期用量',
      'unit_price': '单价',
      'bill_summary': '费用明细汇总',
      'service_fee': '综合服务费',
      'wifi_trash': 'Wifi网络与卫生',
      'total_due': '本期应缴总金额',
      'create_invoice_btn': '确认并生成账单',
      'invoice_created_success': '已成功为 {room} 生成账单！',
      'new_index_cannot_be_less': '新读数不能小于上期底数',
      'already_billed_this_month': '房间 {room} 本月已开具账单。如有错误，请先删除旧账单再重新开具。',
      'billed_this_month': '已结算',
      'cloud_synced': '已于 {time} 同步云端',
      'cloud_syncing': '正在同步云端...',
      'cloud_offline': '无法连接云端 — 数据仍保存在本机',
      'cloud_pending': '{count} 项更改等待上传',
      'sync_now': '立即同步',

      // Checkout Dialog
      'checkout_room_title': '办理退房 - {room}',
      'checkout_instructions': '核验最终水电表读数及设施损耗情况，清算租客押金。',
      'final_electricity': '最终电表读数',
      'final_water': '最终水表读数',
      'damage_fee_label': '设施赔偿 / 扣款金额 (如有)',
      'damage_fee_hint': '0',
      'settlement_summary': '押金清算清单',
      'tenant_deposit': '租客原始押金：',
      'final_elec_cost': '最终电费结算：',
      'final_water_cost': '最终水费结算：',
      'final_damage_cost': '损耗与扣款：',
      'total_deductions': '总扣除金额：',
      'refund_to_tenant': '应退还租客金额：',
      'tenant_must_pay_more': '租客需补缴金额：',
      'confirm_checkout_btn': '确认结算退房',
      'checkout_success_msg': '{room} 已顺利办理退房！',

      // Invoices Tab & Details
      'unpaid_count': '待支付',
      'paid_count': '已支付',
      'no_invoices': '暂无任何账单',
      'invoice_title': '{room} 账单',
      'created_date': '开票日期',
      'room_charge': '房屋租金',
      'electricity_charge': '电费',
      'water_charge': '水费',
      'total_amount': '总计金额',
      'auto_vietqr': 'VIETQR 扫码转账码',
      'cannot_load_qr': '无法加载二维码，请检查网络连接。',
      'mark_as_paid': '确认收款',
      'paid_recorded': '已成功确认收款！',
      'invoice_share_subject': '{room} 租金缴费账单',
      'invoice_notice': '{room} 房租水电缴费通知单',
      'tenant': '租客姓名',
      'thank_you': '感谢您的配合！',

      // Settings Screen
      'settings_title': '费率与VietQR设置',
      'language_section_title': '界面语言 (Language)',
      'fee_section_title': '默认费率设置 (用于自动生成账单)',
      'elec_price_label': '电费单价 (越南盾 / kWh)',
      'water_price_label': '水费单价 (越南盾 / m³)',
      'service_fee_label': '固定服务费 / 间 (含网络、垃圾、保洁)',
      'vietqr_section_title': '收款银行账户设置 (VietQR)',
      'bank_code_label': '收款银行',
      'account_no_label': '银行账号',
      'account_holder_label': '账户持有人姓名 (大写无音调)',
      'save_settings_btn': '保存全部设置',
      'settings_saved_success': '费率与语言设置保存成功！',

      // Statuses
      'status_available': '空闲',
      'status_occupied': '已租',
      'status_maintenance': '维护中',
      'status_pending': '未支付',
      'status_paid': '已支付',
    },
  };

  String t(String key, [Map<String, String>? params]) {
    final lang = _localizedValues.containsKey(locale.languageCode)
        ? locale.languageCode
        : 'vi';
    String text = _localizedValues[lang]?[key] ??
        _localizedValues['vi']?[key] ??
        key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }
    return text;
  }

  // Common getters
  String get appTitle => t('app_title');
  String get appSubtitle => t('app_subtitle');
  String get save => t('save');
  String get cancel => t('cancel');
  String get close => t('close');
  String get delete => t('delete');
  String get edit => t('edit');
  String get update => t('update');
  String get confirm => t('confirm');
  String get all => t('all');
  String get month => t('month');
  String get people => t('people');
  String get share => t('share');
  String get shareZalo => t('share_zalo');
  String get notifications => t('notifications');
  String get noNotifications => t('no_notifications');
  String get search => t('search');
  String get language => t('language');
  String get langVi => t('lang_vi');
  String get langEn => t('lang_en');
  String get langZh => t('lang_zh');
  String get themeSectionTitle => t('theme_section_title');
  String get themeLight => t('theme_light');
  String get themeDark => t('theme_dark');
  String get requiredField => t('required_field');
  String get invalidNumber => t('invalid_number');
  String get mustBePositive => t('must_be_positive');

  // Navigation
  String get navDashboard => t('nav_dashboard');
  String get navRooms => t('nav_rooms');
  String get navInvoices => t('nav_invoices');
  String get titleDashboard => t('title_dashboard');
  String get titleRooms => t('title_rooms');
  String get titleInvoices => t('title_invoices');

  // Auth
  String get login => t('login');
  String get register => t('register');
  String get logout => t('logout');
  String get logoutConfirmTitle => t('logout_confirm_title');
  String get logoutConfirmMsg => t('logout_confirm_msg');
  String get loggedOutSuccess => t('logged_out_success');
  String get accountInfo => t('account_info');
  String get fullName => t('full_name');
  String get loginEmail => t('login_email');
  String get systemRole => t('system_role');
  String get roleLandlord => t('role_landlord');
  String get changePassword => t('change_password');
  String get currentPassword => t('current_password');
  String get newPassword => t('new_password');
  String get enterCurrentPass => t('enter_current_pass');
  String get enterNewPass => t('enter_new_pass');
  String get passMinLength => t('pass_min_length');
  String get passChangeSuccess => t('pass_change_success');
  String get passConfirm => t('pass_confirm');
  String get passNotMatch => t('pass_not_match');
  String get forgotPassword => t('forgot_password');
  String get forgotPasswordTitle => t('forgot_password_title');
  String get forgotPasswordDesc => t('forgot_password_desc');
  String get recoveryEmailHint => t('recovery_email_hint');
  String get sendRecoveryRequest => t('send_recovery_request');
  String get recoveryLinkSent => t('recovery_link_sent');
  String get enterValidEmail => t('enter_valid_email');
  String get fillDemoAccount => t('fill_demo_account');
  String get demoAccountFilled => t('demo_account_filled');
  String get rememberMe => t('remember_me');
  String get loginSuccess => t('login_success');
  String get registerSuccess => t('register_success');
  String get alreadyHaveAccount => t('already_have_account');
  String get noAccount => t('no_account');

  // Dashboard
  String get expectedRevenue => t('expected_revenue');
  String get basedOnRentedRooms => t('based_on_rented_rooms');
  String get totalUnpaidDebt => t('total_unpaid_debt');
  String unpaidInvoicesCount(int count) =>
      t('unpaid_invoices_count', {'count': count.toString()});
  String get statAvailable => t('stat_available');
  String get statOccupied => t('stat_occupied');
  String get statOccupancy => t('stat_occupancy');
  String get roomsNeedBilling => t('rooms_need_billing');
  String get noRentedRooms => t('no_rented_rooms');
  String get recentInvoices => t('recent_invoices');
  String get modalAvailableRooms => t('modal_available_rooms');
  String get modalOccupiedRooms => t('modal_occupied_rooms');
  String get modalOccupancyRooms => t('modal_occupancy_rooms');
  String get noEmptyRoomsMsg => t('no_empty_rooms_msg');
  String get noRentedRoomsMsg => t('no_rented_rooms_msg');
  String get noRoomsData => t('no_rooms_data');
  String get billingAction => t('billing_action');
  String get checkoutAction => t('checkout_action');

  // Room List & Card
  String get searchRoomHint => t('search_room_hint');
  String get filterAll => t('filter_all');
  String get filterAvailable => t('filter_available');
  String get filterOccupied => t('filter_occupied');
  String get filterMaintenance => t('filter_maintenance');
  String get noRoomsFound => t('no_rooms_found');
  String get addNewRoom => t('add_new_room');
  String get editRoomInfo => t('edit_room_info');
  String get checkoutAndDeposit => t('checkout_and_deposit');
  String get changeCheckoutDate => t('change_checkout_date');
  String get changeStatus => t('change_status');
  String get deleteRoom => t('delete_room');
  String get deleteRoomConfirmTitle => t('delete_room_confirm_title');
  String deleteRoomConfirmMsg(String room) =>
      t('delete_room_confirm_msg', {'room': room});
  String deleteRoomSuccess(String room) =>
      t('delete_room_success', {'room': room});
  String get deleteNow => t('delete_now');
  String get deleteInvoice => t('delete_invoice');
  String get deleteInvoiceConfirmTitle => t('delete_invoice_confirm_title');
  String deleteInvoiceConfirmMsg(String room) =>
      t('delete_invoice_confirm_msg', {'room': room});
  String get deleteInvoiceSuccess => t('delete_invoice_success');
  String get deleteMemberTitle => t('delete_member_title');
  String deleteMemberConfirmMsg(String name, String idCard, String room) =>
      t('delete_member_confirm_msg',
          {'name': name, 'idCard': idCard, 'room': room});
  String deleteMemberSuccess(String name) =>
      t('delete_member_success', {'name': name});
  String get pricePerMonth => t('price_per_month');
  String get tenantRepresentative => t('tenant_representative');
  String get unknownTenant => t('unknown_tenant');
  String get occupantCount => t('occupant_count');
  String get deposit => t('deposit');
  String get checkIn => t('check_in');
  String get checkOut => t('check_out');
  String get pickDate => t('pick_date');
  String get checkoutDateUpdated => t('checkout_date_updated');
  String get addRoomImage => t('add_room_image');

  // Room Add/Edit
  String get dialogAddRoom => t('dialog_add_room');
  String get dialogEditRoom => t('dialog_edit_room');
  String get roomNameLabel => t('room_name_label');
  String get roomNameHint => t('room_name_hint');
  String get basePriceLabel => t('base_price_label');
  String get roomStatusLabel => t('room_status_label');
  String get initialElecLabel => t('initial_elec_label');
  String get initialWaterLabel => t('initial_water_label');
  String get tenantInfoHeader => t('tenant_info_header');
  String get tenantNameLabel => t('tenant_name_label');
  String get tenantPhoneLabel => t('tenant_phone_label');
  String get occupantCountLabel => t('occupant_count_label');
  String get depositLabel => t('deposit_label');
  String get checkInDateLabel => t('check_in_date_label');
  String get checkOutDateLabel => t('check_out_date_label');
  String get notSelected => t('not_selected');
  String get selectPhotoSource => t('select_photo_source');
  String get takePhoto => t('take_photo');
  String get chooseFromGallery => t('choose_from_gallery');
  String get samplePhotos => t('sample_photos');
  String get saveRoomBtn => t('save_room_btn');
  String get roomSavedSuccess => t('room_saved_success');

  // Billing
  String billingForRoom(String room) =>
      t('billing_for_room', {'room': room});
  String get electricityBilling => t('electricity_billing');
  String get waterBilling => t('water_billing');
  String get oldIndex => t('old_index');
  String get newIndex => t('new_index');
  String get consumption => t('consumption');
  String get unitPrice => t('unit_price');
  String get billSummary => t('bill_summary');
  String get serviceFee => t('service_fee');
  String get wifiTrash => t('wifi_trash');
  String get totalDue => t('total_due');
  String get createInvoiceBtn => t('create_invoice_btn');
  String invoiceCreatedSuccess(String room) =>
      t('invoice_created_success', {'room': room});
  String get newIndexCannotBeLess => t('new_index_cannot_be_less');
  String alreadyBilledThisMonth(String room) =>
      t('already_billed_this_month').replaceAll('{room}', room);
  String get billedThisMonth => t('billed_this_month');
  String cloudSynced(String time) =>
      t('cloud_synced').replaceAll('{time}', time);
  String get cloudSyncing => t('cloud_syncing');
  String get cloudOffline => t('cloud_offline');
  String cloudPending(int count) =>
      t('cloud_pending').replaceAll('{count}', '$count');
  String get syncNow => t('sync_now');

  // Checkout
  String checkoutRoomTitle(String room) =>
      t('checkout_room_title', {'room': room});
  String get checkoutInstructions => t('checkout_instructions');
  String get finalElectricity => t('final_electricity');
  String get finalWater => t('final_water');
  String get damageFeeLabel => t('damage_fee_label');
  String get damageFeeHint => t('damage_fee_hint');
  String get settlementSummary => t('settlement_summary');
  String get tenantDeposit => t('tenant_deposit');
  String get finalElecCost => t('final_elec_cost');
  String get finalWaterCost => t('final_water_cost');
  String get finalDamageCost => t('final_damage_cost');
  String get totalDeductions => t('total_deductions');
  String get refundToTenant => t('refund_to_tenant');
  String get tenantMustPayMore => t('tenant_must_pay_more');
  String get confirmCheckoutBtn => t('confirm_checkout_btn');
  String checkoutSuccessMsg(String room) =>
      t('checkout_success_msg', {'room': room});

  // Invoices
  String get unpaidCount => t('unpaid_count');
  String get paidCount => t('paid_count');
  String get noInvoices => t('no_invoices');
  String invoiceTitle(String room) =>
      t('invoice_title', {'room': room});
  String get createdDate => t('created_date');
  String get roomCharge => t('room_charge');
  String get electricityCharge => t('electricity_charge');
  String get waterCharge => t('water_charge');
  String get totalAmount => t('total_amount');
  String get autoVietQr => t('auto_vietqr');
  String get cannotLoadQr => t('cannot_load_qr');
  String get markAsPaid => t('mark_as_paid');
  String get paidRecorded => t('paid_recorded');
  String invoiceShareSubject(String room) =>
      t('invoice_share_subject', {'room': room});
  String invoiceNotice(String room) =>
      t('invoice_notice', {'room': room});
  String get tenant => t('tenant');
  String get thankYou => t('thank_you');

  // Settings
  String get settingsTitle => t('settings_title');
  String get languageSectionTitle => t('language_section_title');
  String get feeSectionTitle => t('fee_section_title');
  String get elecPriceLabel => t('elec_price_label');
  String get waterPriceLabel => t('water_price_label');
  String get serviceFeeLabel => t('service_fee_label');
  String get vietqrSectionTitle => t('vietqr_section_title');
  String get bankCodeLabel => t('bank_code_label');
  String get accountNoLabel => t('account_no_label');
  String get accountHolderLabel => t('account_holder_label');
  String get saveSettingsBtn => t('save_settings_btn');
  String get settingsSavedSuccess => t('settings_saved_success');

  // Statuses
  String roomStatus(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return t('status_available');
      case RoomStatus.occupied:
        return t('status_occupied');
      case RoomStatus.maintenance:
        return t('status_maintenance');
    }
  }

  String invoiceStatus(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.pending:
        return t('status_pending');
      case InvoiceStatus.paid:
        return t('status_paid');
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsContextExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
