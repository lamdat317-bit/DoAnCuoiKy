-- ============================================================================
-- CƠ SỞ DỮ LIỆU SUPABASE — APP QUẢN LÝ PHÒNG TRỌ (tên bảng/cột tiếng Việt)
-- ----------------------------------------------------------------------------
-- Cách dùng: Supabase Dashboard → SQL Editor → New query → dán toàn bộ → Run.
-- Chạy lại nhiều lần vẫn an toàn (không xóa dữ liệu).
--
--   phong_tro      : Danh sách phòng trọ
--   hoa_don        : Hóa đơn tiền phòng, điện, nước hằng tháng
--   cu_dan         : Người ở trong phòng & số CCCD/CMND
--   su_co_bao_tri  : Sự cố hỏng hóc & chi phí sửa chữa
--   cai_dat        : Giá điện nước, phí dịch vụ, ngân hàng (dùng chung mọi máy)
-- ============================================================================

-- 1. BẢNG PHÒNG TRỌ ----------------------------------------------------------
create table if not exists public.phong_tro (
  ma_phong          text primary key,
  ten_phong         text not null,
  gia_thue          numeric not null default 0,
  trang_thai        text not null default 'Trống'
                    check (trang_thai in ('Trống', 'Đã thuê', 'Bảo trì')),
  nguoi_thue        text,
  so_dien_thoai     text,
  ngay_het_hop_dong date,
  chi_so_dien       integer not null default 0,
  chi_so_nuoc       integer not null default 0,
  link_anh          text,
  so_nguoi_o        integer not null default 1,
  ngay_vao_o        date,
  ngay_tra_phong    date,
  tien_coc          numeric not null default 0
);

comment on table  public.phong_tro is 'Danh sách phòng trọ';
comment on column public.phong_tro.ma_phong          is 'Mã phòng (vd: room_101)';
comment on column public.phong_tro.ten_phong         is 'Tên phòng (vd: P.101)';
comment on column public.phong_tro.gia_thue          is 'Giá thuê mỗi tháng (VNĐ)';
comment on column public.phong_tro.trang_thai        is 'Trống / Đã thuê / Bảo trì';
comment on column public.phong_tro.nguoi_thue        is 'Tên người đại diện thuê phòng';
comment on column public.phong_tro.so_dien_thoai     is 'Số điện thoại người thuê';
comment on column public.phong_tro.ngay_het_hop_dong is 'Ngày hết hạn hợp đồng';
comment on column public.phong_tro.chi_so_dien       is 'Chỉ số đồng hồ điện lần chốt gần nhất (kWh)';
comment on column public.phong_tro.chi_so_nuoc       is 'Chỉ số đồng hồ nước lần chốt gần nhất (m³)';
comment on column public.phong_tro.link_anh          is 'Đường dẫn ảnh phòng';
comment on column public.phong_tro.so_nguoi_o        is 'Số người đang ở';
comment on column public.phong_tro.ngay_vao_o        is 'Ngày bắt đầu vào ở';
comment on column public.phong_tro.ngay_tra_phong    is 'Ngày dự kiến trả phòng';
comment on column public.phong_tro.tien_coc          is 'Tiền đặt cọc (VNĐ)';

-- 2. BẢNG HÓA ĐƠN ------------------------------------------------------------
create table if not exists public.hoa_don (
  ma_hoa_don      text primary key,
  ma_phong        text not null,
  ten_phong       text not null,
  nguoi_thue      text not null,
  tien_phong      numeric not null default 0,
  dien_cu         integer not null default 0,
  dien_moi        integer not null default 0,
  gia_dien        numeric not null default 0,
  nuoc_cu         integer not null default 0,
  nuoc_moi        integer not null default 0,
  gia_nuoc        numeric not null default 0,
  phi_dich_vu     numeric not null default 0,
  -- Tự động tính, không cần app gửi lên
  tong_tien       numeric generated always as (
                    tien_phong
                    + greatest(dien_moi - dien_cu, 0) * gia_dien
                    + greatest(nuoc_moi - nuoc_cu, 0) * gia_nuoc
                    + phi_dich_vu
                  ) stored,
  ngay_lap        timestamp not null default now(),
  trang_thai      text not null default 'Chưa thanh toán'
                  check (trang_thai in ('Chưa thanh toán', 'Đã thanh toán')),
  ngay_thanh_toan timestamp
);

comment on table  public.hoa_don is 'Hóa đơn tiền phòng hằng tháng';
comment on column public.hoa_don.ma_hoa_don      is 'Mã hóa đơn';
comment on column public.hoa_don.ma_phong        is 'Mã phòng (liên kết bảng phong_tro)';
comment on column public.hoa_don.ten_phong       is 'Tên phòng lúc lập hóa đơn';
comment on column public.hoa_don.nguoi_thue      is 'Người thuê lúc lập hóa đơn';
comment on column public.hoa_don.tien_phong      is 'Tiền phòng (VNĐ)';
comment on column public.hoa_don.dien_cu         is 'Chỉ số điện tháng trước (kWh)';
comment on column public.hoa_don.dien_moi        is 'Chỉ số điện tháng này (kWh)';
comment on column public.hoa_don.gia_dien        is 'Đơn giá điện (VNĐ/kWh)';
comment on column public.hoa_don.nuoc_cu         is 'Chỉ số nước tháng trước (m³)';
comment on column public.hoa_don.nuoc_moi        is 'Chỉ số nước tháng này (m³)';
comment on column public.hoa_don.gia_nuoc        is 'Đơn giá nước (VNĐ/m³)';
comment on column public.hoa_don.phi_dich_vu     is 'Phí dịch vụ: wifi, rác... (VNĐ)';
comment on column public.hoa_don.tong_tien       is 'TỔNG TIỀN phải trả (tự động tính)';
comment on column public.hoa_don.ngay_lap        is 'Ngày giờ lập hóa đơn';
comment on column public.hoa_don.trang_thai      is 'Chưa thanh toán / Đã thanh toán';
comment on column public.hoa_don.ngay_thanh_toan is 'Ngày giờ khách trả tiền';

-- 3. BẢNG CƯ DÂN (CCCD/CMND) -------------------------------------------------
create table if not exists public.cu_dan (
  ma_cu_dan     text primary key,
  ma_phong      text not null,
  ho_ten        text not null,
  so_cccd       text not null,
  so_dien_thoai text,
  ngay_sinh     date,
  que_quan      text,
  la_dai_dien   boolean not null default false,
  ngay_tao      timestamp not null default now()
);

comment on table  public.cu_dan is 'Người ở trong phòng & số CCCD/CMND';
comment on column public.cu_dan.ma_cu_dan     is 'Mã cư dân';
comment on column public.cu_dan.ma_phong      is 'Mã phòng đang ở (liên kết bảng phong_tro)';
comment on column public.cu_dan.ho_ten        is 'Họ và tên';
comment on column public.cu_dan.so_cccd       is 'Số CCCD / CMND';
comment on column public.cu_dan.so_dien_thoai is 'Số điện thoại';
comment on column public.cu_dan.ngay_sinh     is 'Ngày sinh';
comment on column public.cu_dan.que_quan      is 'Quê quán / Thường trú';
comment on column public.cu_dan.la_dai_dien   is 'Có phải người đại diện hợp đồng không';
comment on column public.cu_dan.ngay_tao      is 'Ngày thêm vào danh sách';

-- 4. BẢNG SỰ CỐ BẢO TRÌ ------------------------------------------------------
create table if not exists public.su_co_bao_tri (
  ma_su_co        text primary key,
  ma_phong        text not null,
  ten_phong       text not null,
  ten_su_co       text not null,
  mo_ta           text,
  chi_phi_sua     numeric not null default 0,
  trang_thai      text not null default 'Chờ xử lý'
                  check (trang_thai in ('Chờ xử lý', 'Đang sửa', 'Đã xong', 'Đã hủy')),
  ngay_bao        timestamp not null default now(),
  ngay_hoan_thanh timestamp
);

comment on table  public.su_co_bao_tri is 'Sự cố hỏng hóc & chi phí sửa chữa';
comment on column public.su_co_bao_tri.ma_su_co        is 'Mã sự cố';
comment on column public.su_co_bao_tri.ma_phong        is 'Mã phòng (liên kết bảng phong_tro)';
comment on column public.su_co_bao_tri.ten_phong       is 'Tên phòng';
comment on column public.su_co_bao_tri.ten_su_co       is 'Tên sự cố (vd: Hỏng máy lạnh)';
comment on column public.su_co_bao_tri.mo_ta           is 'Mô tả chi tiết';
comment on column public.su_co_bao_tri.chi_phi_sua     is 'Chi phí sửa chữa (VNĐ)';
comment on column public.su_co_bao_tri.trang_thai      is 'Chờ xử lý / Đang sửa / Đã xong / Đã hủy';
comment on column public.su_co_bao_tri.ngay_bao        is 'Ngày báo sự cố';
comment on column public.su_co_bao_tri.ngay_hoan_thanh is 'Ngày sửa xong';

-- 4b. BẢNG CÀI ĐẶT (dùng chung mọi máy, chỉ 1 dòng 'mac_dinh') ---------------
create table if not exists public.cai_dat (
  ma_cai_dat     text primary key default 'mac_dinh',
  gia_dien       numeric not null default 3500,
  gia_nuoc       numeric not null default 20000,
  phi_dich_vu    numeric not null default 150000,
  ma_ngan_hang   text not null default 'TCB',
  so_tai_khoan   text not null default '19037202589016',
  chu_tai_khoan  text not null default 'CHUYEN KHOAN TRO',
  ngay_cap_nhat  timestamp not null default now()
);

comment on table  public.cai_dat is 'Cài đặt dùng chung: giá điện nước, phí dịch vụ, tài khoản ngân hàng (mã QR)';
comment on column public.cai_dat.ma_cai_dat    is 'Mã cài đặt (luôn là mac_dinh)';
comment on column public.cai_dat.gia_dien      is 'Đơn giá điện (VNĐ/kWh)';
comment on column public.cai_dat.gia_nuoc      is 'Đơn giá nước (VNĐ/m³)';
comment on column public.cai_dat.phi_dich_vu   is 'Phí dịch vụ hằng tháng (VNĐ)';
comment on column public.cai_dat.ma_ngan_hang  is 'Mã ngân hàng nhận tiền (vd: TCB = Techcombank, MB, VCB)';
comment on column public.cai_dat.so_tai_khoan  is 'Số tài khoản nhận tiền';
comment on column public.cai_dat.chu_tai_khoan is 'Tên chủ tài khoản';
comment on column public.cai_dat.ngay_cap_nhat is 'Lần sửa gần nhất';

-- 5. QUYỀN TRUY CẬP (Row Level Security) -------------------------------------
--    App dùng publishable (anon) key nên cần cho phép đọc/ghi.
--    LƯU Ý: ai có key cũng đọc/ghi được — phù hợp đồ án/demo.
do $$
declare
  t text;
begin
  foreach t in array array['phong_tro', 'hoa_don', 'cu_dan', 'su_co_bao_tri', 'cai_dat']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "app_toan_quyen" on public.%I', t);
    execute format(
      'create policy "app_toan_quyen" on public.%I for all to anon, authenticated using (true) with check (true)',
      t);
  end loop;
end $$;

-- 6. (Tùy chọn) Xóa 2 bảng tiếng Anh cũ không còn dùng — bỏ dấu "--" để chạy
-- drop table if exists public.rooms;
-- drop table if exists public.invoices;

-- Làm mới cache của API để app thấy bảng mới ngay
notify pgrst, 'reload schema';
