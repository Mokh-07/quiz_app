import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_result.dart';
import '../services/quiz_provider.dart';
import '../services/simple_audio_service.dart';
import '../utils/constants.dart';
import '../utils/theme_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_card.dart';
import 'quiz_setup_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizResult result;
  final bool isNewRecord;

  const QuizResultScreen({
    super.key,
    required this.result,
    this.isNewRecord = false,
  });

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

      // Jouer le son de quiz terminé
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          SimpleAudioService().playCompleteSound();
        }
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _scoreAnimationController.forward();
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
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildResultHeader(),
                if (widget.isNewRecord) ...[
                  const SizedBox(height: AppSizes.paddingMedium),
                  _buildNewRecordBanner(),
                ],
                const SizedBox(height: AppSizes.paddingMedium),
                _buildScoreCard(),
                const SizedBox(height: AppSizes.paddingMedium),
                _buildStatsCards(),
                const SizedBox(height: AppSizes.paddingMedium),
                _buildQuestionReview(),
                const SizedBox(height: AppSizes.paddingLarge),
                _buildActionButtons(),
                const SizedBox(height: AppSizes.paddingMedium), // Espace en bas
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
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
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              widget.result.isPassed ? Icons.check : Icons.close,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            AppStrings.quizCompleted,
            style: AppTextStyles.headline2.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingXSmall),
          Text(
            widget.result.evaluation,
            style: AppTextStyles.bodyText1.copyWith(
              color:
                  widget.result.isPassed ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNewRecordBanner() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade400, Colors.orange.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎉 NOUVEAU RECORD !',
                    style: AppTextStyles.headline3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Félicitations ! Vous avez établi un nouveau meilleur score pour cette catégorie et difficulté.',
                    style: AppTextStyles.bodyText2.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: AppSizes.iconSize,
                  ),
                  const SizedBox(height: AppSizes.paddingXSmall),
                  Text(
                    '${widget.result.score}',
                    style: AppTextStyles.headline3.copyWith(
                      color: AppColors.success,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Correctes',
                    style: AppTextStyles.bodyText2.copyWith(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingSmall),
        Expanded(
          child: AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cancel,
                    color: AppColors.error,
                    size: AppSizes.iconSize,
                  ),
                  const SizedBox(height: AppSizes.paddingXSmall),
                  Text(
                    '${widget.result.incorrectAnswers}',
                    style: AppTextStyles.headline3.copyWith(
                      color: AppColors.error,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Incorrectes',
                    style: AppTextStyles.bodyText2.copyWith(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingSmall),
        Expanded(
          child: AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: AppColors.primary,
                    size: AppSizes.iconSize,
                  ),
                  const SizedBox(height: AppSizes.paddingXSmall),
                  Text(
                    _formatDuration(widget.result.timeTaken),
                    style: AppTextStyles.bodyText1.copyWith(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Temps',
                    style: AppTextStyles.bodyText2.copyWith(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
          // Limiter la hauteur pour éviter l'overflow
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.result.questions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final question = widget.result.questions[index];
                final userAnswer =
                    index < widget.result.userAnswers.length
                        ? widget.result.userAnswers[index]
                        : '';
                final isCorrect = question.isCorrectAnswer(userAnswer);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingXSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color:
                                isCorrect ? AppColors.success : AppColors.error,
                            size: AppSizes.iconSizeSmall,
                          ),
                          const SizedBox(width: AppSizes.paddingXSmall),
                          Expanded(
                            child: Text(
                              'Question ${index + 1}',
                              style: AppTextStyles.bodyText1.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.paddingXSmall),
                      Text(
                        question.question,
                        style: AppTextStyles.bodyText2.copyWith(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.paddingXSmall),
                      if (!isCorrect) ...[
                        Text(
                          'Votre réponse: $userAnswer',
                          style: AppTextStyles.bodyText2.copyWith(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Bonne réponse: ${question.correctAnswer}',
                          style: AppTextStyles.bodyText2.copyWith(
                            color: AppColors.success,
                            fontSize: 12,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Bonne réponse: ${question.correctAnswer}',
                          style: AppTextStyles.bodyText2.copyWith(
                            color: AppColors.success,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton(
          text: AppStrings.playAgain,
          icon: Icons.refresh,
          onPressed: _playAgain,
          backgroundColor: AppColors.primary,
          height: 48, // Hauteur réduite
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        CustomButton(
          text: AppStrings.backToHome,
          icon: Icons.home,
          onPressed: _backToHome,
          backgroundColor: AppColors.secondary,
          height: 48, // Hauteur réduite
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  void _playAgain() async {
    try {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      quizProvider.resetQuiz();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const QuizSetupScreen()),
        );
      }
    } catch (e) {
      debugPrint('Erreur lors du redémarrage du quiz: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du redémarrage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _backToHome() async {
    try {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);

      // Nettoyer l'état du quiz
      quizProvider.resetQuiz();

      // Attendre un court délai pour s'assurer que l'état est nettoyé
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        // Utiliser une navigation plus sûre
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      debugPrint('Erreur lors du retour à l\'accueil: $e');
      if (mounted) {
        // Fallback: essayer une navigation alternative
        try {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        } catch (fallbackError) {
          // Dernière option: navigation simple
          Navigator.of(context).pop();
        }
      }
    }
  }
}
