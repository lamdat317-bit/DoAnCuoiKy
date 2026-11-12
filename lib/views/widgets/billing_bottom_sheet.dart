/// ============================================================================
/// FILE: views/widgets/billing_bottom_sheet.dart
/// HOẠT ĐỘNG UI: BOTTOMSHEET CHỐT TIỀN ĐIỆN NƯỚC (BillingBottomSheet)
/// ----------------------------------------------------------------------------
/// LUỒNG CHẠY CHI TIẾT CỦA CODE:
/// 1. Đọc đơn giá điện, nước, dịch vụ cài đặt từ `SettingsProvider`.
/// 2. Lấy chỉ số điện cũ và nước cũ trong thông tin phòng (`widget.room.oldElectricity`, `widget.room.oldWater`).
/// 3. Cho người dùng nhập chỉ số điện mới và nước mới.
/// 4. Tự động tính toán real-time tiêu thụ:
///    • Điện = (Điện mới - Điện cũ) * Đơn giá điện
///    • Nước = (Nước mới - Nước cũ) * Đơn giá nước
///    • Tổng tiền = Tiền phòng + Tiền điện + Tiền nước + Phí dịch vụ
/// 5. Bấm nút "Xác Nhận & Tạo Hóa Đơn":
///    • Tạo một `Invoice` mới ở trạng thái `PENDING` (Chưa thu).
///    • Cập nhật chỉ số điện/nước mới cho phòng trong SQLite CSDL.
///    • Thêm hóa đơn vào danh sách `_invoices` và phát tín hiệu `notifyListeners()`.
///    • Dashboard tự động cộng tiền vào TỔNG CÔNG NỢ CHƯA THU!
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/invoice_model.dart';
import '../../models/room_model.dart';
import '../../providers/rental_provider.dart';
import '../../providers/settings_provider.dart';

class BillingBottomSheet extends StatefulWidget {
  final Room room;

  const BillingBottomSheet({super.key, required this.room});

  @override
  State<BillingBottomSheet> createState() => _BillingBottomSheetState();
}

class _BillingBottomSheetState extends State<BillingBottomSheet> {
  // Key quản lý và kiểm tra Form nhập
  final _formKey = GlobalKey<FormState>();

  // Bộ điều khiển ô nhập chỉ số điện mới và nước mới
  late TextEditingController _newElecController;
  late TextEditingController _newWaterController;

  // Biến lưu giá trị chỉ số điện mới và nước mới
  int _newElec = 0;
  int _newWater = 0;

  // Định dạng tiền tệ VNĐ (đ)
  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị ban đầu bằng chỉ số điện nước cũ
    _newElec = widget.room.oldElectricity;
    _newWater = widget.room.oldWater;

    _newElecController =
        TextEditingController(text: widget.room.oldElectricity.toString());
    _newWaterController =
        TextEditingController(text: widget.room.oldWater.toString());

    // Đăng ký hàm tự động tính toán lại khi người dùng gõ số mới
    _newElecController.addListener(_updateCalculations);
    _newWaterController.addListener(_updateCalculations);
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ của Controller khi đóng BottomSheet
    _newElecController.dispose();
    _newWaterController.dispose();
    super.dispose();
  }

  /// [HÀM TÍNH TOÁN]: Cập nhật lại các con số tiêu thụ real-time khi gõ ô nhập
  void _updateCalculations() {
    setState(() {
      _newElec = int.tryParse(_newElecController.text.trim()) ??
          widget.room.oldElectricity;
      _newWater = int.tryParse(_newWaterController.text.trim()) ??
          widget.room.oldWater;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Đọc cài đặt đơn giá điện, nước, dịch vụ từ SettingsProvider
    final settings = context.watch<SettingsProvider>();
    final loc = context.loc;

    final elecUnitPrice = settings.elecPrice;
    final waterUnitPrice = settings.waterPrice;
    final serviceFeeUnit = settings.serviceFee;

    // 2. PHÉP TÍNH 1: Điện tiêu thụ = Số mới - Số cũ -> Thành tiền điện
    final elecUsage = _newElec > widget.room.oldElectricity
        ? _newElec - widget.room.oldElectricity
        : 0;
    final elecTotal = elecUsage * elecUnitPrice;

    // 3. PHÉP TÍNH 2: Nước tiêu thụ = Số mới - Số cũ -> Thành tiền nước
    final waterUsage = _newWater > widget.room.oldWater
        ? _newWater - widget.room.oldWater
        : 0;
    final waterTotal = waterUsage * waterUnitPrice;

    // 4. PHÉP TÍNH 3: Tổng cộng cần thu = Giá phòng + Điện + Nước + Phí dịch vụ
    final grandTotal =
        widget.room.basePrice + elecTotal + waterTotal + serviceFeeUnit;

    /// [HÀM XỬ LÝ]: Bấm nút Xác nhận & Tạo Hóa đơn
    void submitInvoice() async {
      // Kiểm tra hợp lệ: Chỉ số mới không được bé hơn chỉ số cũ
      if (_formKey.currentState!.validate()) {
        final invoice = Invoice(
          id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
          roomId: widget.room.id,
          roomName: widget.room.name,
          tenantName: widget.room.tenantName ?? loc.unknownTenant,
          roomPrice: widget.room.basePrice,
          oldElec: widget.room.oldElectricity,
          newElec: _newElec,
          elecPrice: elecUnitPrice,
          oldWater: widget.room.oldWater,
          newWater: _newWater,
          waterPrice: waterUnitPrice,
          serviceFee: serviceFeeUnit,
          createdAt: DateTime.now(),
          status: InvoiceStatus.pending, // Mặc định là CHƯA THANH TOÁN (PENDING)
        );

        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        try {
          // Lưu hóa đơn vào SQLite CSDL & đổi chỉ số điện/nước cũ cho phòng
          await context.read<RentalProvider>().createInvoiceAndRecord(invoice);
        } on InvoiceException catch (e) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(e.error == InvoiceError.alreadyBilledThisMonth
                  ? loc.alreadyBilledThisMonth(widget.room.name)
                  : loc.newIndexCannotBeLess),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        // Đóng BottomSheet & Hiện thông báo tạo hóa đơn thành công
        if (context.mounted) {
          navigator.pop();

          messenger.showSnackBar(
            SnackBar(
              content: Text(
                '${loc.invoiceCreatedSuccess(widget.room.name)} (${loc.totalDue}: ${_currencyFormatter.format(invoice.totalAmount)})',
              ),
              backgroundColor: Colors.orange.shade900,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER 1: Thanh kéo và Tiêu đề chốt điện nước
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.billingForRoom(widget.room.name),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F51B5),
                        ),
                      ),
                      if (widget.room.tenantName != null)
                        Text(
                          '${loc.tenant}: ${widget.room.tenantName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // KHUNG NHẬP 1: Ô nhập chỉ số Điện mới
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flash_on, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${loc.electricityCharge.toUpperCase()} (${loc.oldIndex}: ${widget.room.oldElectricity} kWh - ${loc.unitPrice}: ${_currencyFormatter.format(elecUnitPrice)}/kWh)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _newElecController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${loc.newIndex} (${loc.electricityCharge})',
                        hintText: 'kWh',
                        suffixText: 'kWh',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc.requiredField;
                        }
                        final val = int.tryParse(value.trim());
                        if (val == null) {
                          return loc.invalidNumber;
                        }
                        if (val < widget.room.oldElectricity) {
                          return loc.newIndexCannotBeLess;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${loc.consumption}: $elecUsage kWh  ➔  ${loc.totalAmount}: ${_currencyFormatter.format(elecTotal)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // KHUNG NHẬP 2: Ô nhập chỉ số Nước mới
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${loc.waterCharge.toUpperCase()} (${loc.oldIndex}: ${widget.room.oldWater} m³ - ${loc.unitPrice}: ${_currencyFormatter.format(waterUnitPrice)}/m³)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _newWaterController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${loc.newIndex} (${loc.waterCharge})',
                        hintText: 'm³',
                        suffixText: 'm³',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc.requiredField;
                        }
                        final val = int.tryParse(value.trim());
                        if (val == null) {
                          return loc.invalidNumber;
                        }
                        if (val < widget.room.oldWater) {
                          return loc.newIndexCannotBeLess;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${loc.consumption}: $waterUsage m³  ➔  ${loc.totalAmount}: ${_currencyFormatter.format(waterTotal)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // BẢNG TÓM TẮT 3: Chi tiết các khoản chi phí hóa đơn
              Container(
                padding: const EdgeInsets.all(14),
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
                        Text('${loc.roomCharge}:'),
                        Text(
                          _currencyFormatter.format(widget.room.basePrice),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${loc.electricityCharge}:'),
                        Text(
                          _currencyFormatter.format(elecTotal),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${loc.waterCharge}:'),
                        Text(
                          _currencyFormatter.format(waterTotal),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${loc.serviceFee} (${loc.wifiTrash}):'),
                        Text(
                          _currencyFormatter.format(serviceFeeUnit),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${loc.totalDue}:',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _currencyFormatter.format(grandTotal),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F51B5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // NÚT BẤM 4: Nút "Xác Nhận & Tạo Hóa Đơn"
              ElevatedButton.icon(
                onPressed: submitInvoice,
                icon: const Icon(Icons.receipt_long),
                label: Text(loc.createInvoiceBtn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
