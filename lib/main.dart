import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/quiz_provider.dart';
import 'services/settings_service.dart';
import 'services/haptic_service.dart';
import 'services/simple_audio_service.dart';
import 'services/localization_service.dart';
import 'services/high_score_service.dart';
import 'screens/home_screen.dart';
import 'screens/high_scores_screen.dart';
import 'theme/app_themes.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les services
  final settingsService = SettingsService();
  await settingsService.initialize();

  final highScoreService = HighScoreService();
  await highScoreService.initialize();

  await HapticService().initialize();
  await SimpleAudioService().initialize();
  await LocalizationService().initialize();

  // Créer le QuizProvider et connecter le HighScoreService
  final quizProvider = QuizProvider();
  quizProvider.setHighScoreService(highScoreService);

  runApp(
    QuizApp(
      settingsService: settingsService,
      highScoreService: highScoreService,
      quizProvider: quizProvider,
    ),
  );
}

class QuizApp extends StatelessWidget {
  final SettingsService settingsService;
  final HighScoreService highScoreService;
  final QuizProvider quizProvider;

  const QuizApp({
    super.key,
    required this.settingsService,
    required this.highScoreService,
    required this.quizProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: quizProvider),
        ChangeNotifierProvider.value(value: settingsService),
        ChangeNotifierProvider.value(value: highScoreService),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
      ],
      child: Consumer2<SettingsService, LocalizationService>(
        builder: (context, settings, localization, child) {
          return MaterialApp(
            title: 'Quiz App',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            locale: localization.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            // Routes nommées pour une navigation plus robuste
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/home': (context) => const HomeScreen(),
              '/high-scores': (context) => const HighScoresScreen(),
            },
            // Gestion d'erreur globale pour la navigation
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              );
            },
            // Gestionnaire d'erreur global
            builder: (context, widget) {
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Une erreur est survenue',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushNamedAndRemoveUntil('/', (route) => false);
                          },
                          child: const Text('Retour à l\'accueil'),
                        ),
                      ],
                    ),
                  ),
                );
              };
              return widget!;
            },
          );
        },
      ),
    );
  }
}
