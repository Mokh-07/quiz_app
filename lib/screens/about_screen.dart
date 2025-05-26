import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../utils/theme_helper.dart';
import '../utils/icon_helper.dart';
import '../widgets/app_card.dart';
import '../widgets/language_button.dart';
import '../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).aboutApp),
        backgroundColor: ThemeHelper.getPrimaryColor(context),
        foregroundColor: ThemeHelper.getOnPrimaryColor(context),
        elevation: 0,
        actions: [const CompactLanguageButton()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: ThemeHelper.getBackgroundGradient(context),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAppInfo(context),
              const SizedBox(height: AppSizes.paddingLarge),
              _buildFeatures(context),
              const SizedBox(height: AppSizes.paddingLarge),
              _buildApiInfo(context),
              const SizedBox(height: AppSizes.paddingLarge),
              _buildTechnicalInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: ThemeHelper.getPrimaryGradient(context),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeHelper.getPrimaryColor(
                        context,
                      ).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  IconHelper.getUIIcon('quiz'),
                  size: 50,
                  color: ThemeHelper.getOnPrimaryColor(context),
                ),
              )
              .animate()
              .scale(duration: 800.ms, curve: Curves.elasticOut)
              .shimmer(duration: 2000.ms),

          const SizedBox(height: AppSizes.paddingLarge),
          Text(
            AppLocalizations.of(context).appTitle,
            style: ThemeHelper.getHeadlineStyle(
              context,
            ).copyWith(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            AppLocalizations.of(context).appDescription,
            style: ThemeHelper.getSecondaryTextStyle(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLarge,
              vertical: AppSizes.paddingMedium,
            ),
            decoration: BoxDecoration(
              gradient: ThemeHelper.getSuccessGradient(context),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: AppSizes.iconSize,
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                Text(
                  '${AppLocalizations.of(context).version} 1.0.0',
                  style: ThemeHelper.getBodyStyle(
                    context,
                  ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                IconHelper.getUIIcon('features'),
                color: ThemeHelper.getPrimaryColor(context),
                size: AppSizes.iconSizeLarge,
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Text(
                AppLocalizations.of(context).features,
                style: ThemeHelper.getHeadlineStyle(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildFeatureItem(
            context,
            IconHelper.getCategoryIcon('General Knowledge'),
            AppLocalizations.of(context).multipleCategories,
            '20+ ${AppLocalizations.of(context).categories.toLowerCase()}',
          ),
          _buildFeatureItem(
            context,
            IconHelper.getUIIcon('difficulty'),
            AppLocalizations.of(context).difficultyLevels,
            '${AppLocalizations.of(context).easy}, ${AppLocalizations.of(context).medium}, ${AppLocalizations.of(context).hard}',
          ),
          _buildFeatureItem(
            context,
            Icons.volume_up,
            AppLocalizations.of(context).audioFeedback,
            AppLocalizations.of(context).soundEffects,
          ),
          _buildFeatureItem(
            context,
            Icons.language,
            AppLocalizations.of(context).multiLanguage,
            'Français, English, العربية, Español',
          ),
          _buildFeatureItem(
            context,
            IconHelper.getUIIcon('theme_dark'),
            AppLocalizations.of(context).darkModeSupport,
            AppLocalizations.of(context).theme,
          ),
          _buildFeatureItem(
            context,
            IconHelper.getUIIcon('history'),
            AppLocalizations.of(context).progressTracking,
            AppLocalizations.of(context).viewHistory,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: ThemeHelper.getPrimaryGradient(context),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: Colors.white, size: AppSizes.iconSize),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ThemeHelper.getBodyStyle(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: ThemeHelper.getSecondaryTextStyle(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiInfo(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.api,
                color: ThemeHelper.getSecondaryColor(context),
                size: AppSizes.iconSizeLarge,
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Text(
                AppLocalizations.of(context).apiInformation,
                style: ThemeHelper.getHeadlineStyle(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          Text(
            AppLocalizations.of(context).apiDescription,
            style: ThemeHelper.getBodyStyle(context),
          ),
          const SizedBox(height: AppSizes.paddingLarge),

          // API Provider
          _buildInfoRow(
            context,
            Icons.business,
            AppLocalizations.of(context).apiProvider,
            'Open Trivia Database',
          ),

          // Website
          _buildInfoRow(
            context,
            Icons.link,
            AppLocalizations.of(context).apiWebsite,
            'https://opentdb.com',
            isLink: true,
          ),

          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            AppLocalizations.of(context).apiFeatures,
            style: ThemeHelper.getBodyStyle(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.paddingSmall),

          _buildFeatureChip(context, AppLocalizations.of(context).freeToUse),
          _buildFeatureChip(
            context,
            AppLocalizations.of(context).noRegistration,
          ),
          _buildFeatureChip(
            context,
            AppLocalizations.of(context).regularUpdates,
          ),
          _buildFeatureChip(
            context,
            AppLocalizations.of(context).qualityQuestions,
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalInfo(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                color: ThemeHelper.getSecondaryColor(context),
                size: AppSizes.iconSizeLarge,
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Text(
                AppLocalizations.of(context).technicalInfo,
                style: ThemeHelper.getHeadlineStyle(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingLarge),

          Text(
            AppLocalizations.of(context).builtWith,
            style: ThemeHelper.getBodyStyle(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          _buildTechItem(context, 'Flutter', 'Cross-platform framework'),
          _buildTechItem(context, 'Dart', 'Programming language'),
          _buildTechItem(context, 'Provider', 'State management'),
          _buildTechItem(context, 'Material Design 3', 'UI design system'),
          _buildTechItem(context, 'Shared Preferences', 'Local storage'),

          const SizedBox(height: AppSizes.paddingLarge),

          Row(
            children: [
              Icon(Icons.person, color: ThemeHelper.getSecondaryColor(context)),
              const SizedBox(width: AppSizes.paddingSmall),
              Text(
                AppLocalizations.of(context).developer,
                style: ThemeHelper.getBodyStyle(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        children: [
          Icon(
            icon,
            color: ThemeHelper.getSecondaryColor(context),
            size: AppSizes.iconSize,
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Text(
            '$label: ',
            style: ThemeHelper.getBodyStyle(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: GestureDetector(
              onTap: isLink ? () => _launchUrl(value) : null,
              child: Text(
                value,
                style: ThemeHelper.getBodyStyle(context).copyWith(
                  color: isLink ? ThemeHelper.getSecondaryColor(context) : null,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.only(
        right: AppSizes.paddingSmall,
        bottom: AppSizes.paddingSmall,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: AppSizes.paddingXSmall),
          Text(
            text,
            style: ThemeHelper.getBodyStyle(
              context,
            ).copyWith(color: Colors.green, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(BuildContext context, String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: ThemeHelper.getSecondaryColor(context),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Text(
            name,
            style: ThemeHelper.getBodyStyle(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Expanded(
            child: Text(
              '- $description',
              style: ThemeHelper.getSecondaryTextStyle(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
