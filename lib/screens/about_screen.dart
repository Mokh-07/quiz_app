import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/app_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.about),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAppInfo(),
            const SizedBox(height: AppSizes.paddingLarge),
            _buildFeatures(),
            const SizedBox(height: AppSizes.paddingLarge),
            _buildApiInfo(),
            const SizedBox(height: AppSizes.paddingLarge),
            _buildDeveloperInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.quiz,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            AppStrings.appName,
            style: AppTextStyles.headline1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            AppStrings.appDescription,
            style: AppTextStyles.bodyText2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Text(
              'Version 1.0.0',
              style: AppTextStyles.bodyText1.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fonctionnalités',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildFeatureItem(
            Icons.category,
            'Catégories variées',
            'Questions sur différents sujets : sciences, histoire, divertissement, etc.',
          ),
          _buildFeatureItem(
            Icons.speed,
            'Niveaux de difficulté',
            'Choisissez entre facile, moyen et difficile selon votre niveau.',
          ),
          _buildFeatureItem(
            Icons.quiz,
            'Questions en temps réel',
            'Questions récupérées en direct depuis l\'API OpenTDB.',
          ),
          _buildFeatureItem(
            Icons.assessment,
            'Suivi des performances',
            'Historique détaillé de vos résultats et statistiques.',
          ),
          _buildFeatureItem(
            Icons.timer,
            'Interface intuitive',
            'Design moderne et expérience utilisateur optimisée.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: AppSizes.iconSize,
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyText1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodyText2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiInfo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.api,
                color: AppColors.secondary,
                size: AppSizes.iconSizeLarge,
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Text(
                'API utilisée',
                style: AppTextStyles.headline3,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            'Open Trivia Database (OpenTDB)',
            style: AppTextStyles.bodyText1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'Cette application utilise l\'API gratuite OpenTDB pour récupérer les questions de quiz. OpenTDB est une base de données collaborative de questions de culture générale.',
            style: AppTextStyles.bodyText2,
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.link,
                  color: AppColors.secondary,
                  size: AppSizes.iconSize,
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: Text(
                    'https://opentdb.com',
                    style: AppTextStyles.bodyText2.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDeveloperInfo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                color: AppColors.warning,
                size: AppSizes.iconSizeLarge,
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Text(
                'Développement',
                style: AppTextStyles.headline3,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            'Cette application a été développée avec Flutter, le framework de développement mobile de Google.',
            style: AppTextStyles.bodyText2,
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildTechItem('Flutter', 'Framework de développement cross-platform'),
          _buildTechItem('Dart', 'Langage de programmation'),
          _buildTechItem('Provider', 'Gestion d\'état'),
          _buildTechItem('HTTP', 'Requêtes API'),
          _buildTechItem('SharedPreferences', 'Stockage local'),
        ],
      ),
    );
  }

  Widget _buildTechItem(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Text(
            name,
            style: AppTextStyles.bodyText1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Expanded(
            child: Text(
              '- $description',
              style: AppTextStyles.bodyText2,
            ),
          ),
        ],
      ),
    );
  }
}
