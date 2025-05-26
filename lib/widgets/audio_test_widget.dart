import 'package:flutter/material.dart';
import '../services/simple_audio_service.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

/// Widget de test pour les fichiers audio
class AudioTestWidget extends StatelessWidget {
  const AudioTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).testAudio),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test des fichiers audio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            const Text(
              'Cliquez sur les boutons pour tester chaque son :',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            _buildTestButton(
              'Test Correct Sound',
              Icons.check_circle,
              Colors.green,
              () => SimpleAudioService().playCorrectSound(),
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            _buildTestButton(
              'Test Wrong Sound',
              Icons.cancel,
              Colors.red,
              () => SimpleAudioService().playWrongSound(),
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            _buildTestButton(
              'Test Complete Sound',
              Icons.celebration,
              Colors.blue,
              () => SimpleAudioService().playCompleteSound(),
            ),

            const SizedBox(height: AppSizes.paddingLarge),

            ElevatedButton.icon(
              onPressed: () => SimpleAudioService().testAllSounds(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Tester tous les sons'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: AppSizes.paddingLarge),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions :',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: AppSizes.paddingSmall),
                    Text('1. Copiez vos fichiers dans assets/sounds/'),
                    Text('2. Nommez-les: correct.mp3, wrong.mp3, complete.mp3'),
                    Text('3. Relancez l\'app avec flutter run'),
                    Text('4. Vérifiez la console pour les messages d\'erreur'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }
}
