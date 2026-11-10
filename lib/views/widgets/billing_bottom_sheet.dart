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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _newElecController;
  late TextEditingController _newWaterController;

  int _newElec = 0;
  int _newWater = 0;

  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _newElec = widget.room.oldElectricity;
    _newWater = widget.room.oldWater;

    _newElecController =
        TextEditingController(text: widget.room.oldElectricity.toString());
    _newWaterController =
        TextEditingController(text: widget.room.oldWater.toString());

    _newElecController.addListener(_updateCalculations);
    _newWaterController.addListener(_updateCalculations);
  }

  @override
  void dispose() {
    _newElecController.dispose();
    _newWaterController.dispose();
    super.dispose();
  }

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
    final settings = context.watch<SettingsProvider>();
    final loc = context.loc;

    final elecUnitPrice = settings.elecPrice;
    final waterUnitPrice = settings.waterPrice;
    final serviceFeeUnit = settings.serviceFee;

    final elecUsage = _newElec > widget.room.oldElectricity
        ? _newElec - widget.room.oldElectricity
        : 0;
    final elecTotal = elecUsage * elecUnitPrice;

    final waterUsage = _newWater > widget.room.oldWater
        ? _newWater - widget.room.oldWater
        : 0;
    final waterTotal = waterUsage * waterUnitPrice;

    final grandTotal =
        widget.room.basePrice + elecTotal + waterTotal + serviceFeeUnit;

    void submitInvoice() async {
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
          status: InvoiceStatus.pending,
        );

        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        try {
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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

              // Electricity section
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

              // Water section
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

              // Fee breakdown summary card
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
