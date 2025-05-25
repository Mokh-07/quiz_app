import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../utils/constants.dart';
import '../utils/theme_helper.dart';

/// Widget de test pour les effets vocaux
class VocalTestWidget extends StatelessWidget {
  const VocalTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test des Effets Vocaux'),
        backgroundColor: ThemeHelper.getPrimaryColor(context),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Testez les effets vocaux de l\'application',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            
            // Section Annonces
            _buildSection(
              'Annonces et Instructions',
              [
                _buildVocalButton(
                  'Message de Bienvenue',
                  Icons.waving_hand,
                  () => AudioService().playWelcomeVocal(enabled: true),
                ),
                _buildVocalButton(
                  'Instructions du Quiz',
                  Icons.info,
                  () => AudioService().playInstructionsVocal(enabled: true),
                ),
                _buildVocalButton(
                  'Avertissement Temps',
                  Icons.timer,
                  () => AudioService().playTimeWarningVocal(enabled: true),
                ),
              ],
            ),
            
            const SizedBox(height: AppSizes.paddingLarge),
            
            // Section Feedback
            _buildSection(
              'Feedback Vocal',
              [
                _buildVocalButton(
                  'Excellent !',
                  Icons.star,
                  () => AudioService().playExcellentVocal(enabled: true),
                ),
                _buildVocalButton(
                  'Bon Travail !',
                  Icons.thumb_up,
                  () => AudioService().playGoodJobVocal(enabled: true),
                ),
                _buildVocalButton(
                  'Essayez Encore',
                  Icons.refresh,
                  () => AudioService().playTryAgainVocal(enabled: true),
                ),
              ],
            ),
            
            const SizedBox(height: AppSizes.paddingLarge),
            
            // Section Résultats
            _buildSection(
              'Annonces de Résultats',
              [
                _buildVocalButton(
                  'Quiz Terminé',
                  Icons.check_circle,
                  () => AudioService().playQuizCompleteVocal(enabled: true),
                ),
                _buildVocalButton(
                  'Score Élevé',
                  Icons.emoji_events,
                  () => AudioService().playHighScoreVocal(enabled: true),
                ),
                _buildVocalButton(
                  'Résultats Prêts',
                  Icons.assessment,
                  () => AudioService().playResultsReadyVocal(enabled: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        ...buttons,
      ],
    );
  }

  Widget _buildVocalButton(String title, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
