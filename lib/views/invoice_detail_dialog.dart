/// ============================================================================
/// FILE: views/invoice_detail_dialog.dart
/// HỘP THOẠI: Xem Chi Tiết Hóa Đơn, Mã VietQR & Đã Thanh Toán (InvoiceDetailDialog)
/// CHỨC NĂNG:
/// - Thiết kế giao diện khung hóa đơn hiện đại (trắng xám tinh tế, không màu vàng).
/// - Tự động tạo ảnh mã QR chuyển khoản VietQR chuẩn ngân hàng.
/// - Nút "Đã thanh toán" chuyển trạng thái PENDING ➔ PAID.
/// - Nút "Chia sẻ Zalo" gửi văn bản hóa đơn qua Zalo/Messenger (`share_plus`).
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../models/invoice_model.dart';
import '../providers/rental_provider.dart';
import '../providers/settings_provider.dart';

class InvoiceDetailDialog extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailDialog({super.key, required this.invoice});

  void _shareInvoice(BuildContext context) {
    final loc = context.loc;
    final currency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final shareText =
        '''
🧾 ${loc.invoiceNotice(invoice.roomName.toUpperCase())}
👤 ${loc.tenant}: ${invoice.tenantName}
📅 ${loc.createdDate}: ${dateFormat.format(invoice.createdAt)}

--------------------------------
🏠 ${loc.roomCharge}: ${currency.format(invoice.roomPrice)}
⚡ ${loc.electricityCharge} (${invoice.oldElec} ➔ ${invoice.newElec} = ${invoice.elecUsage} kWh): ${currency.format(invoice.elecTotal)}
💧 ${loc.waterCharge} (${invoice.oldWater} ➔ ${invoice.newWater} = ${invoice.waterUsage} m³): ${currency.format(invoice.waterTotal)}
📡 ${loc.serviceFee} (${loc.wifiTrash}): ${currency.format(invoice.serviceFee)}
--------------------------------
💰 ${loc.totalDue}: ${currency.format(invoice.totalAmount)}
📌 ${loc.invoiceStatus(invoice.status)}

${loc.thankYou}
''';

    Share.share(shareText, subject: loc.invoiceShareSubject(invoice.roomName));
  }

  void _confirmDeleteInvoice(BuildContext context) {
    final loc = context.loc;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.red),
            const SizedBox(width: 8),
            Text(loc.deleteInvoiceConfirmTitle),
          ],
        ),
        content: Text(loc.deleteInvoiceConfirmMsg(invoice.roomName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Lấy provider & messenger TRƯỚC khi đóng dialog, vì sau khi
              // pop thì context của dialog không còn dùng được nữa.
              final provider = context.read<RentalProvider>();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              Navigator.pop(context);
              await provider.deleteInvoice(invoice.id);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(loc.deleteInvoiceSuccess),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              loc.deleteNow,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final currency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final settings = context.watch<SettingsProvider>();

    final cleanBankCode = settings.bankCode;
    final cleanAccountNo = settings.accountNo;
    final cleanHolder = Uri.encodeComponent(settings.accountHolder);
    final cleanContent = Uri.encodeComponent(
      'Phong ${invoice.roomName} Thanhtoan',
    );
    final amountInt = invoice.totalAmount.toInt();

    final vietQrUrl =
        'https://img.vietqr.io/image/$cleanBankCode-$cleanAccountNo-compact2.png?amount=$amountInt&addInfo=$cleanContent&accountName=$cleanHolder';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: Icon, Room Title & Status Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F51B5).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: Color(0xFF3F51B5),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          loc.invoiceTitle(invoice.roomName),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F51B5),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: invoice.isPaid
                        ? Colors.green.shade50
                        : const Color(0xFFE8EAF6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: invoice.isPaid
                          ? Colors.green.shade300
                          : const Color(0xFFC5CAE9),
                    ),
                  ),
                  child: Text(
                    loc.invoiceStatus(invoice.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: invoice.isPaid
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF3F51B5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tenant & Creation Date Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${loc.tenant}: ${invoice.tenantName}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${loc.createdDate}: ${dateFormat.format(invoice.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Invoice Breakdown Clean Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    '${loc.roomCharge}:',
                    currency.format(invoice.roomPrice),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    '${loc.electricityCharge} (${invoice.oldElec} ➔ ${invoice.newElec} = ${invoice.elecUsage} kWh):',
                    currency.format(invoice.elecTotal),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    '${loc.waterCharge} (${invoice.oldWater} ➔ ${invoice.newWater} = ${invoice.waterUsage} m³):',
                    currency.format(invoice.waterTotal),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    '${loc.serviceFee}:',
                    currency.format(invoice.serviceFee),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${loc.totalAmount}:',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currency.format(invoice.totalAmount),
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
            const SizedBox(height: 14),

            // Clean VietQR Card Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC5CAE9)),
              ),
              child: Column(
                children: [
                  Text(
                    loc.autoVietQr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F51B5),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      vietQrUrl,
                      height: 180,
                      fit: BoxFit.contain,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          height: 180,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (ctx, err, stack) => Container(
                        height: 100,
                        alignment: Alignment.center,
                        child: Text(
                          loc.cannotLoadQr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${settings.bankCode} - STK: ${settings.accountNo}\n${settings.accountHolder}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Action Buttons Row
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: loc.deleteInvoice,
                  onPressed: () => _confirmDeleteInvoice(context),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.close),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: () => _shareInvoice(context),
                  icon: const Icon(Icons.share, size: 16),
                  label: Text(loc.share),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3F51B5),
                    side: const BorderSide(color: Color(0xFF3F51B5)),
                  ),
                ),
              ],
            ),
            // Nút "Đã thanh toán" nằm riêng 1 hàng, rộng hết khung
            // (để chung hàng với các nút khác bị tràn màn hình)
            if (!invoice.isPaid) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await context.read<RentalProvider>().markInvoiceAsPaid(
                      invoice.id,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.paidRecorded),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    loc.markAsPaid,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 13))),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
