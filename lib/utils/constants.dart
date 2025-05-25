import 'package:flutter/material.dart';

// Couleurs de l'application - Thème Material 3 moderne
class AppColors {
  // Couleurs principales Material 3 - Palette Purple/Violet moderne
  static const Color primary = Color(0xFF7C3AED); // Violet profond
  static const Color primaryLight = Color(0xFFA855F7); // Violet clair
  static const Color primaryDark = Color(0xFF5B21B6); // Violet foncé
  static const Color primaryContainer = Color(0xFFEDE9FE); // Container violet

  // Couleurs secondaires - Palette Teal/Emerald
  static const Color secondary = Color(0xFF059669); // Emerald
  static const Color secondaryLight = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF047857);
  static const Color secondaryContainer = Color(0xFFD1FAE5);

  // Couleurs d'accent - Palette Rose/Pink
  static const Color accent = Color(0xFFE11D48); // Rose moderne
  static const Color accentLight = Color(0xFFF43F5E);
  static const Color accentContainer = Color(0xFFFFE4E6);

  // Couleurs de fond Material 3
  static const Color background = Color(0xFFFEFEFE);
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceVariant = Color(0xFFF4F4F5);
  static const Color outline = Color(0xFFE4E4E7);

  // Couleurs d'état améliorées
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFF10B981);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);

  // Couleurs pour les réponses avec Material 3
  static const Color correctAnswer = Color(0xFF059669);
  static const Color incorrectAnswer = Color(0xFFDC2626);
  static const Color selectedAnswer = Color(0xFF7C3AED);
  static const Color unselectedAnswer = Color(0xFFF8FAFC);
  static const Color answerHover = Color(0xFFF1F5F9);

  // Couleurs de texte Material 3
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Dégradés Material 3 modernes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
    stops: [0.0, 1.0],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
    stops: [0.0, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
    stops: [0.0, 1.0],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, surfaceVariant],
    stops: [0.0, 1.0],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successLight],
    stops: [0.0, 1.0],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, errorLight],
    stops: [0.0, 1.0],
  );

  // Nouveaux dégradés pour Material 3
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surface, surfaceVariant],
    stops: [0.0, 1.0],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [Color(0xFFE2E8F0), Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
    stops: [0.0, 0.5, 1.0],
  );
}

// Tailles et espacements Material 3
class AppSizes {
  // Espacements Material 3
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double paddingXXLarge = 48.0;

  // Rayons de bordure Material 3
  static const double borderRadius = 16.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusXLarge = 28.0;

  // Tailles d'icônes
  static const double iconSizeSmall = 16.0;
  static const double iconSize = 24.0;
  static const double iconSizeMedium = 28.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Hauteurs des composants
  static const double buttonHeight = 56.0; // Material 3 standard
  static const double buttonHeightSmall = 40.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 64.0;

  // Élévations Material 3
  static const double elevationNone = 0.0;
  static const double elevationSmall = 1.0;
  static const double elevationMedium = 3.0;
  static const double elevationLarge = 6.0;
  static const double cardElevation = 2.0;

  // Largeurs
  static const double maxContentWidth = 600.0;
  static const double minButtonWidth = 120.0;
}

// Styles de texte Material 3
class AppTextStyles {
  // Headlines Material 3
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Titres
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  // Corps de texte
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    letterSpacing: 0.4,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );

  // Styles personnalisés pour l'app
  static const TextStyle headline1 = headlineLarge;
  static const TextStyle headline2 = headlineMedium;
  static const TextStyle headline3 = headlineSmall;
  static const TextStyle bodyText1 = bodyLarge;
  static const TextStyle bodyText2 = bodyMedium;
  static const TextStyle button = labelLarge;
  static const TextStyle caption = bodySmall;
}

// Durées d'animation
class AppDurations {
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 500);
  static const Duration questionTimer = Duration(seconds: 30);
}

// Messages et textes
class AppStrings {
  static const String appName = 'Quiz App';
  static const String appDescription = 'Application de quiz interactive';

  // Écran d'accueil
  static const String welcomeTitle = 'Bienvenue dans Quiz App';
  static const String welcomeSubtitle =
      'Testez vos connaissances avec des questions variées';
  static const String startQuiz = 'Commencer un quiz';
  static const String viewHistory = 'Voir l\'historique';
  static const String about = 'À propos';

  // Configuration du quiz
  static const String selectCategory = 'Choisir une catégorie';
  static const String selectDifficulty = 'Choisir la difficulté';
  static const String selectQuestionCount = 'Nombre de questions';
  static const String startQuizButton = 'Démarrer le quiz';

  // Quiz
  static const String question = 'Question';
  static const String timeRemaining = 'Temps restant';
  static const String nextQuestion = 'Question suivante';
  static const String finishQuiz = 'Terminer le quiz';

  // Interface de quiz améliorée
  static const String multipleChoiceQuestion = 'Question à choix multiple';
  static const String chooseOneAnswer = 'Choisissez UNE seule réponse';
  static const String answerOptions = 'Options de réponse';

  // Résultats
  static const String quizCompleted = 'Quiz terminé !';
  static const String yourScore = 'Votre score';
  static const String correctAnswers = 'Bonnes réponses';
  static const String incorrectAnswers = 'Mauvaises réponses';
  static const String timeTaken = 'Temps écoulé';
  static const String playAgain = 'Rejouer';
  static const String backToHome = 'Retour à l\'accueil';

  // Erreurs
  static const String noInternetConnection = 'Pas de connexion internet';
  static const String loadingError = 'Erreur de chargement';
  static const String tryAgain = 'Réessayer';
  static const String noQuestionsAvailable = 'Aucune question disponible';

  // Erreurs spécifiques aux questions à choix multiples
  static const String noMultipleChoiceQuestions =
      'Aucune question à choix multiples disponible';
  static const String insufficientMultipleChoiceQuestions =
      'Pas assez de questions à choix multiples';
  static const String suggestionsTitle = 'Suggestions :';
  static const String tryDifferentCategory = '• Essayez une autre catégorie';
  static const String tryDifferentDifficulty =
      '• Changez le niveau de difficulté';
  static const String tryAllCategories =
      '• Sélectionnez "Toutes les catégories"';
  static const String reduceQuestionCount = '• Réduisez le nombre de questions';

  // Historique
  static const String quizHistory = 'Historique des quiz';
  static const String noHistoryAvailable = 'Aucun historique disponible';
  static const String clearHistory = 'Effacer l\'historique';
  static const String confirmClearHistory =
      'Êtes-vous sûr de vouloir effacer tout l\'historique ?';

  // Général
  static const String yes = 'Oui';
  static const String no = 'Non';
  static const String cancel = 'Annuler';
  static const String confirm = 'Confirmer';
  static const String loading = 'Chargement...';
  static const String retry = 'Réessayer';
}

// Nombres de questions disponibles
class QuestionCounts {
  static const List<int> available = [5, 10, 15, 20, 25];
  static const int defaultCount = 10;
  static const int minCount = 5;
  static const int maxCount = 25;
}

// Configuration de l'API
class ApiConfig {
  static const String baseUrl = 'https://opentdb.com/api.php';
  static const String categoriesUrl = 'https://opentdb.com/api_category.php';
  static const Duration timeout = Duration(seconds: 10);
}
