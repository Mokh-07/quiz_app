import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/quiz_provider.dart';
import 'services/settings_service.dart';
import 'services/haptic_service.dart';
import 'services/simple_audio_service.dart';
import 'services/localization_service.dart';
import 'services/high_score_service.dart';
import 'services/auth_service.dart';
import 'services/firebase_auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/high_scores_screen.dart';
import 'theme/app_themes.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les services en parallèle pour de meilleures performances
  final settingsService = SettingsService();
  final highScoreService = HighScoreService();
  final authService = AuthService();
  final firebaseAuthService = FirebaseAuthService();

  // Initialisation parallèle des services critiques
  await Future.wait([
    settingsService.initialize(),
    highScoreService.initialize(),
    authService.initialize(),
  ]);

  // Initialisation Firebase séparément (peut être plus lente)
  await firebaseAuthService.initialize();

  // Initialisation des services légers en parallèle
  await Future.wait([
    HapticService().initialize(),
    SimpleAudioService().initialize(),
    LocalizationService().initialize(),
  ]);

  // Créer le QuizProvider et connecter les services
  final quizProvider = QuizProvider();
  quizProvider.setHighScoreService(highScoreService);

  // Connecter les services au FirebaseAuthService pour la synchronisation
  firebaseAuthService.connectServices(
    highScoreService: highScoreService,
    quizProvider: quizProvider,
  );

  runApp(
    QuizApp(
      settingsService: settingsService,
      highScoreService: highScoreService,
      quizProvider: quizProvider,
      authService: authService,
      firebaseAuthService: firebaseAuthService,
    ),
  );
}

class QuizApp extends StatelessWidget {
  final SettingsService settingsService;
  final HighScoreService highScoreService;
  final QuizProvider quizProvider;
  final AuthService authService;
  final FirebaseAuthService firebaseAuthService;

  const QuizApp({
    super.key,
    required this.settingsService,
    required this.highScoreService,
    required this.quizProvider,
    required this.authService,
    required this.firebaseAuthService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: quizProvider),
        ChangeNotifierProvider.value(value: settingsService),
        ChangeNotifierProvider.value(value: highScoreService),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: firebaseAuthService),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return Consumer<LocalizationService>(
            builder: (context, localization, child) {
              return Consumer<AuthService>(
                builder: (context, auth, child) {
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
                    home:
                        auth.isLoading
                            ? const _LoadingScreen()
                            : auth.isAuthenticated
                            ? const HomeScreen()
                            : const AuthScreen(),
                    routes: {
                      '/auth': (context) => const AuthScreen(),
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
                                    ).pushNamedAndRemoveUntil(
                                      '/',
                                      (route) => false,
                                    );
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
              );
            },
          );
        },
      ),
    );
  }
}

/// Écran de chargement simple pendant l'initialisation de l'authentification
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('Chargement...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
