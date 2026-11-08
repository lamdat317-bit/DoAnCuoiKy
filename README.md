# Ứng Dụng Quản Lý Phòng Trọ & Căn Hộ Dịch Vụ (Rental Management App)

Ứng dụng di động xây dựng bằng **Flutter**, hỗ trợ toàn diện công tác quản trị căn hộ, phòng trọ, thanh toán hóa đơn, định danh người thuê và theo dõi sự cố bảo trì.

---

## 🌟 Tính Năng Nổi Bật (Key Features)

### 1. 🌐 Đa Ngôn Ngữ Linh Hoạt (Multi-Language Support)
- Hỗ trợ 3 ngôn ngữ hoàn chỉnh:
  - 🇻🇳 **Tiếng Việt** (Mặc định)
  - 🇬🇧 **English**
  - 🇨🇳 **中文 (Simplified Chinese)**
- Nút chuyển đổi nhanh trực tiếp ngay trên thanh AppBar (LanguageSegmentedBar & LanguagePickerActionItem).
- Lưu tùy chọn ngôn ngữ tự động qua SharedPreferences.

### 2. 🌓 Chế Độ Sáng / Tối (Dark & Light Theme)
- Thiết kế giao diện hiện đại theo chuẩn **Material 3**.
- Hỗ trợ đầy đủ Light Mode và Dark Mode dịu mắt, độ tương phản cao.
- Nút chuyển đổi nhanh 1 chạm (ThemeToggleActionItem).

### 3. 🏠 Quản Lý Phòng & Khách Thuê (Room & Tenant Management)
- Theo dõi trạng thái từng phòng: **Còn trống**, **Đang thuê**, **Bảo trì**.
- Thêm mới, chỉnh sửa thông tin phòng, cập nhật đơn giá phòng, điện, nước.
- Trực quan hóa danh sách phòng kèm bộ lọc tiện lợi.

### 4. 🪪 Quản Lý Thành Viên Phòng & CCCD (Room Members & Identification)
- Quản lý danh sách người lưu trú trong từng phòng.
- Lưu trữ thông tin định danh: Họ tên, Số điện thoại, Số CCCD/CMND, Ngày sinh, Quê quán.
- Thiết lập đại diện phòng chịu trách nhiệm ký hợp đồng và nhận hóa đơn.

### 5. 🛠️ Báo Sự Cố & Quản Lý Bảo Trì (Maintenance & Repairs)
- Ghi nhận yêu cầu sự cố từ người thuê hoặc chủ nhà (điện nước, điều hòa, khóa cửa...).
- Theo dõi tiến độ: **Chờ xử lý**, **Đang sửa chữa**, **Đã hoàn thành**.
- Thống kê chi phí sửa chữa theo từng phòng và tổng chi phí toàn khu trọ.

### 6. 🧾 Lập Hóa Đơn & Tính Tiền Tự Động (Billing & Invoicing)
- Tự động tính tiền điện theo chỉ số cũ/mới, tiền nước và các dịch vụ đi kèm.
- Quản lý trạng thái hóa đơn: **Chưa thanh toán** / **Đã thanh toán**.
- Hỗ trợ xuất chi tiết hóa đơn và tính năng chia sẻ nhanh qua tin nhắn / Zalo.

### 7. 📊 Báo Cáo & Thống Kê (Dashboard Analytics)
- Thống kê doanh thu dự kiến trong tháng.
- Thống kê tổng công nợ chưa thu và tỷ lệ lấp đầy phòng.

---

## 🛠️ Công Nghệ Sử Dụng (Tech Stack)

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK >= 3.0.0)
- **State Management**: provider (MultiProvider, ChangeNotifierProvider)
- **Local Database**: sqflite (SQLite database)
- **Preferences**: shared_preferences
- **Localization**: lutter_localizations, intl
- **Utility Libraries**: share_plus, image_picker, path

---

## 📁 Cấu Trúc Thư Mục (Project Structure)

`	ext
lib/
├── data/               # Mock data khởi tạo ban đầu
├── l10n/               # Đa ngôn ngữ (AppLocalizations: vi, en, zh)
├── models/             # Data models (Room, Invoice, Member, Maintenance)
├── providers/          # State management (RentalProvider, AuthProvider, SettingsProvider)
├── services/           # DatabaseHelper (SQLite), SettingsService
├── theme/              # Material 3 Light & Dark AppTheme
├── views/              # Giao diện chính (Dashboard, RoomList, InvoiceList, Settings...)
│   └── widgets/        # Reusable UI widgets (RoomCard, LanguageSelector, Dialogs...)
└── main.dart           # Điểm khởi chạy ứng dụng
`

---

## 🚀 Hướng Dẫn Cài Đặt & Chạy Ứng Dụng (Getting Started)

### Yêu cầu tiên quyết:
- Đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install).
- Android Studio / VS Code và thiết bị di động (Android Emulator hoặc máy thật).

### Các bước thực hiện:

1. **Clone repository:**
   `ash
   git clone https://github.com/lamdat317-bit/DoAnCuoiKy.git
   cd DoAnCuoiKy
   `

2. **Cài đặt dependencies:**
   `ash
   flutter pub get
   `

3. **Chạy kiểm thử (Unit & Widget tests):**
   `ash
   flutter test
   `

4. **Khởi chạy ứng dụng:**
   `ash
   flutter run
   `

### Tài khoản trải nghiệm (Demo Account):
- **Email:** dmin@gmail.com
- **Mật khẩu:** 123456
- *(Ứng dụng có nút **Điền nhanh tài khoản Demo** ngay tại màn hình đăng nhập).*
