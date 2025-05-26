import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/quiz_provider.dart';
import 'services/settings_service.dart';
import 'services/haptic_service.dart';
import 'services/simple_audio_service.dart';
import 'services/localization_service.dart';
import 'screens/home_screen.dart';
import 'theme/app_themes.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les services
  final settingsService = SettingsService();
  await settingsService.initialize();

  await HapticService().initialize();
  await SimpleAudioService().initialize();
  await LocalizationService().initialize();

  runApp(QuizApp(settingsService: settingsService));
}

class QuizApp extends StatelessWidget {
  final SettingsService settingsService;

  const QuizApp({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => QuizProvider()),
        ChangeNotifierProvider.value(value: settingsService),
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
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
