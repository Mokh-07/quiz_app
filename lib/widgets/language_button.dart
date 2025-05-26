import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../services/haptic_service.dart';
import '../services/settings_service.dart';
import '../l10n/app_localizations.dart';

/// Bouton de changement de langue partagé
class LanguageButton extends StatelessWidget {
  final bool showLabel;
  final double? iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;

  const LanguageButton({
    super.key,
    this.showLabel = false,
    this.iconSize,
    this.iconColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        if (showLabel) {
          return _buildButtonWithLabel(context, localizationService);
        } else {
          return _buildIconButton(context, localizationService);
        }
      },
    );
  }

  Widget _buildIconButton(BuildContext context, LocalizationService localizationService) {
    return IconButton(
      icon: Text(
        localizationService.getCurrentLanguageFlag(),
        style: TextStyle(fontSize: iconSize ?? 24),
      ),
      onPressed: () => _showLanguageDialog(context, localizationService),
      tooltip: AppLocalizations.of(context).changeLanguage,
      padding: padding ?? const EdgeInsets.all(8),
    );
  }

  Widget _buildButtonWithLabel(BuildContext context, LocalizationService localizationService) {
    return TextButton.icon(
      onPressed: () => _showLanguageDialog(context, localizationService),
      icon: Text(
        localizationService.getCurrentLanguageFlag(),
        style: const TextStyle(fontSize: 20),
      ),
      label: Text(
        localizationService.getCurrentLanguageName(),
        style: TextStyle(
          color: iconColor ?? Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LocalizationService localizationService) async {
    final settings = Provider.of<SettingsService>(context, listen: false);
    
    // Feedback haptique
    await HapticService().selectionVibration(
      enabled: settings.vibrationEnabled,
    );

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.language),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).changeLanguage),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocalizationService.supportedLocales.map((locale) {
            final localeString = '${locale.languageCode}_${locale.countryCode}';
            final isSelected = localizationService.currentLocaleString == localeString;
            
            return ListTile(
              leading: Text(
                LocalizationService.languageFlags[localeString] ?? '🌍',
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                LocalizationService.languageNames[localeString] ?? 'Unknown',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
              trailing: isSelected 
                ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                : null,
              onTap: () async {
                if (!isSelected) {
                  await localizationService.setLocale(locale);
                  
                  // Feedback haptique
                  await HapticService().successVibration(
                    enabled: settings.vibrationEnabled,
                  );
                }
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).close),
          ),
        ],
      ),
    );
  }
}

/// Version compacte du bouton de langue pour les AppBars
class CompactLanguageButton extends StatelessWidget {
  const CompactLanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const LanguageButton(
      showLabel: false,
      iconSize: 20,
    );
  }
}

/// Version avec label pour les paramètres
class LabeledLanguageButton extends StatelessWidget {
  const LabeledLanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const LanguageButton(
      showLabel: true,
    );
  }
}
