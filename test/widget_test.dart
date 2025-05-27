// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:quiz_app/services/settings_service.dart';
import 'package:quiz_app/services/high_score_service.dart';
import 'package:quiz_app/services/quiz_provider.dart';
import 'package:quiz_app/services/auth_service.dart';
import 'package:quiz_app/services/firebase_auth_service.dart';
import 'package:quiz_app/services/localization_service.dart';
import 'package:quiz_app/screens/auth_screen.dart';

void main() {
  testWidgets('Quiz app smoke test', (WidgetTester tester) async {
    // Créer les instances des services requis pour le test
    final settingsService = SettingsService();
    final highScoreService = HighScoreService();
    final quizProvider = QuizProvider();
    final authService = AuthService();
    final firebaseAuthService = FirebaseAuthService();
    final localizationService = LocalizationService();

    // Initialiser les services nécessaires pour le test (sans Firebase)
    await settingsService.initialize();
    await highScoreService.initialize();
    await authService.initialize();
    await localizationService.initialize();

    // Connecter les services
    quizProvider.setHighScoreService(highScoreService);

    // Build our app and trigger a frame avec une version simplifiée
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settingsService),
          ChangeNotifierProvider.value(value: quizProvider),
          ChangeNotifierProvider.value(value: highScoreService),
          ChangeNotifierProvider.value(value: authService),
          ChangeNotifierProvider.value(value: firebaseAuthService),
          ChangeNotifierProvider.value(value: localizationService),
        ],
        child: Consumer<SettingsService>(
          builder: (context, settings, child) {
            return MaterialApp(
              title: 'Quiz App Test',
              debugShowCheckedModeBanner: false,
              themeMode: settings.themeMode,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              home: const AuthScreen(),
            );
          },
        ),
      ),
    );

    // Attendre que l'app se charge complètement
    await tester.pumpAndSettle();

    // Verify that our app loads correctly.
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(AuthScreen), findsOneWidget);
  });
}
