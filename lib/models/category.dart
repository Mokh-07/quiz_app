class QuizCategory {
  final int id;
  final String name;

  const QuizCategory({required this.id, required this.name});

  // Factory constructor pour créer une catégorie à partir d'un JSON
  factory QuizCategory.fromJson(Map<String, dynamic> json) {
    return QuizCategory(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  // Convertit la catégorie en JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  String toString() {
    return 'QuizCategory{id: $id, name: $name}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Énumération pour les niveaux de difficulté
enum Difficulty {
  easy('easy'),
  medium('medium'),
  hard('hard');

  const Difficulty(this.value);

  final String value;

  static Difficulty fromString(String value) {
    return Difficulty.values.firstWhere(
      (difficulty) => difficulty.value == value,
      orElse: () => Difficulty.easy,
    );
  }
}

// Extension pour obtenir le nom traduit de la difficulté
extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Facile';
      case Difficulty.medium:
        return 'Moyen';
      case Difficulty.hard:
        return 'Difficile';
    }
  }
}

// Énumération pour les types de questions
enum QuestionType {
  multiple('multiple', 'Choix multiple'),
  boolean('boolean', 'Vrai/Faux');

  const QuestionType(this.value, this.displayName);

  final String value;
  final String displayName;

  static QuestionType fromString(String value) {
    return QuestionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => QuestionType.multiple,
    );
  }
}
