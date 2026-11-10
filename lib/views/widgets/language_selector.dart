import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';

class LanguageOption {
  final String code;
  final String name;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
  });
}

const List<LanguageOption> appLanguages = [
  LanguageOption(code: 'vi', name: 'Tiếng Việt', flag: '🇻🇳'),
  LanguageOption(code: 'en', name: 'English', flag: '🇺🇸'),
  LanguageOption(code: 'zh', name: '中文', flag: '🇨🇳'),
];

void showLanguageSelectorDialog(BuildContext context) {
  final currentCode = context.read<SettingsProvider>().languageCode;

  showDialog(
    context: context,
    builder: (ctx) {
      final loc = ctx.loc;
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.language, color: Color(0xFF3F51B5)),
            const SizedBox(width: 10),
            Text(loc.language),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: appLanguages.map((lang) {
            final isSelected = lang.code == currentCode;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3F51B5).withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3F51B5)
                      : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                leading: Text(
                  lang.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  lang.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF3F51B5) : null,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF3F51B5))
                    : null,
                onTap: () {
                  context.read<SettingsProvider>().setLocale(lang.code);
                  Navigator.pop(ctx);
                },
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.close),
          ),
        ],
      );
    },
  );
}

class LanguagePickerActionItem extends StatelessWidget {
  const LanguagePickerActionItem({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final currentLang = appLanguages.firstWhere(
      (l) => l.code == settings.languageCode,
      orElse: () => appLanguages.first,
    );

    return InkWell(
      onTap: () => showLanguageSelectorDialog(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentLang.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              currentLang.code.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F51B5),
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF3F51B5)),
          ],
        ),
      ),
    );
  }
}

class LanguageSegmentedBar extends StatelessWidget {
  const LanguageSegmentedBar({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: appLanguages.map((lang) {
          final isSelected = lang.code == settings.languageCode;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: () => context.read<SettingsProvider>().setLocale(lang.code),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3F51B5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lang.flag, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      lang.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ThemeToggleActionItem extends StatelessWidget {
  final Color? color;
  const ThemeToggleActionItem({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return IconButton(
      tooltip: isDark ? 'Light Mode' : 'Dark Mode',
      icon: Icon(
        isDark ? Icons.light_mode : Icons.dark_mode_outlined,
        color: color ?? (isDark ? Colors.amber : Colors.white),
      ),
      onPressed: () {
        context.read<SettingsProvider>().toggleTheme();
      },
    );
  }
}
