import 'package:flutter/material.dart';

/// Helper class pour obtenir les couleurs du thème actuel
class ThemeHelper {
  /// Obtient les couleurs du thème actuel
  static ColorScheme getColorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

  /// Obtient les couleurs de texte du thème actuel
  static TextTheme getTextTheme(BuildContext context) {
    return Theme.of(context).textTheme;
  }

  /// Vérifie si le thème actuel est sombre
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Couleurs adaptatives selon le thème
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getOnPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }

  static Color getOnSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSecondary;
  }

  static Color getOnBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.onBackground;
  }

  static Color getOnSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  static Color getOnErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.onError;
  }

  /// Couleurs spécifiques pour les réponses - Améliorées pour le mode sombre
  static Color getCorrectAnswerColor(BuildContext context) {
    return isDarkMode(context)
        ? const Color(0xFF34D399) // Plus lumineux en mode sombre
        : const Color(0xFF059669);
  }

  static Color getIncorrectAnswerColor(BuildContext context) {
    return isDarkMode(context)
        ? const Color(0xFFFF6B6B) // Plus doux en mode sombre
        : const Color(0xFFDC2626);
  }

  static Color getSelectedAnswerColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getUnselectedAnswerColor(BuildContext context) {
    return isDarkMode(context)
        ? Theme.of(context)
            .colorScheme
            .surfaceContainerHighest // Utilise la couleur du thème mise à jour
        : const Color(0xFFF8FAFC);
  }

  /// Couleurs pour les cartes et containers - Améliorées
  static Color getQuizCardColor(BuildContext context) {
    return isDarkMode(context)
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Theme.of(context).colorScheme.surface;
  }

  static Color getAnswerCardColor(
    BuildContext context, {
    bool isSelected = false,
    bool isCorrect = false,
    bool isIncorrect = false,
  }) {
    if (isCorrect) {
      return getCorrectAnswerColor(context).withValues(alpha: 0.15);
    } else if (isIncorrect) {
      return getIncorrectAnswerColor(context).withValues(alpha: 0.15);
    } else if (isSelected) {
      return Theme.of(context).colorScheme.primaryContainer;
    } else {
      return isDarkMode(context)
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).colorScheme.surface;
    }
  }

  /// Dégradés adaptatifs
  static LinearGradient getPrimaryGradient(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primary, primaryContainer],
      stops: const [0.0, 1.0],
    );
  }

  static LinearGradient getBackgroundGradient(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final surfaceContainer = Theme.of(context).colorScheme.surfaceContainer;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [surface, surfaceContainer],
      stops: const [0.0, 1.0],
    );
  }

  static LinearGradient getSuccessGradient(BuildContext context) {
    final successColor = getCorrectAnswerColor(context);
    final successLight =
        isDarkMode(context) ? const Color(0xFF34D399) : const Color(0xFF10B981);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [successColor, successLight],
      stops: const [0.0, 1.0],
    );
  }

  static LinearGradient getErrorGradient(BuildContext context) {
    final errorColor = getIncorrectAnswerColor(context);
    final errorLight =
        isDarkMode(context) ? const Color(0xFFF87171) : const Color(0xFFEF4444);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [errorColor, errorLight],
      stops: const [0.0, 1.0],
    );
  }

  /// Styles de texte adaptatifs
  static TextStyle getHeadlineStyle(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle();
  }

  static TextStyle getBodyStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ) ??
        const TextStyle();
  }

  static TextStyle getSecondaryTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ) ??
        const TextStyle();
  }

  /// Couleurs pour les cartes et containers
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).dividerColor;
  }

  /// Couleurs pour les icônes
  static Color getIconColor(BuildContext context) {
    return Theme.of(context).iconTheme.color ??
        Theme.of(context).colorScheme.onSurface;
  }

  static Color getPrimaryIconColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Couleurs pour les boutons
  static Color getButtonBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getButtonTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }

  static Color getSecondaryButtonBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color getSecondaryButtonTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSecondary;
  }

  /// Couleurs pour les bordures
  static Color getBorderColor(BuildContext context) {
    return isDarkMode(context)
        ? const Color(0xFF374151)
        : const Color(0xFFE5E7EB);
  }

  static Color getFocusedBorderColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Couleurs pour les états (hover, pressed, etc.)
  static Color getHoverColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);
  }

  static Color getPressedColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);
  }

  static Color getDisabledColor(BuildContext context) {
    return Theme.of(context).disabledColor;
  }

  /// Couleurs pour les ombres
  static Color getShadowColor(BuildContext context) {
    return isDarkMode(context)
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.1);
  }

  /// Couleurs pour les indicateurs de progression
  static Color getProgressIndicatorColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getProgressBackgroundColor(BuildContext context) {
    return isDarkMode(context)
        ? const Color(0xFF374151)
        : const Color(0xFFE5E7EB);
  }
}
