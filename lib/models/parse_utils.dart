/// Hàm chuyển đổi dữ liệu an toàn dùng chung cho các Model.
/// Dữ liệu có thể đến từ SQLite (int/double/String) hoặc Supabase
/// (num, bool, chuỗi ngày có múi giờ "+00:00"), nên cần chuẩn hóa.
library;

int parseInt(dynamic v, [int fallback = 0]) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt() ?? fallback;
  return fallback;
}

double parseDouble(dynamic v, [double fallback = 0.0]) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

bool parseBool(dynamic v) => v == true || v == 1 || v == '1' || v == 'true';

/// Đọc ngày giờ và giữ nguyên "giờ đồng hồ" đã lưu (bỏ thông tin múi giờ)
/// để hiển thị giống nhau trên SQLite và Supabase.
DateTime? parseDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  final d = DateTime.tryParse(v.toString());
  if (d == null) return null;
  if (!d.isUtc) return d;
  return DateTime(d.year, d.month, d.day, d.hour, d.minute, d.second,
      d.millisecond, d.microsecond);
}
