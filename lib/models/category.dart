class QuizCategory {
  final int id;
  final String name;

  const QuizCategory({
    required this.id,
    required this.name,
  });

  // Factory constructor pour créer une catégorie à partir d'un JSON
  factory QuizCategory.fromJson(Map<String, dynamic> json) {
    return QuizCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  // Convertit la catégorie en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
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
  easy('easy', 'Facile'),
  medium('medium', 'Moyen'),
  hard('hard', 'Difficile');

  const Difficulty(this.value, this.displayName);

  final String value;
  final String displayName;

  static Difficulty fromString(String value) {
    return Difficulty.values.firstWhere(
      (difficulty) => difficulty.value == value,
      orElse: () => Difficulty.easy,
    );
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
