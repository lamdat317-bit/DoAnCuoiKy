/// ============================================================================
/// FILE: views/widgets/checkout_dialog.dart
/// HỘP THOẠI UI: TRẢ PHÒNG & QUYẾT TOÁN TIỀN CỌC (CheckoutDialog)
/// ----------------------------------------------------------------------------
/// NGHỆP VỤ XỬ LÝ TRONG HỘP THOẠI NÀY:
/// 1. Nhập chỉ số Điện & Nước ngày cuối cùng trước khi trả phòng.
/// 2. Nhập chi phí khấu trừ đền bù hư hỏng thiết bị hoặc phí vệ sinh (nếu có).
/// 3. Tự động tính toán số tiền hoàn cọc cho khách:
///    [Tiền Cọc Hoàn Trả] = [Tiền Cọc Giữ Chỗ] - [Tiền Điện Cuối] - [Tiền Nước Cuối] - [Phí Hư Hỏng]
/// 4. Kiểm tra phòng còn hóa đơn CHƯA THANH TOÁN (PENDING) không, nếu còn sẽ chặn không cho trả phòng.
/// 5. Bấm "XÁC NHẬN TRẢ PHÒNG" -> Chuyển trạng thái phòng về TRỐNG (Available) & Xóa dữ liệu khách.
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/room_model.dart';
import '../../providers/rental_provider.dart';
import '../../providers/settings_provider.dart';

class CheckoutDialog extends StatefulWidget {
  final Room room;

  const CheckoutDialog({super.key, required this.room});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  // Key để quản lý và kiểm tra dữ liệu Form nhập
  final _formKey = GlobalKey<FormState>();

  // Bộ điều khiển nhập văn bản (TextEditingController) cho Điện, Nước và Phí đền bù
  late TextEditingController _lastElecController;
  late TextEditingController _lastWaterController;
  late TextEditingController _damageFeeController;

  // Biến lưu giá trị số sau khi chuyển đổi
  int _lastElec = 0;
  int _lastWater = 0;
  double _damageFee = 0.0;

  // Định dạng hiển thị tiền tệ VNĐ (Ví dụ: 3.500.000 đ)
  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Gán giá trị chỉ số điện nước cũ ban đầu vào các ô nhập
    _lastElec = widget.room.oldElectricity;
    _lastWater = widget.room.oldWater;

    _lastElecController =
        TextEditingController(text: widget.room.oldElectricity.toString());
    _lastWaterController =
        TextEditingController(text: widget.room.oldWater.toString());
    _damageFeeController = TextEditingController(text: '0');

    // Đăng ký hàm tự động tính toán lại khi người dùng thay đổi con số trong ô nhập
    _lastElecController.addListener(_recalculate);
    _lastWaterController.addListener(_recalculate);
    _damageFeeController.addListener(_recalculate);
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ của các Controller khi đóng Hộp thoại
    _lastElecController.dispose();
    _lastWaterController.dispose();
    _damageFeeController.dispose();
    super.dispose();
  }

  /// [HÀM TÍNH TOÁN]: Tự động cập nhật lại các chỉ số và tính toán số tiền cọc hoàn trả
  void _recalculate() {
    setState(() {
      _lastElec =
          int.tryParse(_lastElecController.text.trim()) ?? widget.room.oldElectricity;
      _lastWater =
          int.tryParse(_lastWaterController.text.trim()) ?? widget.room.oldWater;
      _damageFee = double.tryParse(_damageFeeController.text.trim()) ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Đọc cài đặt đơn giá điện nước và bộ ngôn ngữ
    final settings = context.watch<SettingsProvider>();
    final loc = context.loc;

    // PHÉP TÍNH 1: Tính số kWh điện tiêu thụ ngày cuối và thành tiền điện
    final elecUsage =
        _lastElec > widget.room.oldElectricity ? _lastElec - widget.room.oldElectricity : 0;
    final elecTotal = elecUsage * settings.elecPrice;

    // PHÉP TÍNH 2: Tính số m³ nước tiêu thụ ngày cuối và thành tiền nước
    final waterUsage =
        _lastWater > widget.room.oldWater ? _lastWater - widget.room.oldWater : 0;
    final waterTotal = waterUsage * settings.waterPrice;

    // PHÉP TÍNH 3: Tính tổng số tiền bị khấu trừ (Điện + Nước + Đền bù hư hỏng)
    final totalDeductions = elecTotal + waterTotal + _damageFee;

    // PHÉP TÍNH 4: Tính số tiền cọc còn lại phải hoàn trả cho khách (Tiền Cọc - Tổng Khấu Trừ)
    final refundAmount = widget.room.depositAmount - totalDeductions;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER 1: Tiêu đề Hộp thoại Trả phòng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_busy, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        loc.checkoutRoomTitle(widget.room.name),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),

              // HEADER 2: Thông tin Tên đại diện thuê & Tiền cọc ban đầu
              Text(
                '${loc.tenantRepresentative}: ${widget.room.tenantName ?? loc.unknownTenant}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${loc.tenantDeposit} ${_currencyFormatter.format(widget.room.depositAmount)}',
                style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // KHUNG NHẬP 1: Chỉ số Điện & Nước chốt ngày cuối
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lastElecController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.finalElectricity,
                        suffixText: 'kWh',
                      ),
                      validator: (value) {
                        final val = int.tryParse(value?.trim() ?? '');
                        if (val == null) return loc.invalidNumber;
                        if (val < widget.room.oldElectricity) return loc.newIndexCannotBeLess;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _lastWaterController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.finalWater,
                        suffixText: 'm³',
                      ),
                      validator: (value) {
                        final val = int.tryParse(value?.trim() ?? '');
                        if (val == null) return loc.invalidNumber;
                        if (val < widget.room.oldWater) return loc.newIndexCannotBeLess;
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // KHUNG NHẬP 2: Chi phí đền bù hư hỏng thiết bị (nếu có)
              TextFormField(
                controller: _damageFeeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.damageFeeLabel,
                  hintText: loc.damageFeeHint,
                  prefixIcon: const Icon(Icons.build_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // BẢNG BÁO CÁO 3: Chi tiết tổng hợp Quyết toán Cọc
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${loc.finalElecCost} ($elecUsage kWh):'),
                        Text(_currencyFormatter.format(elecTotal)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${loc.finalWaterCost} ($waterUsage m³):'),
                        Text(_currencyFormatter.format(waterTotal)),
                      ],
                    ),
                    if (_damageFee > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${loc.finalDamageCost}:'),
                          Text(_currencyFormatter.format(_damageFee),
                              style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ],
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          refundAmount >= 0 ? loc.refundToTenant : loc.tenantMustPayMore,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _currencyFormatter.format(refundAmount.abs()),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: refundAmount >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // NÚT THAO TÁC 4: Xác Nhận Trả Phòng & Lưu CSDL
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  // 1. Kiểm tra tính hợp lệ của dữ liệu nhập
                  if (!_formKey.currentState!.validate()) return;
                  final provider = context.read<RentalProvider>();

                  // 2. BẢO VỆ NGHIỆP VỤ: Kiểm tra phòng có còn hóa đơn CHƯA THU (PENDING) không
                  final unpaid = provider.unpaidInvoicesOfRoom(widget.room.id);
                  if (unpaid.isNotEmpty) {
                    final debt = unpaid.fold(
                        0.0, (sum, inv) => sum + inv.totalAmount);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.t('checkout_unpaid_block', {
                          'room': widget.room.name,
                          'count': '${unpaid.length}',
                          'amount': _currencyFormatter.format(debt),
                        })),
                        backgroundColor: Colors.orange.shade900,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                    return;
                  }

                  // 3. Thực thi Trả phòng: Đổi trạng thái phòng thành TRỐNG (Available) & Xóa khách
                  try {
                    await provider.checkoutRoom(
                      widget.room.id,
                      _lastElec,
                      _lastWater,
                    );
                  } catch (_) {
                    return;
                  }

                  // 4. Đóng Hộp thoại & Hiển thị thông báo thành công
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          loc.checkoutSuccessMsg(widget.room.name),
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text(
                  loc.confirmCheckoutBtn.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
