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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _lastElecController;
  late TextEditingController _lastWaterController;
  late TextEditingController _damageFeeController;

  int _lastElec = 0;
  int _lastWater = 0;
  double _damageFee = 0.0;

  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _lastElec = widget.room.oldElectricity;
    _lastWater = widget.room.oldWater;

    _lastElecController =
        TextEditingController(text: widget.room.oldElectricity.toString());
    _lastWaterController =
        TextEditingController(text: widget.room.oldWater.toString());
    _damageFeeController = TextEditingController(text: '0');

    _lastElecController.addListener(_recalculate);
    _lastWaterController.addListener(_recalculate);
    _damageFeeController.addListener(_recalculate);
  }

  @override
  void dispose() {
    _lastElecController.dispose();
    _lastWaterController.dispose();
    _damageFeeController.dispose();
    super.dispose();
  }

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
    final settings = context.watch<SettingsProvider>();
    final loc = context.loc;

    final elecUsage =
        _lastElec > widget.room.oldElectricity ? _lastElec - widget.room.oldElectricity : 0;
    final elecTotal = elecUsage * settings.elecPrice;

    final waterUsage =
        _lastWater > widget.room.oldWater ? _lastWater - widget.room.oldWater : 0;
    final waterTotal = waterUsage * settings.waterPrice;

    final totalDeductions = elecTotal + waterTotal + _damageFee;
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

              Text(
                '${loc.tenantRepresentative}: ${widget.room.tenantName ?? loc.unknownTenant}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${loc.tenantDeposit} ${_currencyFormatter.format(widget.room.depositAmount)}',
                style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Final Meter Inputs
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

              // Settlement Summary Card
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

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final provider = context.read<RentalProvider>();
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
                  try {
                    await provider.checkoutRoom(
                      widget.room.id,
                      _lastElec,
                      _lastWater,
                    );
                  } catch (_) {
                    return; // Đã được chặn bởi validator / kiểm tra ở trên
                  }
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
