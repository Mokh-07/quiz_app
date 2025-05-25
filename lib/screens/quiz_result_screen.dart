import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_result.dart';
import '../services/quiz_provider.dart';
import '../services/audio_service.dart';
import '../utils/constants.dart';
import '../utils/theme_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_card.dart';
import 'home_screen.dart';
import 'quiz_setup_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizResult result;

  const QuizResultScreen({super.key, required this.result});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scoreAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppDurations.long,
      vsync: this,
    );

    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: widget.result.percentage,
    ).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _startAnimations() {
    if (mounted) {
      _animationController.forward();

      // Jouer l'annonce de fin de quiz
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          AudioService().playQuizCompleteVocal(enabled: true);
        }
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _scoreAnimationController.forward();
        }
      });

      // Jouer un feedback vocal basé sur la performance
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          final percentage = widget.result.percentage;
          if (percentage >= 90) {
            AudioService().playExcellentVocal(enabled: true);
          } else if (percentage >= 70) {
            AudioService().playGoodJobVocal(enabled: true);
          } else {
            AudioService().playTryAgainVocal(enabled: true);
          }

          // Si c'est un score élevé, jouer l'annonce spéciale
          if (percentage >= 95) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                AudioService().playHighScoreVocal(enabled: true);
              }
            });
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Résultats'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildResultHeader(),
              const SizedBox(height: AppSizes.paddingLarge),
              _buildScoreCard(),
              const SizedBox(height: AppSizes.paddingLarge),
              _buildStatsCards(),
              const SizedBox(height: AppSizes.paddingLarge),
              _buildQuestionReview(),
              const SizedBox(height: AppSizes.paddingXLarge),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color:
                  widget.result.isPassed ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.result.isPassed
                          ? AppColors.success
                          : AppColors.error)
                      .withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              widget.result.isPassed ? Icons.check : Icons.close,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            AppStrings.quizCompleted,
            style: AppTextStyles.headline1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            widget.result.evaluation,
            style: AppTextStyles.headline3.copyWith(
              color:
                  widget.result.isPassed ? AppColors.success : AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return AppCard(
      child: Column(
        children: [
          Text(AppStrings.yourScore, style: AppTextStyles.headline3),
          const SizedBox(height: AppSizes.paddingMedium),
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  Text(
                    '${_scoreAnimation.value.toInt()}%',
                    style: AppTextStyles.headline1.copyWith(
                      fontSize: 48,
                      color:
                          widget.result.isPassed
                              ? AppColors.success
                              : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  LinearProgressIndicator(
                    value: _scoreAnimation.value / 100,
                    backgroundColor: AppColors.unselectedAnswer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.result.isPassed
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    minHeight: 8,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            '${widget.result.score} sur ${widget.result.totalQuestions} questions',
            style: ThemeHelper.getBodyStyle(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: AppSizes.iconSizeLarge,
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Text(
                  '${widget.result.score}',
                  style: AppTextStyles.headline2.copyWith(
                    color: AppColors.success,
                  ),
                ),
                Text('Correctes', style: AppTextStyles.bodyText2),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingMedium),
        Expanded(
          child: AppCard(
            child: Column(
              children: [
                Icon(
                  Icons.cancel,
                  color: AppColors.error,
                  size: AppSizes.iconSizeLarge,
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Text(
                  '${widget.result.incorrectAnswers}',
                  style: AppTextStyles.headline2.copyWith(
                    color: AppColors.error,
                  ),
                ),
                Text('Incorrectes', style: AppTextStyles.bodyText2),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingMedium),
        Expanded(
          child: AppCard(
            child: Column(
              children: [
                Icon(
                  Icons.timer,
                  color: AppColors.primary,
                  size: AppSizes.iconSizeLarge,
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Text(
                  _formatDuration(widget.result.timeTaken),
                  style: AppTextStyles.headline3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text('Temps', style: AppTextStyles.bodyText2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionReview() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Révision des questions', style: AppTextStyles.headline3),
          const SizedBox(height: AppSizes.paddingMedium),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.result.questions.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final question = widget.result.questions[index];
              final userAnswer =
                  index < widget.result.userAnswers.length
                      ? widget.result.userAnswers[index]
                      : '';
              final isCorrect = question.isCorrectAnswer(userAnswer);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingSmall,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color:
                              isCorrect ? AppColors.success : AppColors.error,
                          size: AppSizes.iconSize,
                        ),
                        const SizedBox(width: AppSizes.paddingSmall),
                        Expanded(
                          child: Text(
                            'Question ${index + 1}',
                            style: AppTextStyles.bodyText1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Text(question.question, style: AppTextStyles.bodyText1),
                    const SizedBox(height: AppSizes.paddingSmall),
                    if (!isCorrect) ...[
                      Text(
                        'Votre réponse: $userAnswer',
                        style: AppTextStyles.bodyText2.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      Text(
                        'Bonne réponse: ${question.correctAnswer}',
                        style: AppTextStyles.bodyText2.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Bonne réponse: ${question.correctAnswer}',
                        style: AppTextStyles.bodyText2.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          text: AppStrings.playAgain,
          icon: Icons.refresh,
          onPressed: _playAgain,
          backgroundColor: AppColors.primary,
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        CustomButton(
          text: AppStrings.backToHome,
          icon: Icons.home,
          onPressed: _backToHome,
          backgroundColor: AppColors.secondary,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  void _playAgain() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    quizProvider.resetQuiz();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const QuizSetupScreen()),
    );
  }

  void _backToHome() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    quizProvider.resetQuiz();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }
}
