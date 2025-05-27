import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/category.dart';
import '../models/quiz_result.dart';
import 'api_service.dart';
import 'storage_service.dart';

class QuizProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // État des catégories
  List<QuizCategory> _categories = [];
  bool _categoriesLoading = false;
  String? _categoriesError;

  // État du quiz actuel
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  List<String> _userAnswers = [];
  bool _quizLoading = false;
  String? _quizError;
  DateTime? _quizStartTime;

  // Paramètres du quiz
  int _selectedCategoryId = 0;
  Difficulty _selectedDifficulty = Difficulty.easy;
  int _numberOfQuestions = 10;

  // Résultats
  List<QuizResult> _quizHistory = [];
  bool _resultsLoading = false;

  // Getters
  List<QuizCategory> get categories => _categories;
  bool get categoriesLoading => _categoriesLoading;
  String? get categoriesError => _categoriesError;

  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  Question? get currentQuestion =>
      _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;
  List<String> get userAnswers => _userAnswers;
  bool get quizLoading => _quizLoading;
  String? get quizError => _quizError;
  bool get isQuizCompleted => _currentQuestionIndex >= _questions.length;
  int get questionsAnswered => _userAnswers.length;
  int get questionsRemaining => _questions.length - _userAnswers.length;

  int get selectedCategoryId => _selectedCategoryId;
  Difficulty get selectedDifficulty => _selectedDifficulty;
  int get numberOfQuestions => _numberOfQuestions;

  List<QuizResult> get quizHistory => _quizHistory;
  bool get resultsLoading => _resultsLoading;

  // Charge les catégories depuis l'API
  Future<void> loadCategories() async {
    _categoriesLoading = true;
    _categoriesError = null;
    notifyListeners();

    try {
      _categories = await _apiService.getCategories();
      // Ajouter une catégorie "Toutes" au début
      _categories.insert(
        0,
        const QuizCategory(id: 0, name: 'Toutes les catégories'),
      );
    } catch (e) {
      _categoriesError = e.toString();
    } finally {
      _categoriesLoading = false;
      notifyListeners();
    }
  }

  // Met à jour les paramètres du quiz
  void updateQuizSettings({
    int? categoryId,
    Difficulty? difficulty,
    int? numberOfQuestions,
  }) {
    if (categoryId != null) _selectedCategoryId = categoryId;
    if (difficulty != null) _selectedDifficulty = difficulty;
    if (numberOfQuestions != null) _numberOfQuestions = numberOfQuestions;
    notifyListeners();
  }

  // Démarre un nouveau quiz avec stratégies de fallback automatiques
  Future<void> startQuiz() async {
    _quizLoading = true;
    _quizError = null;
    _questions.clear();
    _userAnswers.clear();
    _currentQuestionIndex = 0;
    notifyListeners();

    try {
      // Essayer de récupérer les questions avec stratégies de fallback automatiques
      _questions = await _getQuestionsWithFallback();

      // Validation finale des questions reçues
      final validQuestions =
          _questions
              .where(
                (q) =>
                    q.type.toLowerCase() == 'multiple' &&
                    q.incorrectAnswers.length >= 3,
              )
              .toList();

      if (validQuestions.isEmpty) {
        _quizError =
            'Impossible de trouver des questions à choix multiples.\n\n'
            'Suggestions :\n'
            '• Vérifiez votre connexion internet\n'
            '• Essayez "Toutes les catégories"\n'
            '• Réduisez le nombre de questions';
        notifyListeners();
        return;
      }

      // Utiliser les questions valides (même si moins que demandé)
      _questions = validQuestions.take(_numberOfQuestions).toList();
      _quizStartTime = DateTime.now();
    } catch (e) {
      _quizError =
          'Erreur lors du chargement du quiz: ${e.toString()}\n\n'
          'Suggestions :\n'
          '• Vérifiez votre connexion internet\n'
          '• Essayez une autre catégorie\n'
          '• Réessayez dans quelques instants';
    } finally {
      _quizLoading = false;
      notifyListeners();
    }
  }

  // Méthode privée pour récupérer les questions avec stratégies de fallback
  Future<List<Question>> _getQuestionsWithFallback() async {
    List<Question> questions = [];

    // Stratégie 1: Essayer avec les paramètres originaux
    try {
      questions = await _apiService.getQuestions(
        amount: _numberOfQuestions,
        categoryId: _selectedCategoryId > 0 ? _selectedCategoryId : null,
        difficulty: _selectedDifficulty,
        type: QuestionType.multiple,
      );

      final validQuestions =
          questions
              .where(
                (q) =>
                    q.type.toLowerCase() == 'multiple' &&
                    q.incorrectAnswers.length >= 3,
              )
              .toList();

      if (validQuestions.length >= _numberOfQuestions) {
        return validQuestions;
      }

      questions = validQuestions;
    } catch (e) {
      // Continuer avec les stratégies de fallback
    }

    // Stratégie 2: Essayer sans contrainte de difficulté
    if (questions.length < _numberOfQuestions) {
      try {
        final fallbackQuestions = await _apiService.getQuestions(
          amount: _numberOfQuestions * 2,
          categoryId: _selectedCategoryId > 0 ? _selectedCategoryId : null,
          difficulty: null, // Supprimer la contrainte de difficulté
          type: QuestionType.multiple,
        );

        final validQuestions =
            fallbackQuestions
                .where(
                  (q) =>
                      q.type.toLowerCase() == 'multiple' &&
                      q.incorrectAnswers.length >= 3,
                )
                .toList();

        questions.addAll(validQuestions);
        questions = _removeDuplicateQuestions(questions);

        if (questions.length >= _numberOfQuestions) {
          return questions;
        }
      } catch (e) {
        // Continuer avec la stratégie suivante
      }
    }

    // Stratégie 3: Essayer sans contrainte de catégorie
    if (questions.length < _numberOfQuestions) {
      try {
        final fallbackQuestions = await _apiService.getQuestions(
          amount: _numberOfQuestions * 2,
          categoryId: null, // Supprimer la contrainte de catégorie
          difficulty: _selectedDifficulty,
          type: QuestionType.multiple,
        );

        final validQuestions =
            fallbackQuestions
                .where(
                  (q) =>
                      q.type.toLowerCase() == 'multiple' &&
                      q.incorrectAnswers.length >= 3,
                )
                .toList();

        questions.addAll(validQuestions);
        questions = _removeDuplicateQuestions(questions);

        if (questions.length >= _numberOfQuestions) {
          return questions;
        }
      } catch (e) {
        // Continuer avec la stratégie suivante
      }
    }

    // Stratégie 4: Essayer sans aucune contrainte (sauf le type)
    if (questions.length < _numberOfQuestions) {
      try {
        final fallbackQuestions = await _apiService.getQuestions(
          amount: _numberOfQuestions * 3,
          categoryId: null,
          difficulty: null,
          type: QuestionType.multiple,
        );

        final validQuestions =
            fallbackQuestions
                .where(
                  (q) =>
                      q.type.toLowerCase() == 'multiple' &&
                      q.incorrectAnswers.length >= 3,
                )
                .toList();

        questions.addAll(validQuestions);
        questions = _removeDuplicateQuestions(questions);
      } catch (e) {
        // Dernière tentative échouée
      }
    }

    return questions;
  }

  // Supprime les questions en double
  List<Question> _removeDuplicateQuestions(List<Question> questions) {
    final Set<String> seenQuestions = <String>{};
    return questions.where((question) {
      final questionKey = question.question.toLowerCase().trim();
      if (seenQuestions.contains(questionKey)) {
        return false;
      }
      seenQuestions.add(questionKey);
      return true;
    }).toList();
  }

  // Répond à une question
  void answerQuestion(String answer) {
    if (_currentQuestionIndex < _questions.length) {
      _userAnswers.add(answer);
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // Calcule et sauvegarde le résultat du quiz
  Future<QuizResult> completeQuiz() async {
    if (_quizStartTime == null) {
      throw Exception('Quiz non démarré');
    }

    final Duration timeTaken = DateTime.now().difference(_quizStartTime!);
    int score = 0;

    // Calcul du score
    for (int i = 0; i < _userAnswers.length && i < _questions.length; i++) {
      if (_questions[i].isCorrectAnswer(_userAnswers[i])) {
        score++;
      }
    }

    // Récupération du nom de la catégorie
    String categoryName = 'Toutes les catégories';
    if (_selectedCategoryId > 0) {
      final category = _categories.firstWhere(
        (cat) => cat.id == _selectedCategoryId,
        orElse: () => const QuizCategory(id: 0, name: 'Inconnue'),
      );
      categoryName = category.name;
    }

    final QuizResult result = QuizResult(
      questions: List.from(_questions),
      userAnswers: List.from(_userAnswers),
      score: score,
      totalQuestions: _questions.length,
      category: categoryName,
      difficulty: _selectedDifficulty,
      completedAt: DateTime.now(),
      timeTaken: timeTaken,
    );

    // Sauvegarde du résultat
    await _storageService.saveQuizResult(result);

    return result;
  }

  // Charge l'historique des quiz
  Future<void> loadQuizHistory() async {
    _resultsLoading = true;
    notifyListeners();

    try {
      _quizHistory = await _storageService.getAllQuizResults();
      // Trier par date décroissante
      _quizHistory.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    } catch (e) {
      debugPrint('Erreur lors du chargement de l\'historique: $e');
    } finally {
      _resultsLoading = false;
      notifyListeners();
    }
  }

  // Remet à zéro le quiz
  void resetQuiz() {
    try {
      _questions.clear();
      _userAnswers.clear();
      _currentQuestionIndex = 0;
      _quizError = null;
      _quizStartTime = null;
      _quizLoading = false;

      // S'assurer que tous les listeners sont notifiés
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la réinitialisation du quiz: $e');
      // Forcer la réinitialisation même en cas d'erreur
      _questions = [];
      _userAnswers = [];
      _currentQuestionIndex = 0;
      _quizError = null;
      _quizStartTime = null;
      _quizLoading = false;
      notifyListeners();
    }
  }

  // Supprime tout l'historique
  Future<void> clearHistory() async {
    await _storageService.clearAllResults();
    _quizHistory.clear();
    notifyListeners();
  }
}
