import 'package:html/parser.dart' as html_parser;

class Question {
  final String category;
  final String type;
  final String difficulty;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final List<String> allAnswers;

  Question({
    required this.category,
    required this.type,
    required this.difficulty,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  }) : allAnswers = _shuffleAnswers(correctAnswer, incorrectAnswers);

  // Mélange les réponses pour éviter que la bonne réponse soit toujours en première position
  static List<String> _shuffleAnswers(String correct, List<String> incorrect) {
    final List<String> answers = [correct, ...incorrect];
    answers.shuffle();
    return answers;
  }

  // Décode le HTML dans les textes (l'API OpenTDB encode certains caractères)
  static String _decodeHtml(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.documentElement?.text ?? htmlString;
  }

  // Factory constructor pour créer une Question à partir d'un JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      category: _decodeHtml(json['category'] ?? ''),
      type: json['type'] ?? '',
      difficulty: json['difficulty'] ?? '',
      question: _decodeHtml(json['question'] ?? ''),
      correctAnswer: _decodeHtml(json['correct_answer'] ?? ''),
      incorrectAnswers:
          (json['incorrect_answers'] as List<dynamic>?)
              ?.map((answer) => _decodeHtml(answer.toString()))
              .toList() ??
          [],
    );
  }

  // Convertit la Question en JSON
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'type': type,
      'difficulty': difficulty,
      'question': question,
      'correct_answer': correctAnswer,
      'incorrect_answers': incorrectAnswers,
    };
  }

  // Vérifie si une réponse est correcte
  bool isCorrectAnswer(String answer) {
    return answer == correctAnswer;
  }

  @override
  String toString() {
    return 'Question{category: $category, difficulty: $difficulty, question: $question}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question &&
          runtimeType == other.runtimeType &&
          question == other.question &&
          correctAnswer == other.correctAnswer;

  @override
  int get hashCode => question.hashCode ^ correctAnswer.hashCode;
}
