import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_result.dart';

class StorageService {
  static const String _scoresKey = 'quiz_scores';
  static const String _settingsKey = 'quiz_settings';

  String? _currentUserId; // ID de l'utilisateur Firebase actuel

  /// Définit l'utilisateur actuel pour le stockage des données
  void setCurrentUser(String? userId) {
    _currentUserId = userId;
  }

  /// Obtient la clé de stockage pour l'utilisateur actuel
  String _getUserStorageKey() {
    if (_currentUserId != null) {
      return '${_scoresKey}_$_currentUserId';
    }
    return _scoresKey; // Fallback pour les utilisateurs non connectés
  }

  // Sauvegarde un résultat de quiz
  Future<void> saveQuizResult(QuizResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String storageKey = _getUserStorageKey();
      final List<String> existingScores = prefs.getStringList(storageKey) ?? [];

      // Vérifier si ce résultat existe déjà (basé sur l'ID)
      final existingIds = <String>{};
      final filteredScores = <String>[];

      for (final scoreJson in existingScores) {
        try {
          final Map<String, dynamic> data = json.decode(scoreJson);
          final String existingId = data['id'] ?? '';
          if (existingId.isNotEmpty && !existingIds.contains(existingId)) {
            existingIds.add(existingId);
            filteredScores.add(scoreJson);
          }
        } catch (e) {
          // Ignorer les résultats corrompus
        }
      }

      // Ajouter le nouveau résultat seulement s'il n'existe pas déjà
      if (!existingIds.contains(result.id)) {
        filteredScores.add(json.encode(result.toJson()));
      }

      // Garder seulement les 50 derniers résultats pour éviter un stockage excessif
      if (filteredScores.length > 50) {
        filteredScores.removeRange(0, filteredScores.length - 50);
      }

      await prefs.setStringList(storageKey, filteredScores);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du résultat: $e');
    }
  }

  // Récupère tous les résultats de quiz
  Future<List<QuizResult>> getAllQuizResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String storageKey = _getUserStorageKey();
      final List<String> scoresJson = prefs.getStringList(storageKey) ?? [];

      return scoresJson
          .map((scoreJson) {
            try {
              final Map<String, dynamic> data = json.decode(scoreJson);
              return QuizResult.fromJson(data);
            } catch (e) {
              // Ignorer les résultats corrompus
              return null;
            }
          })
          .where((result) => result != null)
          .cast<QuizResult>()
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des résultats: $e');
    }
  }

  // Récupère les meilleurs scores par catégorie
  Future<Map<String, QuizResult>> getBestScoresByCategory() async {
    try {
      final List<QuizResult> allResults = await getAllQuizResults();
      final Map<String, QuizResult> bestScores = {};

      for (final result in allResults) {
        final String key = '${result.category}_${result.difficulty.value}';

        if (!bestScores.containsKey(key) ||
            result.percentage > bestScores[key]!.percentage) {
          bestScores[key] = result;
        }
      }

      return bestScores;
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des meilleurs scores: $e',
      );
    }
  }

  // Récupère le meilleur score global
  Future<QuizResult?> getBestOverallScore() async {
    try {
      final List<QuizResult> allResults = await getAllQuizResults();

      if (allResults.isEmpty) return null;

      return allResults.reduce(
        (current, next) =>
            current.percentage > next.percentage ? current : next,
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération du meilleur score: $e');
    }
  }

  // Supprime tous les résultats
  Future<void> clearAllResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String storageKey = _getUserStorageKey();
      await prefs.remove(storageKey);
    } catch (e) {
      throw Exception('Erreur lors de la suppression des résultats: $e');
    }
  }

  // Sauvegarde les paramètres de l'application
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, json.encode(settings));
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde des paramètres: $e');
    }
  }

  // Récupère les paramètres de l'application
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        return json.decode(settingsJson);
      }

      // Paramètres par défaut
      return {
        'sound_enabled': true,
        'vibration_enabled': true,
        'theme_mode': 'system', // system, light, dark
        'language': 'fr',
      };
    } catch (e) {
      // Retourner les paramètres par défaut en cas d'erreur
      return {
        'sound_enabled': true,
        'vibration_enabled': true,
        'theme_mode': 'system',
        'language': 'fr',
      };
    }
  }
}
