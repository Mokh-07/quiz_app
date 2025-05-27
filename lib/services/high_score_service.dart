import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/high_score.dart';
import '../models/quiz_result.dart';

/// Service pour gérer les meilleurs scores localement par utilisateur
class HighScoreService extends ChangeNotifier {
  static const String _highScoresKey = 'high_scores';

  late SharedPreferences _prefs;
  Map<String, HighScore> _highScores = {};
  bool _isInitialized = false;
  String? _currentUserId; // ID de l'utilisateur Firebase actuel

  // Getters
  Map<String, HighScore> get highScores => Map.unmodifiable(_highScores);
  bool get isInitialized => _isInitialized;

  /// Définit l'utilisateur actuel pour le stockage des données
  void setCurrentUser(String? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      // Recharger les scores pour ce nouvel utilisateur
      if (_isInitialized) {
        _loadHighScores();
      }
    }
  }

  /// Initialise le service avec les scores sauvegardés
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadHighScores();
    _isInitialized = true;
    notifyListeners();
  }

  /// Obtient la clé de stockage pour l'utilisateur actuel
  String _getUserStorageKey() {
    if (_currentUserId != null) {
      return '${_highScoresKey}_$_currentUserId';
    }
    return _highScoresKey; // Fallback pour les utilisateurs non connectés
  }

  /// Charge les meilleurs scores depuis le stockage local
  Future<void> _loadHighScores() async {
    try {
      final String storageKey = _getUserStorageKey();
      final String? scoresJson = _prefs.getString(storageKey);
      if (scoresJson != null) {
        final Map<String, dynamic> scoresMap = json.decode(scoresJson);
        _highScores = scoresMap.map(
          (key, value) => MapEntry(key, HighScore.fromJson(value)),
        );
      } else {
        _highScores = {};
      }
      notifyListeners();

      if (kDebugMode) {
        print(
          '✅ Scores chargés pour utilisateur: $_currentUserId (${_highScores.length} scores)',
        );
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des scores: $e');
      _highScores = {};
    }
  }

  /// Sauvegarde les meilleurs scores dans le stockage local
  Future<void> _saveHighScores() async {
    try {
      final String storageKey = _getUserStorageKey();
      final Map<String, dynamic> scoresMap = _highScores.map(
        (key, score) => MapEntry(key, score.toJson()),
      );
      await _prefs.setString(storageKey, json.encode(scoresMap));

      if (kDebugMode) {
        print('✅ Scores sauvegardés pour utilisateur: $_currentUserId');
      }
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des scores: $e');
    }
  }

  /// Vérifie et met à jour le meilleur score pour une catégorie/difficulté
  Future<bool> checkAndUpdateHighScore(QuizResult result) async {
    final String categoryName = result.category;
    final String difficulty = result.difficulty.value;
    final String key = '${categoryName}_$difficulty';

    final HighScore newScore = HighScore(
      categoryName: categoryName,
      difficulty: difficulty,
      score: result.score,
      totalQuestions: result.totalQuestions,
      percentage: result.percentage,
      date: result.completedAt,
    );

    final HighScore? currentBest = _highScores[key];

    // Si pas de score existant ou si le nouveau score est meilleur
    if (currentBest == null || newScore.isBetterThan(currentBest)) {
      _highScores[key] = newScore;
      await _saveHighScores();
      notifyListeners();
      return true; // Nouveau record !
    }

    return false; // Pas de nouveau record
  }

  /// Obtient le meilleur score pour une catégorie et difficulté spécifiques
  HighScore? getHighScore(String categoryName, String difficulty) {
    final String key = '${categoryName}_$difficulty';
    return _highScores[key];
  }

  /// Obtient tous les meilleurs scores pour une catégorie donnée
  List<HighScore> getHighScoresForCategory(String categoryName) {
    return _highScores.values
        .where((score) => score.categoryName == categoryName)
        .toList()
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
  }

  /// Obtient tous les meilleurs scores pour une difficulté donnée
  List<HighScore> getHighScoresForDifficulty(String difficulty) {
    return _highScores.values
        .where((score) => score.difficulty == difficulty)
        .toList()
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
  }

  /// Obtient tous les meilleurs scores triés par pourcentage décroissant
  List<HighScore> getAllHighScores() {
    final List<HighScore> scores = _highScores.values.toList();
    scores.sort((a, b) => b.percentage.compareTo(a.percentage));
    return scores;
  }

  /// Obtient les top N meilleurs scores
  List<HighScore> getTopScores(int limit) {
    final List<HighScore> allScores = getAllHighScores();
    return allScores.take(limit).toList();
  }

  /// Vérifie si un score donné serait un nouveau record
  bool wouldBeNewRecord(
    String categoryName,
    String difficulty,
    double percentage,
  ) {
    final HighScore? currentBest = getHighScore(categoryName, difficulty);
    return currentBest == null || percentage > currentBest.percentage;
  }

  /// Obtient le nombre total de records établis
  int get totalRecords => _highScores.length;

  /// Obtient la moyenne de tous les meilleurs scores
  double get averageScore {
    if (_highScores.isEmpty) return 0.0;
    final double total = _highScores.values
        .map((score) => score.percentage)
        .reduce((a, b) => a + b);
    return total / _highScores.length;
  }

  /// Remet à zéro tous les meilleurs scores
  Future<void> resetAllHighScores() async {
    _highScores.clear();
    await _prefs.remove(_highScoresKey);
    notifyListeners();
  }

  /// Supprime le meilleur score pour une catégorie/difficulté spécifique
  Future<void> removeHighScore(String categoryName, String difficulty) async {
    final String key = '${categoryName}_$difficulty';
    if (_highScores.containsKey(key)) {
      _highScores.remove(key);
      await _saveHighScores();
      notifyListeners();
    }
  }

  /// Exporte tous les scores au format JSON
  String exportScores() {
    final Map<String, dynamic> exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'totalScores': _highScores.length,
      'scores': _highScores.map((key, score) => MapEntry(key, score.toJson())),
    };
    return json.encode(exportData);
  }

  /// Importe des scores depuis un JSON
  Future<bool> importScores(String jsonData) async {
    try {
      final Map<String, dynamic> importData = json.decode(jsonData);
      final Map<String, dynamic> scoresData = importData['scores'];

      final Map<String, HighScore> importedScores = scoresData.map(
        (key, value) => MapEntry(key, HighScore.fromJson(value)),
      );

      // Fusionner avec les scores existants (garder les meilleurs)
      for (final entry in importedScores.entries) {
        final String key = entry.key;
        final HighScore importedScore = entry.value;
        final HighScore? currentScore = _highScores[key];

        if (currentScore == null || importedScore.isBetterThan(currentScore)) {
          _highScores[key] = importedScore;
        }
      }

      await _saveHighScores();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'importation des scores: $e');
      return false;
    }
  }
}
