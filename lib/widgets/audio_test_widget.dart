import 'package:flutter/material.dart';
import '../services/simple_audio_service.dart';
import '../utils/constants.dart';

/// Widget de test pour les fichiers audio
class AudioTestWidget extends StatelessWidget {
  const AudioTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Column(
        children: [
          // En-tête du dialogue
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.borderRadius),
                topRight: Radius.circular(AppSizes.borderRadius),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.volume_up, color: Colors.white, size: 24),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: Text(
                    'Test Audio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Contenu scrollable
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              children: [
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
              ],
            ),
          ),
        ],
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
