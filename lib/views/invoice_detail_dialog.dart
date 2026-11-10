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
    final currency =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final shareText = '''
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
              Navigator.pop(ctx);
              Navigator.pop(context);
              await context.read<RentalProvider>().deleteInvoice(invoice.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.deleteInvoiceSuccess),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(loc.deleteNow, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final currency =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final settings = context.watch<SettingsProvider>();

    final cleanBankCode = settings.bankCode;
    final cleanAccountNo = settings.accountNo;
    final cleanHolder = Uri.encodeComponent(settings.accountHolder);
    final cleanContent =
        Uri.encodeComponent('Phong ${invoice.roomName} Thanhtoan');
    final amountInt = invoice.totalAmount.toInt();

    final vietQrUrl =
        'https://img.vietqr.io/image/$cleanBankCode-$cleanAccountNo-compact2.png?amount=$amountInt&addInfo=$cleanContent&accountName=$cleanHolder';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: Color(0xFF3F51B5)),
              const SizedBox(width: 8),
              Text(loc.invoiceTitle(invoice.roomName)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: invoice.isPaid ? Colors.green.shade100 : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              loc.invoiceStatus(invoice.status),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: invoice.isPaid ? Colors.green.shade900 : Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${loc.tenant}: ${invoice.tenantName}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text('${loc.createdDate}: ${dateFormat.format(invoice.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const Divider(height: 20),

            _buildDetailRow('${loc.roomCharge}:', currency.format(invoice.roomPrice)),
            const SizedBox(height: 6),
            _buildDetailRow(
              '${loc.electricityCharge} (${invoice.oldElec} ➔ ${invoice.newElec} = ${invoice.elecUsage} kWh):',
              currency.format(invoice.elecTotal),
            ),
            const SizedBox(height: 6),
            _buildDetailRow(
              '${loc.waterCharge} (${invoice.oldWater} ➔ ${invoice.newWater} = ${invoice.waterUsage} m³):',
              currency.format(invoice.waterTotal),
            ),
            const SizedBox(height: 6),
            _buildDetailRow('${loc.serviceFee}:', currency.format(invoice.serviceFee)),
            const Divider(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${loc.totalAmount}:',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 16),

            // Real VietQR Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    loc.autoVietQr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F51B5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
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
                          style: const TextStyle(fontSize: 12, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${settings.bankCode} - STK: ${settings.accountNo}\n${settings.accountHolder}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: loc.deleteInvoice,
          onPressed: () => _confirmDeleteInvoice(context),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.close),
        ),
        OutlinedButton.icon(
          onPressed: () => _shareInvoice(context),
          icon: const Icon(Icons.share, size: 16),
          label: Text(loc.share),
        ),
        if (!invoice.isPaid)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              await context
                  .read<RentalProvider>()
                  .markInvoiceAsPaid(invoice.id);
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
            icon: const Icon(Icons.check_circle, size: 16, color: Colors.white),
            label: Text(loc.markAsPaid, style: const TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ),
        Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
