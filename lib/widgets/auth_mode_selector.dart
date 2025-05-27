import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';
import '../widgets/app_card.dart';

/// Widget pour sélectionner le mode d'authentification
class AuthModeSelector extends StatelessWidget {
  final Function(bool useFirebase) onModeSelected;

  const AuthModeSelector({
    super.key,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text(
            'Choisir le mode d\'authentification',
            style: ThemeHelper.getHeadlineStyle(context).copyWith(
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Mode Firebase
          _buildModeOption(
            context: context,
            title: '🔥 Firebase Authentication',
            subtitle: 'Authentification cloud sécurisée',
            description: 'Utilise Firebase pour gérer les comptes utilisateurs',
            onTap: () => onModeSelected(true),
            color: Colors.orange,
          ),
          
          const SizedBox(height: 16),
          
          // Mode Statique
          _buildModeOption(
            context: context,
            title: '💾 Mode Statique',
            subtitle: 'Authentification locale (test)',
            description: 'Utilise des comptes de test prédéfinis',
            onTap: () => onModeSelected(false),
            color: Colors.blue,
          ),
          
          const SizedBox(height: 16),
          
          // Note d'information
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vous pouvez changer de mode à tout moment dans les paramètres',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                title.contains('Firebase') ? Icons.cloud : Icons.storage,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
