import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/quiz_provider.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import '../utils/theme_helper.dart';
import '../utils/difficulty_helper.dart';
import '../l10n/app_localizations.dart';

import '../widgets/custom_button.dart';
import '../widgets/app_card.dart';
import '../widgets/question_count_slider.dart';
import 'quiz_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).selectCategory),
        backgroundColor: ThemeHelper.getPrimaryColor(context),
        foregroundColor: ThemeHelper.getOnPrimaryColor(context),
        elevation: 0,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.categoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (quizProvider.categoriesError != null) {
            return _buildErrorWidget(quizProvider);
          }

          return _buildSetupForm(quizProvider);
        },
      ),
    );
  }

  Widget _buildErrorWidget(QuizProvider quizProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: ThemeHelper.getErrorColor(context),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              AppLocalizations.of(context).error,
              style: ThemeHelper.getHeadlineStyle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              quizProvider.categoriesError!,
              style: ThemeHelper.getSecondaryTextStyle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            CustomButton(
              text: AppLocalizations.of(context).retry,
              icon: Icons.refresh,
              onPressed: () => quizProvider.loadCategories(),
              backgroundColor: ThemeHelper.getPrimaryColor(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupForm(QuizProvider quizProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCategorySelection(quizProvider),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildDifficultySelection(quizProvider),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildQuestionCountSelection(quizProvider),
          const SizedBox(height: AppSizes.paddingXLarge),
          _buildStartButton(quizProvider),
        ],
      ),
    );
  }

  Widget _buildCategorySelection(QuizProvider quizProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).selectCategory,
            style: ThemeHelper.getHeadlineStyle(context),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          DropdownButtonFormField<int>(
            value: quizProvider.selectedCategoryId,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
            ),
            items:
                quizProvider.categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(
                      category.name,
                      style: ThemeHelper.getBodyStyle(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                quizProvider.updateQuizSettings(categoryId: value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelection(QuizProvider quizProvider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).selectDifficulty,
            style: ThemeHelper.getHeadlineStyle(context),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Row(
            children:
                Difficulty.values.map((difficulty) {
                  final bool isSelected =
                      quizProvider.selectedDifficulty == difficulty;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap:
                            () => quizProvider.updateQuizSettings(
                              difficulty: difficulty,
                            ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.paddingMedium,
                            horizontal: AppSizes.paddingXSmall,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? ThemeHelper.getPrimaryColor(context)
                                    : ThemeHelper.getUnselectedAnswerColor(
                                      context,
                                    ),
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadius,
                            ),
                            border:
                                isSelected
                                    ? null
                                    : Border.all(
                                      color: ThemeHelper.getBorderColor(
                                        context,
                                      ),
                                      width: 1,
                                    ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              DifficultyHelper.getDisplayName(
                                context,
                                difficulty,
                              ),
                              style: ThemeHelper.getBodyStyle(context).copyWith(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : ThemeHelper.getOnSurfaceColor(
                                          context,
                                        ),
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCountSelection(QuizProvider quizProvider) {
    return QuestionCountSlider(
      initialValue: quizProvider.numberOfQuestions,
      onChanged:
          (value) => quizProvider.updateQuizSettings(numberOfQuestions: value),
      minValue: QuestionCounts.minCount,
      maxValue: QuestionCounts.maxCount,
    );
  }

  Widget _buildStartButton(QuizProvider quizProvider) {
    return CustomButton(
      text: AppLocalizations.of(context).start,
      icon: Icons.play_arrow,
      onPressed: () => _startQuiz(quizProvider),
      backgroundColor: ThemeHelper.getCorrectAnswerColor(context),
      height: 56,
    );
  }

  void _startQuiz(QuizProvider quizProvider) async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await quizProvider.startQuiz();

      if (mounted) {
        Navigator.of(context).pop(); // Fermer le dialog de chargement

        if (quizProvider.quizError == null &&
            quizProvider.questions.isNotEmpty) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const QuizScreen()),
          );
        } else {
          _showErrorDialog(quizProvider.quizError ?? 'Erreur inconnue');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Fermer le dialog de chargement
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Erreur'),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
