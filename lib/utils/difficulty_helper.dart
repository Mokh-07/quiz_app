import 'package:flutter/material.dart';
import '../models/category.dart';
import '../l10n/app_localizations.dart';

/// Helper pour obtenir les noms traduits des difficultés
class DifficultyHelper {
  static String getDisplayName(BuildContext context, Difficulty difficulty) {
    final localizations = AppLocalizations.of(context);
    
    switch (difficulty) {
      case Difficulty.easy:
        return localizations.easy;
      case Difficulty.medium:
        return localizations.medium;
      case Difficulty.hard:
        return localizations.hard;
    }
  }
}
