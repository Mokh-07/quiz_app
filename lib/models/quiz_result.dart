import 'question.dart';
import 'category.dart';

class QuizResult {
  final List<Question> questions;
  final List<String> userAnswers;
  final int score;
  final int totalQuestions;
  final String category;
  final Difficulty difficulty;
  final DateTime completedAt;
  final Duration timeTaken;

  QuizResult({
    required this.questions,
    required this.userAnswers,
    required this.score,
    required this.totalQuestions,
    required this.category,
    required this.difficulty,
    required this.completedAt,
    required this.timeTaken,
  });

  // Calcule le pourcentage de réussite
  double get percentage => totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  // Retourne le nombre de réponses incorrectes
  int get incorrectAnswers => totalQuestions - score;

  // Vérifie si le quiz est réussi (plus de 50%)
  bool get isPassed => percentage >= 50;

  // Retourne une évaluation textuelle du résultat
  String get evaluation {
    if (percentage >= 90) return 'Excellent !';
    if (percentage >= 80) return 'Très bien !';
    if (percentage >= 70) return 'Bien !';
    if (percentage >= 60) return 'Assez bien';
    if (percentage >= 50) return 'Passable';
    return 'À améliorer';
  }

  // Factory constructor pour créer un QuizResult à partir d'un JSON
  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q))
              .toList() ??
          [],
      userAnswers: (json['user_answers'] as List<dynamic>?)
              ?.map((answer) => answer.toString())
              .toList() ??
          [],
      score: json['score'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      category: json['category'] ?? '',
      difficulty: Difficulty.fromString(json['difficulty'] ?? 'easy'),
      completedAt: DateTime.parse(json['completed_at'] ?? DateTime.now().toIso8601String()),
      timeTaken: Duration(seconds: json['time_taken_seconds'] ?? 0),
    );
  }

  // Convertit le QuizResult en JSON
  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((q) => q.toJson()).toList(),
      'user_answers': userAnswers,
      'score': score,
      'total_questions': totalQuestions,
      'category': category,
      'difficulty': difficulty.value,
      'completed_at': completedAt.toIso8601String(),
      'time_taken_seconds': timeTaken.inSeconds,
    };
  }

  @override
  String toString() {
    return 'QuizResult{score: $score/$totalQuestions (${percentage.toStringAsFixed(1)}%), category: $category, difficulty: ${difficulty.displayName}}';
  }
}
