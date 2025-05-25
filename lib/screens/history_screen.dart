import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/quiz_provider.dart';
import '../models/quiz_result.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import '../widgets/app_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).loadQuizHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.quizHistory),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<QuizProvider>(
            builder: (context, quizProvider, child) {
              if (quizProvider.quizHistory.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () => _showClearHistoryDialog(quizProvider),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.resultsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (quizProvider.quizHistory.isEmpty) {
            return _buildEmptyState();
          }

          return _buildHistoryList(quizProvider.quizHistory);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            const SizedBox(height: AppSizes.paddingLarge),
            Text(
              AppStrings.noHistoryAvailable,
              style: AppTextStyles.headline3.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              'Commencez votre premier quiz pour voir vos résultats ici',
              style: AppTextStyles.bodyText2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<QuizResult> history) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final result = history[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
          child: _buildHistoryItem(result),
        );
      },
    );
  }

  Widget _buildHistoryItem(QuizResult result) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  result.category,
                  style: AppTextStyles.headline3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      result.isPassed
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusSmall,
                  ),
                ),
                child: Text(
                  '${result.percentage.toStringAsFixed(0)}%',
                  style: AppTextStyles.bodyText1.copyWith(
                    color:
                        result.isPassed ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Row(
            children: [
              _buildInfoChip(
                Icons.quiz,
                '${result.score}/${result.totalQuestions}',
                AppColors.primary,
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              _buildInfoChip(
                Icons.speed,
                result.difficulty.displayName,
                _getDifficultyColor(result.difficulty),
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              _buildInfoChip(
                Icons.timer,
                _formatDuration(result.timeTaken),
                AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(_formatDate(result.completedAt), style: AppTextStyles.caption),
          const SizedBox(height: AppSizes.paddingMedium),
          Row(
            children: [
              Expanded(
                child: Text(
                  result.evaluation,
                  style: AppTextStyles.bodyText1.copyWith(
                    fontWeight: FontWeight.w500,
                    color:
                        result.isPassed ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
              Icon(
                result.isPassed ? Icons.check_circle : Icons.cancel,
                color: result.isPassed ? AppColors.success : AppColors.error,
                size: AppSizes.iconSize,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return AppColors.success;
      case Difficulty.medium:
        return AppColors.warning;
      case Difficulty.hard:
        return AppColors.error;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showClearHistoryDialog(QuizProvider quizProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Effacer l\'historique'),
            content: const Text(AppStrings.confirmClearHistory),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _clearHistory(quizProvider);
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Effacer'),
              ),
            ],
          ),
    );
  }

  void _clearHistory(QuizProvider quizProvider) async {
    try {
      await quizProvider.clearHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historique effacé avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'effacement: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
