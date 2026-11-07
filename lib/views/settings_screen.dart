import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'widgets/language_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _elecController;
  late TextEditingController _waterController;
  late TextEditingController _serviceController;
  late TextEditingController _bankCodeController;
  late TextEditingController _accountNoController;
  late TextEditingController _holderController;

  final Map<String, String> _popularBanks = {
    'MB': 'MBBank (Quân Đội)',
    'VCB': 'Vietcombank',
    'TCB': 'Techcombank',
    'ACB': 'ACB (Á Châu)',
    'ICB': 'VietinBank',
    'BIDV': 'BIDV',
    'VPB': 'VPBank',
    'TPB': 'TPBank',
  };

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _elecController =
        TextEditingController(text: settings.elecPrice.toStringAsFixed(0));
    _waterController =
        TextEditingController(text: settings.waterPrice.toStringAsFixed(0));
    _serviceController =
        TextEditingController(text: settings.serviceFee.toStringAsFixed(0));
    _bankCodeController = TextEditingController(text: settings.bankCode);
    _accountNoController = TextEditingController(text: settings.accountNo);
    _holderController = TextEditingController(text: settings.accountHolder);
  }

  @override
  void dispose() {
    _elecController.dispose();
    _waterController.dispose();
    _serviceController.dispose();
    _bankCodeController.dispose();
    _accountNoController.dispose();
    _holderController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final elec = double.parse(_elecController.text.trim());
      final water = double.parse(_waterController.text.trim());
      final service = double.parse(_serviceController.text.trim());
      final bank = _bankCodeController.text.trim();
      final account = _accountNoController.text.trim();
      final holder = _holderController.text.trim();

      context.read<SettingsProvider>().updateSettings(
            elecPrice: elec,
            waterPrice: water,
            serviceFee: service,
            bankCode: bank,
            accountNo: account,
            accountHolder: holder,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc.settingsSavedSuccess),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Selector Section
              Text(
                loc.languageSectionTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F51B5),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: appLanguages.map((lang) {
                    final isSelected = lang.code == settings.languageCode;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3F51B5).withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3F51B5)
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade200),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Text(
                          lang.flag,
                          style: const TextStyle(fontSize: 22),
                        ),
                        title: Text(
                          lang.name,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF3F51B5)
                                : null,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Color(0xFF3F51B5), size: 20)
                            : null,
                        onTap: () {
                          context.read<SettingsProvider>().setLocale(lang.code);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Theme Selector Section
              Text(
                loc.themeSectionTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F51B5),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            context.read<SettingsProvider>().setDarkMode(false),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !settings.isDarkMode
                                ? const Color(0xFF3F51B5).withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: !settings.isDarkMode
                                  ? const Color(0xFF3F51B5)
                                  : Colors.grey.shade400,
                              width: !settings.isDarkMode ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.light_mode,
                                  color: Colors.amber, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                loc.themeLight,
                                style: TextStyle(
                                  fontWeight: !settings.isDarkMode
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            context.read<SettingsProvider>().setDarkMode(true),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: settings.isDarkMode
                                ? const Color(0xFF3F51B5).withValues(alpha: 0.25)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: settings.isDarkMode
                                  ? const Color(0xFF7986CB)
                                  : Colors.grey.shade400,
                              width: settings.isDarkMode ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.dark_mode,
                                  color: Colors.blueAccent, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                loc.themeDark,
                                style: TextStyle(
                                  fontWeight: settings.isDarkMode
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Unit Price Card
              Text(
                loc.feeSectionTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F51B5),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _elecController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.elecPriceLabel,
                  suffixText: 'đ/kWh',
                  prefixIcon: const Icon(Icons.flash_on, color: Colors.amber),
                ),
                validator: (val) {
                  if (val == null || double.tryParse(val.trim()) == null) {
                    return loc.invalidNumber;
                  }
                  if (double.parse(val.trim()) < 0) {
                    return loc.mustBePositive;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _waterController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.waterPriceLabel,
                  suffixText: 'đ/m³',
                  prefixIcon: const Icon(Icons.water_drop, color: Colors.blue),
                ),
                validator: (val) {
                  if (val == null || double.tryParse(val.trim()) == null) {
                    return loc.invalidNumber;
                  }
                  if (double.parse(val.trim()) < 0) {
                    return loc.mustBePositive;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _serviceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.serviceFeeLabel,
                  suffixText: 'đ/${loc.month}',
                  prefixIcon:
                      const Icon(Icons.cleaning_services, color: Colors.teal),
                ),
                validator: (val) {
                  if (val == null || double.tryParse(val.trim()) == null) {
                    return loc.invalidNumber;
                  }
                  if (double.parse(val.trim()) < 0) {
                    return loc.mustBePositive;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Bank Details Card for VietQR
              Text(
                loc.vietqrSectionTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F51B5),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _popularBanks.containsKey(_bankCodeController.text)
                    ? _bankCodeController.text
                    : 'MB',
                decoration: InputDecoration(
                  labelText: loc.bankCodeLabel,
                  prefixIcon: const Icon(Icons.account_balance,
                      color: Color(0xFF3F51B5)),
                ),
                items: _popularBanks.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text('${entry.key} - ${entry.value}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _bankCodeController.text = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accountNoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.accountNoLabel,
                  hintText: '0901234567',
                  prefixIcon: const Icon(Icons.credit_card),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return loc.requiredField;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _holderController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: loc.accountHolderLabel,
                  hintText: 'NGUYEN VAN A',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return loc.requiredField;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: Text(
                  loc.saveSettingsBtn,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
