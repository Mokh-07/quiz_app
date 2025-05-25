import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/quiz_provider.dart';
import '../services/settings_service.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../utils/constants.dart';
import '../utils/theme_helper.dart';
import '../utils/icon_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_card.dart';
import 'quiz_setup_screen.dart';
import 'history_screen.dart';
import 'about_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadInitialData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppDurations.long,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    // Jouer le message de bienvenue après un délai
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        AudioService().playWelcomeVocal(enabled: true);
      }
    });
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      quizProvider.loadCategories();
      quizProvider.loadQuizHistory();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<SettingsService>(
            builder: (context, settings, child) {
              return IconButton(
                icon: Icon(
                  settings.isDarkMode
                      ? IconHelper.getUIIcon('theme_light')
                      : IconHelper.getUIIcon('theme_dark'),
                ),
                onPressed: () async {
                  // Basculer entre les modes
                  final newMode =
                      settings.themeMode == ThemeMode.light
                          ? ThemeMode.dark
                          : settings.themeMode == ThemeMode.dark
                          ? ThemeMode.system
                          : ThemeMode.light;

                  await settings.setThemeMode(newMode);

                  // Feedback haptique et sonore
                  await HapticService().selectionVibration(
                    enabled: settings.vibrationEnabled,
                  );
                  await AudioService().playSelectionSound(
                    enabled: settings.soundEnabled,
                  );
                },
                tooltip: 'Changer le thème',
              );
            },
          ),
          IconButton(
            icon: Icon(IconHelper.getUIIcon('settings')),
            onPressed: () => _navigateToSettings(),
            tooltip: 'Paramètres',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: ThemeHelper.getBackgroundGradient(context),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: AnimationLimiter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSizes.paddingXLarge),
                      AnimationConfiguration.staggeredList(
                        position: 0,
                        duration: const Duration(milliseconds: 600),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(child: _buildHeader()),
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Expanded(child: _buildMenuOptions()),
                      AnimationConfiguration.staggeredList(
                        position: 3,
                        duration: const Duration(milliseconds: 600),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(child: _buildFooter()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: ThemeHelper.getPrimaryGradient(context),
                borderRadius: BorderRadius.circular(70),
                boxShadow: [
                  BoxShadow(
                    color: ThemeHelper.getPrimaryColor(
                      context,
                    ).withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: ThemeHelper.getPrimaryColor(
                      context,
                    ).withValues(alpha: 0.2),
                    blurRadius: 60,
                    offset: const Offset(0, 30),
                  ),
                ],
              ),
              child: Icon(
                IconHelper.getUIIcon('quiz'),
                size: 70,
                color: ThemeHelper.getOnPrimaryColor(context),
              ),
            )
            .animate()
            .scale(duration: 800.ms, curve: Curves.elasticOut)
            .shimmer(
              duration: 2000.ms,
              color: Colors.white.withValues(alpha: 0.5),
            ),
        const SizedBox(height: AppSizes.paddingLarge),

        ShaderMask(
              shaderCallback:
                  (bounds) => ThemeHelper.getPrimaryGradient(
                    context,
                  ).createShader(bounds),
              child: Text(
                AppStrings.welcomeTitle,
                style: ThemeHelper.getHeadlineStyle(context).copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            )
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 200.ms),

        const SizedBox(height: AppSizes.paddingSmall),

        Text(
              AppStrings.welcomeSubtitle,
              style: ThemeHelper.getSecondaryTextStyle(
                context,
              ).copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(duration: 600.ms, delay: 400.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 400.ms),

        const SizedBox(height: AppSizes.paddingSmall),

        // Feature highlights with icons
        Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFeatureHighlight(
                  icon: IconHelper.getUIIcon('quiz'),
                  title: '20+ Catégories',
                  subtitle: 'Variées',
                ),
                _buildFeatureHighlight(
                  icon: IconHelper.getUIIcon('timer'),
                  title: 'Rapide & Fun',
                  subtitle: 'Questions',
                ),
                _buildFeatureHighlight(
                  icon: IconHelper.getUIIcon('score'),
                  title: 'Suivi Progrès',
                  subtitle: 'Personnel',
                ),
              ],
            )
            .animate()
            .fadeIn(duration: 600.ms, delay: 600.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 600.ms),
      ],
    );
  }

  Widget _buildMenuOptions() {
    return Column(
      children: [
        AnimationConfiguration.staggeredList(
          position: 1,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: SizedBox(
                height: 120,
                child: AppCard(
                  gradient: AppColors.primaryGradient,
                  child: CustomButton(
                    text: AppStrings.startQuiz,
                    icon: IconHelper.getUIIcon('start'),
                    onPressed: () => _navigateToQuizSetup(),
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        AnimationConfiguration.staggeredList(
          position: 2,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        gradient: AppColors.secondaryGradient,
                        child: CustomButton(
                          text: AppStrings.viewHistory,
                          icon: IconHelper.getUIIcon('history'),
                          onPressed: () => _navigateToHistory(),
                          backgroundColor: Colors.transparent,
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingMedium),
                    Expanded(
                      child: AppCard(
                        gradient: AppColors.accentGradient,
                        child: CustomButton(
                          text: AppStrings.about,
                          icon: IconHelper.getUIIcon('about'),
                          onPressed: () => _navigateToAbout(),
                          backgroundColor: Colors.transparent,
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.quizHistory.isNotEmpty) {
          final lastQuiz = quizProvider.quizHistory.first;
          return AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        IconHelper.getUIIcon('history'),
                        color: ThemeHelper.getPrimaryColor(context),
                        size: AppSizes.iconSize,
                      ),
                      const SizedBox(width: AppSizes.paddingSmall),
                      Text(
                        'Dernier quiz',
                        style: ThemeHelper.getHeadlineStyle(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            IconHelper.getCategoryIcon(lastQuiz.category),
                            size: AppSizes.iconSizeSmall,
                            color:
                                ThemeHelper.getSecondaryTextStyle(
                                  context,
                                ).color,
                          ),
                          const SizedBox(width: AppSizes.paddingXSmall),
                          Text(
                            lastQuiz.category,
                            style: ThemeHelper.getSecondaryTextStyle(context),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            lastQuiz.isPassed
                                ? IconHelper.getUIIcon('success')
                                : IconHelper.getUIIcon('error'),
                            size: AppSizes.iconSizeSmall,
                            color:
                                lastQuiz.isPassed
                                    ? ThemeHelper.getCorrectAnswerColor(context)
                                    : ThemeHelper.getIncorrectAnswerColor(
                                      context,
                                    ),
                          ),
                          const SizedBox(width: AppSizes.paddingXSmall),
                          Text(
                            '${lastQuiz.score}/${lastQuiz.totalQuestions}',
                            style: ThemeHelper.getBodyStyle(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  lastQuiz.isPassed
                                      ? ThemeHelper.getCorrectAnswerColor(
                                        context,
                                      )
                                      : ThemeHelper.getIncorrectAnswerColor(
                                        context,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFeatureHighlight({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ThemeHelper.getPrimaryColor(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: ThemeHelper.getPrimaryColor(context),
            size: AppSizes.iconSize,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Text(
          title,
          style: ThemeHelper.getBodyStyle(
            context,
          ).copyWith(fontWeight: FontWeight.w600, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: ThemeHelper.getSecondaryTextStyle(
            context,
          ).copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _navigateToQuizSetup() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const QuizSetupScreen()));
  }

  void _navigateToHistory() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const HistoryScreen()));
  }

  void _navigateToAbout() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AboutScreen()));
  }

  void _navigateToSettings() async {
    final settings = Provider.of<SettingsService>(context, listen: false);

    // Feedback haptique et sonore
    await HapticService().selectionVibration(
      enabled: settings.vibrationEnabled,
    );
    await AudioService().playSelectionSound(enabled: settings.soundEnabled);

    if (mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
    }
  }
}
