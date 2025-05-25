import 'package:flutter/material.dart';
import '../models/category.dart';

/// Helper class for managing icons throughout the application
/// Provides consistent icon mapping for categories, difficulties, and UI elements
class IconHelper {
  // Private constructor to prevent instantiation
  IconHelper._();

  /// Maps category names to their corresponding icons
  /// Based on Open Trivia Database categories
  static const Map<String, IconData> _categoryIcons = {
    // Default/All categories
    'Toutes les catégories': Icons.apps,
    'Any Category': Icons.apps,
    
    // General Knowledge
    'General Knowledge': Icons.lightbulb,
    'Entertainment: Books': Icons.menu_book,
    'Entertainment: Film': Icons.movie,
    'Entertainment: Music': Icons.music_note,
    'Entertainment: Musicals & Theatres': Icons.theater_comedy,
    'Entertainment: Television': Icons.tv,
    'Entertainment: Video Games': Icons.videogame_asset,
    'Entertainment: Board Games': Icons.casino,
    'Entertainment: Comics': Icons.auto_awesome,
    'Entertainment: Japanese Anime & Manga': Icons.animation,
    'Entertainment: Cartoon & Animations': Icons.animation,
    
    // Science categories
    'Science & Nature': Icons.science,
    'Science: Computers': Icons.computer,
    'Science: Mathematics': Icons.calculate,
    'Science: Gadgets': Icons.devices,
    
    // Other subjects
    'Mythology': Icons.auto_stories,
    'Sports': Icons.sports_soccer,
    'Geography': Icons.public,
    'History': Icons.history_edu,
    'Politics': Icons.account_balance,
    'Art': Icons.palette,
    'Celebrities': Icons.star,
    'Animals': Icons.pets,
    'Vehicles': Icons.directions_car,
  };

  /// Maps difficulty levels to their corresponding icons
  static const Map<Difficulty, IconData> _difficultyIcons = {
    Difficulty.easy: Icons.sentiment_satisfied,
    Difficulty.medium: Icons.sentiment_neutral,
    Difficulty.hard: Icons.sentiment_very_dissatisfied,
  };

  /// Maps difficulty levels to their corresponding colors
  static const Map<Difficulty, Color> _difficultyColors = {
    Difficulty.easy: Color(0xFF059669), // Green
    Difficulty.medium: Color(0xFFD97706), // Orange
    Difficulty.hard: Color(0xFFDC2626), // Red
  };

  /// Common UI icons used throughout the app
  static const Map<String, IconData> uiIcons = {
    'quiz': Icons.quiz,
    'start': Icons.play_arrow,
    'settings': Icons.settings,
    'history': Icons.history,
    'about': Icons.info_outline,
    'theme_light': Icons.light_mode,
    'theme_dark': Icons.dark_mode,
    'sound_on': Icons.volume_up,
    'sound_off': Icons.volume_off,
    'vibration_on': Icons.vibration,
    'vibration_off': Icons.phone_android,
    'refresh': Icons.refresh,
    'error': Icons.error_outline,
    'success': Icons.check_circle,
    'warning': Icons.warning,
    'timer': Icons.timer,
    'score': Icons.emoji_events,
    'correct': Icons.check,
    'incorrect': Icons.close,
    'next': Icons.arrow_forward,
    'back': Icons.arrow_back,
    'home': Icons.home,
    'delete': Icons.delete,
    'clear': Icons.clear_all,
  };

  /// Gets the icon for a specific category
  /// Returns a default icon if category is not found
  static IconData getCategoryIcon(String categoryName) {
    return _categoryIcons[categoryName] ?? Icons.help_outline;
  }

  /// Gets the icon for a specific difficulty level
  static IconData getDifficultyIcon(Difficulty difficulty) {
    return _difficultyIcons[difficulty] ?? Icons.help_outline;
  }

  /// Gets the color for a specific difficulty level
  static Color getDifficultyColor(Difficulty difficulty) {
    return _difficultyColors[difficulty] ?? Colors.grey;
  }

  /// Gets a UI icon by name
  /// Returns a default icon if name is not found
  static IconData getUIIcon(String iconName) {
    return uiIcons[iconName] ?? Icons.help_outline;
  }

  /// Checks if a category has a custom icon
  static bool hasCategoryIcon(String categoryName) {
    return _categoryIcons.containsKey(categoryName);
  }

  /// Gets all available category icons as a map
  static Map<String, IconData> get allCategoryIcons => Map.from(_categoryIcons);

  /// Gets all available difficulty icons as a map
  static Map<Difficulty, IconData> get allDifficultyIcons => Map.from(_difficultyIcons);

  /// Helper method to get icon with fallback for category objects
  static IconData getCategoryIconFromObject(QuizCategory category) {
    return getCategoryIcon(category.name);
  }
}
