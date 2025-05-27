/// Modèle pour représenter un meilleur score
class HighScore {
  final String categoryName;
  final String difficulty;
  final int score;
  final int totalQuestions;
  final double percentage;
  final DateTime date;

  const HighScore({
    required this.categoryName,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.date,
  });

  /// Crée un HighScore à partir d'un Map JSON
  factory HighScore.fromJson(Map<String, dynamic> json) {
    return HighScore(
      categoryName: json['categoryName'] as String,
      difficulty: json['difficulty'] as String,
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      percentage: json['percentage'] as double,
      date: DateTime.parse(json['date'] as String),
    );
  }

  /// Convertit le HighScore en Map JSON
  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'difficulty': difficulty,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'date': date.toIso8601String(),
    };
  }

  /// Crée une clé unique pour identifier le score par catégorie et difficulté
  String get key => '${categoryName}_$difficulty';

  /// Retourne une description formatée du score
  String get description => '$score/$totalQuestions (${percentage.toStringAsFixed(1)}%)';

  /// Compare deux scores pour déterminer lequel est meilleur
  bool isBetterThan(HighScore other) {
    // D'abord comparer le pourcentage
    if (percentage != other.percentage) {
      return percentage > other.percentage;
    }
    // Si même pourcentage, comparer le score absolu
    if (score != other.score) {
      return score > other.score;
    }
    // Si même score, le plus récent est meilleur
    return date.isAfter(other.date);
  }

  @override
  String toString() {
    return 'HighScore(category: $categoryName, difficulty: $difficulty, score: $description, date: ${date.toLocal()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HighScore &&
        other.categoryName == categoryName &&
        other.difficulty == difficulty &&
        other.score == score &&
        other.totalQuestions == totalQuestions &&
        other.percentage == percentage &&
        other.date == date;
  }

  @override
  int get hashCode {
    return Object.hash(
      categoryName,
      difficulty,
      score,
      totalQuestions,
      percentage,
      date,
    );
  }
}
