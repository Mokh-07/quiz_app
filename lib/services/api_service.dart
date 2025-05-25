import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import '../models/category.dart';

class ApiService {
  static const String _baseUrl = 'https://opentdb.com/api.php';
  static const String _categoriesUrl = 'https://opentdb.com/api_category.php';

  // Timeout pour les requêtes HTTP
  static const Duration _timeout = Duration(seconds: 10);

  // Récupère les catégories disponibles
  Future<List<QuizCategory>> getCategories() async {
    try {
      final response = await http
          .get(Uri.parse(_categoriesUrl))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> categoriesJson = data['trivia_categories'] ?? [];

        return categoriesJson
            .map((categoryJson) => QuizCategory.fromJson(categoryJson))
            .toList();
      } else {
        throw HttpException(
          'Erreur lors de la récupération des catégories: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const SocketException('Pas de connexion internet');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw Exception(
        'Erreur inattendue lors de la récupération des catégories: $e',
      );
    }
  }

  // Récupère les questions du quiz avec validation du type
  Future<List<Question>> getQuestions({
    required int amount,
    int? categoryId,
    Difficulty? difficulty,
    QuestionType? type,
  }) async {
    try {
      // Première tentative avec les paramètres spécifiés
      List<Question> questions = await _fetchQuestionsFromAPI(
        amount: amount,
        categoryId: categoryId,
        difficulty: difficulty,
        type: type,
      );

      // Validation du type de questions si spécifié
      if (type != null) {
        questions = _validateQuestionType(questions, type);

        // Si pas assez de questions du bon type, essayer des stratégies de fallback
        if (questions.length < amount) {
          questions = await _tryFallbackStrategies(
            amount: amount,
            categoryId: categoryId,
            difficulty: difficulty,
            type: type,
            currentQuestions: questions,
          );
        }
      }

      if (questions.isEmpty) {
        throw Exception(
          'Aucune question à choix multiples disponible pour ces critères',
        );
      }

      return questions.take(amount).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Méthode privée pour récupérer les questions de l'API
  Future<List<Question>> _fetchQuestionsFromAPI({
    required int amount,
    int? categoryId,
    Difficulty? difficulty,
    QuestionType? type,
  }) async {
    try {
      // Construction de l'URL avec les paramètres
      final Map<String, String> queryParams = {'amount': amount.toString()};

      if (categoryId != null) {
        queryParams['category'] = categoryId.toString();
      }

      if (difficulty != null) {
        queryParams['difficulty'] = difficulty.value;
      }

      if (type != null) {
        queryParams['type'] = type.value;
      }

      final Uri uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Vérification du code de réponse de l'API
        final int responseCode = data['response_code'] ?? 1;

        switch (responseCode) {
          case 0: // Succès
            final List<dynamic> questionsJson = data['results'] ?? [];
            return questionsJson
                .map((questionJson) => Question.fromJson(questionJson))
                .toList();
          case 1:
            throw Exception(
              'Pas assez de questions disponibles pour ces critères',
            );
          case 2:
            throw Exception('Paramètres invalides');
          case 3:
            throw Exception('Token non trouvé');
          case 4:
            throw Exception('Token vide');
          default:
            throw Exception('Erreur API inconnue: $responseCode');
        }
      } else {
        throw HttpException(
          'Erreur lors de la récupération des questions: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const SocketException('Pas de connexion internet');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw Exception(
        'Erreur inattendue lors de la récupération des questions: $e',
      );
    }
  }

  // Valide que les questions sont du bon type
  List<Question> _validateQuestionType(
    List<Question> questions,
    QuestionType expectedType,
  ) {
    return questions.where((question) {
      // Vérifier le type de question
      if (expectedType == QuestionType.multiple) {
        // Une question à choix multiple doit avoir au moins 3 réponses incorrectes + 1 correcte
        return question.incorrectAnswers.length >= 3 &&
            question.type.toLowerCase() == 'multiple';
      } else if (expectedType == QuestionType.boolean) {
        return question.type.toLowerCase() == 'boolean';
      }
      return true;
    }).toList();
  }

  // Stratégies de fallback pour obtenir des questions à choix multiples
  Future<List<Question>> _tryFallbackStrategies({
    required int amount,
    int? categoryId,
    Difficulty? difficulty,
    required QuestionType type,
    required List<Question> currentQuestions,
  }) async {
    List<Question> allQuestions = List.from(currentQuestions);

    // Stratégie 1: Essayer sans spécifier la difficulté
    if (difficulty != null && allQuestions.length < amount) {
      try {
        final fallbackQuestions = await _fetchQuestionsFromAPI(
          amount: amount * 2, // Demander plus pour avoir plus de choix
          categoryId: categoryId,
          difficulty: null, // Supprimer la contrainte de difficulté
          type: type,
        );

        final validQuestions = _validateQuestionType(fallbackQuestions, type);
        allQuestions.addAll(validQuestions);

        // Supprimer les doublons
        allQuestions = _removeDuplicateQuestions(allQuestions);
      } catch (e) {
        // Continuer avec la stratégie suivante
      }
    }

    // Stratégie 2: Essayer sans spécifier la catégorie
    if (categoryId != null && allQuestions.length < amount) {
      try {
        final fallbackQuestions = await _fetchQuestionsFromAPI(
          amount: amount * 2,
          categoryId: null, // Supprimer la contrainte de catégorie
          difficulty: difficulty,
          type: type,
        );

        final validQuestions = _validateQuestionType(fallbackQuestions, type);
        allQuestions.addAll(validQuestions);

        // Supprimer les doublons
        allQuestions = _removeDuplicateQuestions(allQuestions);
      } catch (e) {
        // Continuer avec la stratégie suivante
      }
    }

    // Stratégie 3: Essayer sans contraintes (sauf le type)
    if (allQuestions.length < amount) {
      try {
        final fallbackQuestions = await _fetchQuestionsFromAPI(
          amount: amount * 3,
          categoryId: null,
          difficulty: null,
          type: type,
        );

        final validQuestions = _validateQuestionType(fallbackQuestions, type);
        allQuestions.addAll(validQuestions);

        // Supprimer les doublons
        allQuestions = _removeDuplicateQuestions(allQuestions);
      } catch (e) {
        // Dernière tentative échouée
      }
    }

    return allQuestions;
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

  // Vérifie la disponibilité des questions à choix multiples pour une catégorie
  Future<int> checkMultipleChoiceAvailability({
    int? categoryId,
    Difficulty? difficulty,
  }) async {
    try {
      final questions = await _fetchQuestionsFromAPI(
        amount: 50, // Demander un échantillon
        categoryId: categoryId,
        difficulty: difficulty,
        type: QuestionType.multiple,
      );

      final validQuestions = _validateQuestionType(
        questions,
        QuestionType.multiple,
      );
      return validQuestions.length;
    } catch (e) {
      return 0;
    }
  }

  // Méthode utilitaire pour tester la connexion à l'API
  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl?amount=1'))
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
