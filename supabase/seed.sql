-- ============================================================================
-- DỮ LIỆU MẪU — chạy SAU schema.sql
-- Supabase Dashboard → SQL Editor → New query → dán toàn bộ → Run.
-- Chạy lại nhiều lần vẫn an toàn: dòng nào đã có (trùng mã) thì bỏ qua.
-- Mở app / kéo để làm mới → app tải dữ liệu này về máy.
-- ============================================================================

-- 1. PHÒNG TRỌ (giống dữ liệu mẫu trong app: lib/data/mock_data.dart) --------
insert into public.phong_tro
  (ma_phong, ten_phong, gia_thue, trang_thai, nguoi_thue, so_dien_thoai,
   ngay_het_hop_dong, chi_so_dien, chi_so_nuoc, link_anh, so_nguoi_o,
   ngay_vao_o, ngay_tra_phong, tien_coc)
values
  ('room_101', 'P.101', 3500000, 'Đã thuê', 'Nguyễn Văn An', '0901234567',
   '2025-12-31', 1420, 85,
   'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600&auto=format&fit=crop&q=80',
   2, '2024-01-15', '2025-12-31', 0),
  ('room_102', 'P.102', 3200000, 'Trống', null, null, null, 920, 50,
   'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=600&auto=format&fit=crop&q=80',
   1, null, null, 0),
  ('room_201', 'P.201', 4000000, 'Đã thuê', 'Lê Thị Hoa', '0912345678',
   '2025-10-15', 2150, 110,
   'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&auto=format&fit=crop&q=80',
   3, '2023-10-15', '2025-10-15', 0),
  ('room_202', 'P.202', 3800000, 'Bảo trì', null, null, null, 1050, 62,
   'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=600&auto=format&fit=crop&q=80',
   1, null, null, 0),
  ('room_301', 'P.301', 4500000, 'Trống', null, null, null, 300, 15,
   'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=600&auto=format&fit=crop&q=80',
   1, null, null, 0)
on conflict (ma_phong) do nothing;

-- 2. CƯ DÂN (khớp số người ở của P.101 = 2, P.201 = 3) -----------------------
insert into public.cu_dan
  (ma_cu_dan, ma_phong, ho_ten, so_cccd, so_dien_thoai, ngay_sinh, que_quan, la_dai_dien)
values
  ('mem_seed_101_1', 'room_101', 'Nguyễn Văn An',   '079095001234', '0901234567', '1995-03-12', 'TP. Hồ Chí Minh', true),
  ('mem_seed_101_2', 'room_101', 'Trần Thị Bích',   '079196005678', '0933456789', '1996-07-20', 'Long An',         false),
  ('mem_seed_201_1', 'room_201', 'Lê Thị Hoa',      '052198002468', '0912345678', '1998-11-05', 'Bình Định',       true),
  ('mem_seed_201_2', 'room_201', 'Phạm Minh Tuấn',  '052097003579', '0987654321', '1997-01-30', 'Bình Định',       false),
  ('mem_seed_201_3', 'room_201', 'Võ Thị Mai',      '064099004680', '0977111222', '1999-09-15', 'Gia Lai',         false)
on conflict (ma_cu_dan) do nothing;

-- 3. HÓA ĐƠN (chỉ số mới tháng 10 = chỉ số hiện tại của phòng) --------------
--    tong_tien tự động tính, không cần nhập.
insert into public.hoa_don
  (ma_hoa_don, ma_phong, ten_phong, nguoi_thue, tien_phong,
   dien_cu, dien_moi, gia_dien, nuoc_cu, nuoc_moi, gia_nuoc, phi_dich_vu,
   ngay_lap, trang_thai, ngay_thanh_toan)
values
  -- P.101: tháng 10 đã có hóa đơn lập trong app (26/10) → mẫu là tháng 8, 9
  ('inv_seed_101_2026_08', 'room_101', 'P.101', 'Nguyễn Văn An', 3500000,
   1300, 1360, 3500, 75, 80, 20000, 150000,
   '2026-08-31 09:00', 'Đã thanh toán', '2026-09-03 18:30'),
  ('inv_seed_101_2026_09', 'room_101', 'P.101', 'Nguyễn Văn An', 3500000,
   1360, 1420, 3500, 80, 85, 20000, 150000,
   '2026-09-30 09:00', 'Đã thanh toán', '2026-10-03 19:15'),
  ('inv_seed_201_2026_09', 'room_201', 'P.201', 'Lê Thị Hoa', 4000000,
   2030, 2090, 3500, 100, 105, 20000, 150000,
   '2026-09-30 09:10', 'Đã thanh toán', '2026-10-05 20:00'),
  ('inv_seed_201_2026_10', 'room_201', 'P.201', 'Lê Thị Hoa', 4000000,
   2090, 2150, 3500, 105, 110, 20000, 150000,
   '2026-10-31 09:10', 'Chưa thanh toán', null)
on conflict (ma_hoa_don) do nothing;

-- 4. SỰ CỐ BẢO TRÌ -----------------------------------------------------------
insert into public.su_co_bao_tri
  (ma_su_co, ma_phong, ten_phong, ten_su_co, mo_ta, chi_phi_sua,
   trang_thai, ngay_bao, ngay_hoan_thanh)
values
  ('mnt_seed_202_1', 'room_202', 'P.202', 'Hỏng máy lạnh',
   'Máy lạnh không lạnh, chảy nước. Đã gọi thợ kiểm tra gas.', 800000,
   'Đang sửa', '2026-11-01 08:30', null),
  ('mnt_seed_101_1', 'room_101', 'P.101', 'Rò rỉ vòi nước',
   'Vòi nước nhà tắm rò rỉ, đã thay vòi mới.', 150000,
   'Đã xong', '2026-10-10 07:45', '2026-10-11 16:00'),
  ('mnt_seed_201_1', 'room_201', 'P.201', 'Bóng đèn cháy',
   'Bóng đèn phòng khách bị cháy.', 0,
   'Chờ xử lý', '2026-11-08 21:00', null)
on conflict (ma_su_co) do nothing;
