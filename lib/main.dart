import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/quiz_provider.dart';
import 'services/settings_service.dart';
import 'services/audio_service.dart';
import 'services/haptic_service.dart';
import 'screens/home_screen.dart';
import 'theme/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les services
  final settingsService = SettingsService();
  await settingsService.initialize();

  await AudioService().initialize();
  await HapticService().initialize();

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
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Quiz App',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
