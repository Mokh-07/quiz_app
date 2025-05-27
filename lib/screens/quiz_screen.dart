import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../services/quiz_provider.dart';
import '../services/settings_service.dart';

import '../services/haptic_service.dart';
import '../services/simple_audio_service.dart';
import '../models/question.dart';
import '../utils/constants.dart';
import '../utils/theme_helper.dart';
import '../widgets/app_card.dart';
import '../l10n/app_localizations.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _questionAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedAnswer;
  bool _showResult = false;
  Timer? _questionTimer;
  Timer? _resultTimer;
  int _timeRemaining = 15; // 15 secondes par question
  static const int _questionTimeLimit = 15;
  static const int _resultDisplayTime = 2; // 2 secondes pour voir le résultat

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startQuestionTimer();
  }

  void _setupAnimations() {
    _questionAnimationController = AnimationController(
      duration: AppDurations.medium,
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: AppDurations.long,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _questionAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _questionAnimationController.forward();
  }

  void _startQuestionTimer() {
    _timeRemaining = _questionTimeLimit;
    _questionTimer?.cancel();

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeRemaining--;
        });

        if (_timeRemaining <= 0 || _selectedAnswer != null) {
          timer.cancel();
          if (_selectedAnswer == null) {
            // Temps écoulé, sélectionner automatiquement une réponse vide
            _selectAnswer('');
          }
          _showAnswerResult();
        }
      }
    });
  }

  void _showAnswerResult() async {
    if (mounted) {
      // Obtenir les paramètres utilisateur
      final settings = Provider.of<SettingsService>(context, listen: false);
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      final currentQuestion = quizProvider.currentQuestion;

      setState(() {
        _showResult = true;
      });

      // Feedback sonore et haptique selon le résultat
      if (_selectedAnswer != null && currentQuestion != null) {
        final isCorrect = currentQuestion.isCorrectAnswer(_selectedAnswer!);

        if (isCorrect) {
          // Réponse correcte
          await HapticService().successVibration(
            enabled: settings.vibrationEnabled,
          );
          await SimpleAudioService().playCorrectSound();
        } else {
          // Réponse incorrecte
          await HapticService().errorVibration(
            enabled: settings.vibrationEnabled,
          );
          await SimpleAudioService().playWrongSound();
        }
      } else {
        // Temps écoulé - vibration d'avertissement
        await HapticService().warningVibration(
          enabled: settings.vibrationEnabled,
        );
      }

      _resultTimer = Timer(Duration(seconds: _resultDisplayTime), () {
        if (mounted) {
          _proceedToNextQuestion();
        }
      });
    }
  }

  void _proceedToNextQuestion() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    quizProvider.answerQuestion(_selectedAnswer ?? '');

    if (quizProvider.isQuizCompleted) {
      _navigateToResults(quizProvider);
    } else {
      _resetForNextQuestion();
    }
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _resultTimer?.cancel();
    _questionAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).question),
        backgroundColor: ThemeHelper.getPrimaryColor(context),
        foregroundColor: ThemeHelper.getOnPrimaryColor(context),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (quizProvider.isQuizCompleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToResults(quizProvider);
            });
            return const Center(child: CircularProgressIndicator());
          }

          return _buildQuizContent(quizProvider);
        },
      ),
    );
  }

  Widget _buildQuizContent(QuizProvider quizProvider) {
    final Question? currentQuestion = quizProvider.currentQuestion;

    if (currentQuestion == null) {
      return const Center(child: Text('Aucune question disponible'));
    }

    return Column(
      children: [
        _buildProgressBar(quizProvider),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildQuestionHeader(quizProvider),
                    const SizedBox(height: AppSizes.paddingLarge),
                    _buildQuestionCard(currentQuestion),
                    const SizedBox(height: AppSizes.paddingLarge),
                    _buildAnswerOptions(currentQuestion),
                    const SizedBox(height: AppSizes.paddingLarge),
                    // Le bouton "Question suivante" a été supprimé - transition automatique
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(QuizProvider quizProvider) {
    final double progress =
        (quizProvider.currentQuestionIndex + 1) / quizProvider.questions.length;
    final double timeProgress = _timeRemaining / _questionTimeLimit;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        gradient: ThemeHelper.getBackgroundGradient(context),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getPrimaryColor(context).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppLocalizations.of(context).question} ${quizProvider.currentQuestionIndex + 1}',
                style: ThemeHelper.getBodyStyle(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingSmall,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              _timeRemaining <= 5
                                  ? ThemeHelper.getErrorGradient(context)
                                  : ThemeHelper.getPrimaryGradient(context),
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadius,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${_timeRemaining}s',
                              style: AppTextStyles.bodyText2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate(target: _timeRemaining <= 5 ? 1 : 0)
                      .shake(duration: 500.ms),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Text(
                    '${quizProvider.currentQuestionIndex + 1} ${AppLocalizations.of(context).ofText} ${quizProvider.questions.length}',
                    style: AppTextStyles.bodyText2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // Barre de progression des questions
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: ThemeHelper.getProgressBackgroundColor(context),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: ThemeHelper.getPrimaryGradient(context),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.paddingSmall),

          // Barre de progression du temps
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: ThemeHelper.getProgressBackgroundColor(context),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: timeProgress,
              child: Container(
                decoration: BoxDecoration(
                  gradient:
                      _timeRemaining <= 5
                          ? ThemeHelper.getErrorGradient(context)
                          : ThemeHelper.getSuccessGradient(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(QuizProvider quizProvider) {
    final Question currentQuestion = quizProvider.currentQuestion!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusSmall,
                  ),
                ),
                child: Text(
                  currentQuestion.category,
                  style: ThemeHelper.getBodyStyle(context).copyWith(
                    color: ThemeHelper.getPrimaryColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(
                    context,
                    currentQuestion.difficulty,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusSmall,
                  ),
                ),
                child: Text(
                  currentQuestion.difficulty.toUpperCase(),
                  style: ThemeHelper.getBodyStyle(context).copyWith(
                    color: _getDifficultyColor(
                      context,
                      currentQuestion.difficulty,
                    ),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(BuildContext context, String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return ThemeHelper.getCorrectAnswerColor(context);
      case 'medium':
        return Colors.orange; // Couleur d'avertissement
      case 'hard':
        return ThemeHelper.getIncorrectAnswerColor(context);
      default:
        return ThemeHelper.getPrimaryColor(context);
    }
  }

  Widget _buildQuestionCard(Question question) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question directement sans en-tête
          Text(
            question.question,
            style: ThemeHelper.getHeadlineStyle(
              context,
            ).copyWith(height: 1.4, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(Question question) {
    // Lettres pour les options (A, B, C, D)
    const List<String> optionLabels = ['A', 'B', 'C', 'D'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Liste des options sans scroll
        ...List.generate(question.allAnswers.length, (index) {
          final String answer = question.allAnswers[index];
          final bool isSelected = _selectedAnswer == answer;
          final bool isCorrect = question.isCorrectAnswer(answer);
          final String optionLabel =
              index < optionLabels.length
                  ? optionLabels[index]
                  : '${index + 1}';

          Color backgroundColor = ThemeHelper.getUnselectedAnswerColor(context);
          Color textColor = ThemeHelper.getOnSurfaceColor(context);
          Color labelBackgroundColor = ThemeHelper.getSurfaceColor(context);
          Color labelTextColor = ThemeHelper.getOnSurfaceColor(context);

          if (_showResult) {
            if (isCorrect) {
              backgroundColor = ThemeHelper.getCorrectAnswerColor(context);
              textColor = Colors.white;
              labelBackgroundColor = ThemeHelper.getCorrectAnswerColor(context);
              labelTextColor = Colors.white;
            } else if (isSelected && !isCorrect) {
              backgroundColor = ThemeHelper.getIncorrectAnswerColor(context);
              textColor = Colors.white;
              labelBackgroundColor = ThemeHelper.getIncorrectAnswerColor(
                context,
              );
              labelTextColor = Colors.white;
            }
          } else if (isSelected) {
            backgroundColor = ThemeHelper.getPrimaryColor(context);
            textColor = ThemeHelper.getOnPrimaryColor(context);
            labelBackgroundColor = ThemeHelper.getPrimaryColor(context);
            labelTextColor = ThemeHelper.getOnPrimaryColor(context);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
            child: GestureDetector(
              onTap: _showResult ? null : () => _selectAnswer(answer),
              child: AnimatedContainer(
                duration: AppDurations.short,
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(
                    color:
                        isSelected
                            ? ThemeHelper.getPrimaryColor(context)
                            : ThemeHelper.getBorderColor(context),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: ThemeHelper.getPrimaryColor(
                                context,
                              ).withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  children: [
                    // Lettre de l'option (A, B, C, D)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: labelBackgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected
                                  ? ThemeHelper.getOnPrimaryColor(context)
                                  : ThemeHelper.getBorderColor(context),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          optionLabel,
                          style: ThemeHelper.getBodyStyle(context).copyWith(
                            color: labelTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSizes.paddingMedium),

                    // Texte de la réponse
                    Expanded(
                      child: Text(
                        answer,
                        style: ThemeHelper.getBodyStyle(context).copyWith(
                          color: textColor,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          height: 1.3,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Indicateur de sélection/résultat
                    if (isSelected && !_showResult)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: ThemeHelper.getPrimaryColor(context),
                        ),
                      ),

                    if (_showResult && isCorrect)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: ThemeHelper.getCorrectAnswerColor(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: AppSizes.iconSize,
                        ),
                      ),

                    if (_showResult && isSelected && !isCorrect)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: ThemeHelper.getIncorrectAnswerColor(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cancel,
                          color: Colors.white,
                          size: AppSizes.iconSize,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _selectAnswer(String answer) async {
    if (_selectedAnswer == null && !_showResult) {
      // Obtenir les paramètres utilisateur
      final settings = Provider.of<SettingsService>(context, listen: false);

      setState(() {
        _selectedAnswer = answer;
      });

      // Feedback immédiat : vibration de sélection
      await HapticService().selectionVibration(
        enabled: settings.vibrationEnabled,
      );

      // Arrêter le timer et montrer le résultat automatiquement
      _questionTimer?.cancel();
      _showAnswerResult();
    }
  }

  void _resetForNextQuestion() {
    setState(() {
      _selectedAnswer = null;
      _showResult = false;
    });

    // Redémarrer le timer pour la nouvelle question
    _startQuestionTimer();

    // Animation pour la nouvelle question
    _questionAnimationController.reset();
    _questionAnimationController.forward();
  }

  void _navigateToResults(QuizProvider quizProvider) async {
    try {
      final result = await quizProvider.completeQuiz();

      if (mounted) {
        // Attendre un court délai pour s'assurer que l'état est stable
        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => QuizResultScreen(result: result),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la navigation vers les résultats: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: ThemeHelper.getIncorrectAnswerColor(context),
          ),
        );

        // En cas d'erreur, retourner à l'écran de configuration
        Navigator.of(context).pop();
      }
    }
  }
}
