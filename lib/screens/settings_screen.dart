import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

import '../services/haptic_service.dart';
import '../utils/constants.dart';
import '../widgets/app_card.dart';
import '../widgets/audio_test_widget.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres'), centerTitle: true),
      body: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Apparence
                _buildSectionTitle(context, 'Apparence'),
                const SizedBox(height: AppSizes.paddingMedium),
                _buildThemeCard(context, settings),

                const SizedBox(height: AppSizes.paddingLarge),

                // Section Vibrations
                _buildSectionTitle(context, 'Vibrations'),
                const SizedBox(height: AppSizes.paddingMedium),
                _buildVibrationCard(context, settings),

                const SizedBox(height: AppSizes.paddingLarge),

                // Section Actions
                _buildSectionTitle(context, 'Actions'),
                const SizedBox(height: AppSizes.paddingMedium),
                _buildActionsCard(context, settings),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, SettingsService settings) {
    return AppCard(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Mode d\'affichage'),
            subtitle: Text(settings.themeModeDescription),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Système'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Clair')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Sombre')),
              ],
              onChanged: (ThemeMode? mode) {
                if (mode != null) {
                  settings.setThemeMode(mode);
                  // Feedback haptique
                  HapticService().selectionVibration(
                    enabled: settings.vibrationEnabled,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibrationCard(BuildContext context, SettingsService settings) {
    return AppCard(
      child: Column(
        children: [
          SwitchListTile(
            secondary: Icon(
              settings.vibrationEnabled ? Icons.vibration : Icons.phone_android,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Vibrations haptiques'),
            subtitle: const Text('Retour tactile lors des interactions'),
            value: settings.vibrationEnabled,
            onChanged: (bool value) async {
              await settings.setVibrationEnabled(value);

              // Vibration de test si activée
              if (value) {
                await HapticService().selectionVibration(enabled: true);
              }
            },
          ),
          if (settings.vibrationEnabled) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.touch_app),
              title: const Text('Tester les vibrations'),
              subtitle: const Text(
                'Essayer les différents types de vibrations',
              ),
              onTap: () => _showVibrationTestDialog(context, settings),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, SettingsService settings) {
    return AppCard(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.volume_up,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Test Audio'),
            subtitle: const Text('Tester les effets sonores de l\'application'),
            onTap: () => _showAudioTestDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Réinitialiser les paramètres'),
            subtitle: const Text('Remettre tous les paramètres par défaut'),
            onTap: () => _showResetDialog(context, settings),
          ),
        ],
      ),
    );
  }

  void _showAudioTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: const AudioTestWidget(),
            ),
          ),
    );
  }

  void _showVibrationTestDialog(
    BuildContext context,
    SettingsService settings,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.vibration,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text('Test des vibrations'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (kIsWeb)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sur le web, les vibrations sont simulées. Ouvrez la console (F12) pour voir les logs.',
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildVibrationTestButton('Sélection', () async {
                  await HapticService().selectionVibration(enabled: true);
                  if (kIsWeb && kDebugMode) {
                    print('🧪 Test vibration: Sélection (légère)');
                  }
                }),
                _buildVibrationTestButton('Succès', () async {
                  await HapticService().successVibration(enabled: true);
                  if (kIsWeb && kDebugMode) {
                    print('🧪 Test vibration: Succès (pattern court)');
                  }
                }),
                _buildVibrationTestButton('Erreur', () async {
                  await HapticService().errorVibration(enabled: true);
                  if (kIsWeb && kDebugMode) {
                    print('🧪 Test vibration: Erreur (pattern long)');
                  }
                }),
                _buildVibrationTestButton('Avertissement', () async {
                  await HapticService().warningVibration(enabled: true);
                  if (kIsWeb && kDebugMode) {
                    print('🧪 Test vibration: Avertissement (pattern moyen)');
                  }
                }),
                _buildVibrationTestButton('Fort', () async {
                  await HapticService().heavyVibration(enabled: true);
                  if (kIsWeb && kDebugMode) {
                    print('🧪 Test vibration: Fort (vibration longue)');
                  }
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  Widget _buildVibrationTestButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(onPressed: onPressed, child: Text(label)),
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Réinitialiser les paramètres'),
            content: const Text(
              'Êtes-vous sûr de vouloir remettre tous les paramètres à leurs valeurs par défaut ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () async {
                  await settings.resetToDefaults();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Paramètres réinitialisés')),
                    );
                  }
                },
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
    );
  }
}
