import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/invoice_model.dart';
import '../providers/rental_provider.dart';
import 'invoice_detail_dialog.dart';

class InvoiceListTab extends StatefulWidget {
  const InvoiceListTab({super.key});

  @override
  State<InvoiceListTab> createState() => _InvoiceListTabState();
}

class _InvoiceListTabState extends State<InvoiceListTab> {
  InvoiceStatus? _filterStatus;

  void _showInvoiceDetailDialog(BuildContext context, Invoice inv) {
    showDialog(
      context: context,
      builder: (ctx) => InvoiceDetailDialog(invoice: inv),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentalProvider>();
    final allInvoices = provider.invoices;
    final loc = context.loc;

    final filteredInvoices = allInvoices.where((inv) {
      if (_filterStatus != null && inv.status != _filterStatus) {
        return false;
      }
      return true;
    }).toList();

    final currency =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                FilterChip(
                  label: Text('${loc.filterAll} (${allInvoices.length})'),
                  selected: _filterStatus == null,
                  onSelected: (selected) {
                    setState(() {
                      _filterStatus = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text('${loc.unpaidCount} (${provider.unpaidInvoicesCount})'),
                  selected: _filterStatus == InvoiceStatus.pending,
                  selectedColor: Colors.orange.shade100,
                  checkmarkColor: Colors.orange.shade900,
                  onSelected: (selected) {
                    setState(() {
                      _filterStatus = selected ? InvoiceStatus.pending : null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(
                      '${loc.paidCount} (${allInvoices.length - provider.unpaidInvoicesCount})'),
                  selected: _filterStatus == InvoiceStatus.paid,
                  selectedColor: Colors.green.shade100,
                  checkmarkColor: Colors.green.shade900,
                  onSelected: (selected) {
                    setState(() {
                      _filterStatus = selected ? InvoiceStatus.paid : null;
                    });
                  },
                ),
              ],
            ),
          ),

          // Invoice list
          Expanded(
            child: filteredInvoices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          loc.noInvoices,
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredInvoices.length,
                    itemBuilder: (context, index) {
                      final inv = filteredInvoices[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: inv.isPaid
                                ? Colors.green
                                : Colors.orange.shade800,
                            child: Icon(
                              inv.isPaid
                                  ? Icons.check
                                  : Icons.access_time_filled,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            '${inv.roomName} - ${loc.tenant}: ${inv.tenantName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              '${loc.createdDate}: ${dateFormat.format(inv.createdAt)}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                currency.format(inv.totalAmount),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: inv.isPaid
                                      ? Colors.green
                                      : Colors.orange.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: inv.isPaid
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  loc.invoiceStatus(inv.status),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: inv.isPaid
                                        ? Colors.green.shade900
                                        : Colors.orange.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showInvoiceDetailDialog(context, inv),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
