/// ============================================================================
/// BẢNG CHUYỂN ĐỔI: SQLite (tiếng Anh) ⇄ Supabase (tiếng Việt)
/// ============================================================================
/// Trong app (SQLite, Model) vẫn dùng tên tiếng Anh như cũ.
/// Khi gửi lên Supabase, tên bảng / tên cột / giá trị trạng thái được đổi sang
/// tiếng Việt để mở Supabase Dashboard ra là đọc hiểu ngay:
///   rooms.status = 'occupied'  ➜  phong_tro.trang_thai = 'Đã thuê'
/// Khi tải về thì đổi ngược lại.
/// ============================================================================
library;

class CloudTable {
  /// Tên bảng trên Supabase
  final String name;

  /// Tên cột SQLite ➜ tên cột Supabase
  final Map<String, String> columns;

  /// Cột kiểu đúng/sai trên Supabase (SQLite lưu 0/1)
  final Set<String> boolColumns;

  /// Giá trị trạng thái: giá trị trong app ➜ chữ tiếng Việt trên Supabase
  final Map<String, String> statusValues;

  const CloudTable({
    required this.name,
    required this.columns,
    this.boolColumns = const {},
    this.statusValues = const {},
  });
}

const Map<String, CloudTable> cloudTables = {
  'rooms': CloudTable(
    name: 'phong_tro',
    columns: {
      'id': 'ma_phong',
      'name': 'ten_phong',
      'base_price': 'gia_thue',
      'status': 'trang_thai',
      'tenant_name': 'nguoi_thue',
      'phone': 'so_dien_thoai',
      'contract_end': 'ngay_het_hop_dong',
      'old_electricity': 'chi_so_dien',
      'old_water': 'chi_so_nuoc',
      'image_url': 'link_anh',
      'occupant_count': 'so_nguoi_o',
      'check_in_date': 'ngay_vao_o',
      'check_out_date': 'ngay_tra_phong',
      'deposit_amount': 'tien_coc',
    },
    statusValues: {
      'available': 'Trống',
      'occupied': 'Đã thuê',
      'maintenance': 'Bảo trì',
    },
  ),
  'invoices': CloudTable(
    name: 'hoa_don',
    columns: {
      'id': 'ma_hoa_don',
      'room_id': 'ma_phong',
      'room_name': 'ten_phong',
      'tenant_name': 'nguoi_thue',
      'room_price': 'tien_phong',
      'old_elec': 'dien_cu',
      'new_elec': 'dien_moi',
      'elec_price': 'gia_dien',
      'old_water': 'nuoc_cu',
      'new_water': 'nuoc_moi',
      'water_price': 'gia_nuoc',
      'service_fee': 'phi_dich_vu',
      'created_at': 'ngay_lap',
      'status': 'trang_thai',
      'paid_at': 'ngay_thanh_toan',
    },
    statusValues: {
      'pending': 'Chưa thanh toán',
      'paid': 'Đã thanh toán',
    },
  ),
  'room_members': CloudTable(
    name: 'cu_dan',
    columns: {
      'id': 'ma_cu_dan',
      'room_id': 'ma_phong',
      'name': 'ho_ten',
      'id_card': 'so_cccd',
      'phone': 'so_dien_thoai',
      'date_of_birth': 'ngay_sinh',
      'hometown': 'que_quan',
      'is_representative': 'la_dai_dien',
      'created_at': 'ngay_tao',
    },
    boolColumns: {'is_representative'},
  ),
  'maintenance_requests': CloudTable(
    name: 'su_co_bao_tri',
    columns: {
      'id': 'ma_su_co',
      'room_id': 'ma_phong',
      'room_name': 'ten_phong',
      'title': 'ten_su_co',
      'description': 'mo_ta',
      'repair_cost': 'chi_phi_sua',
      'status': 'trang_thai',
      'created_at': 'ngay_bao',
      'completed_at': 'ngay_hoan_thanh',
    },
    statusValues: {
      'pending': 'Chờ xử lý',
      'inProgress': 'Đang sửa',
      'completed': 'Đã xong',
      'cancelled': 'Đã hủy',
    },
  ),
  // Cài đặt dùng chung cho mọi máy (chỉ 1 dòng, mã 'mac_dinh').
  // Không nằm trong SQLite: trong app lưu bằng SharedPreferences.
  'settings': CloudTable(
    name: 'cai_dat',
    columns: {
      'id': 'ma_cai_dat',
      'elec_price': 'gia_dien',
      'water_price': 'gia_nuoc',
      'service_fee': 'phi_dich_vu',
      'bank_code': 'ma_ngan_hang',
      'account_no': 'so_tai_khoan',
      'account_holder': 'chu_tai_khoan',
      'updated_at': 'ngay_cap_nhat',
    },
  ),
};

/// Đổi 1 dòng dữ liệu SQLite ➜ dòng dữ liệu Supabase (tiếng Việt)
Map<String, dynamic> toCloudRow(String localTable, Map<String, dynamic> row) {
  final t = cloudTables[localTable]!;
  final out = <String, dynamic>{};
  row.forEach((key, value) {
    final cloudKey = t.columns[key];
    if (cloudKey == null) return;
    dynamic v = value;
    if (t.boolColumns.contains(key)) {
      v = value == 1 || value == true;
    } else if (key == 'status' && value is String) {
      v = t.statusValues[value] ?? value;
    } else if (v is double && v == v.truncateToDouble()) {
      v = v.toInt(); // 3500000.0 ➜ 3500000 cho dễ đọc
    }
    out[cloudKey] = v;
  });
  return out;
}

/// Đổi 1 dòng dữ liệu Supabase (tiếng Việt) ➜ dòng dữ liệu SQLite
Map<String, dynamic> fromCloudRow(
    String localTable, Map<String, dynamic> row) {
  final t = cloudTables[localTable]!;
  final out = <String, dynamic>{};
  t.columns.forEach((localKey, cloudKey) {
    if (!row.containsKey(cloudKey)) return;
    dynamic v = row[cloudKey];
    if (t.boolColumns.contains(localKey)) {
      v = (v == true || v == 1) ? 1 : 0;
    } else if (localKey == 'status' && v is String) {
      v = t.statusValues.entries
          .firstWhere((e) => e.value == v, orElse: () => MapEntry(v, v))
          .key;
    }
    out[localKey] = v;
  });
  return out;
}

/// Tên cột Supabase tương ứng với cột SQLite
String cloudColumn(String localTable, String localColumn) =>
    cloudTables[localTable]!.columns[localColumn] ?? localColumn;
