import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:do_an_cuoiky/services/supabase_service.dart';

void main() {
  PostgrestException err(String? code) =>
      PostgrestException(message: 'x', code: code);

  test('Lỗi bị Supabase từ chối hẳn → bỏ qua, không chặn hàng đợi', () {
    expect(SupabaseService.isPermanentError(err('PGRST205')), isTrue); // chưa tạo bảng
    expect(SupabaseService.isPermanentError(err('23514')), isTrue); // sai check
    expect(SupabaseService.isPermanentError(err('22P02')), isTrue); // sai kiểu
    expect(SupabaseService.isPermanentError(err('42703')), isTrue); // thiếu cột
  });

  test('Lỗi tạm thời → giữ lại để gửi lại sau', () {
    expect(SupabaseService.isPermanentError(err(null)), isFalse);
    expect(SupabaseService.isPermanentError(err('503')), isFalse);
    expect(SupabaseService.isPermanentError(err('PGRST000')), isFalse); // mất kết nối DB
  });
}
