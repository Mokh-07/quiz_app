import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Service d'authentification statique
/// Prépare la structure pour Firebase plus tard
class AuthService extends ChangeNotifier {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _isGuestKey = 'is_guest';

  User? _currentUser;
  bool _isLoading = false;
  
  // Base de données statique des utilisateurs (temporaire)
  final Map<String, Map<String, String>> _staticUsers = {
    'admin@quiz.com': {
      'password': 'admin123',
      'name': 'Administrateur',
      'id': 'admin_001',
    },
    'user@quiz.com': {
      'password': 'user123',
      'name': 'Utilisateur Test',
      'id': 'user_001',
    },
    'demo@quiz.com': {
      'password': 'demo123',
      'name': 'Utilisateur Démo',
      'id': 'demo_001',
    },
  };

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isGuest => _currentUser?.isGuest ?? false;

  /// Initialise le service d'authentification
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      if (isLoggedIn) {
        final userId = prefs.getString(_userIdKey);
        final userName = prefs.getString(_userNameKey);
        final userEmail = prefs.getString(_userEmailKey);
        final isGuest = prefs.getBool(_isGuestKey) ?? false;
        
        if (userId != null && userName != null) {
          _currentUser = User(
            id: userId,
            name: userName,
            email: userEmail,
            isGuest: isGuest,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'initialisation de l\'authentification: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Connexion avec email et mot de passe
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulation d'un délai réseau
      await Future.delayed(const Duration(milliseconds: 1500));

      // Vérification dans la base statique
      if (_staticUsers.containsKey(email)) {
        final userData = _staticUsers[email]!;
        if (userData['password'] == password) {
          _currentUser = User(
            id: userData['id']!,
            name: userData['name']!,
            email: email,
            isGuest: false,
          );
          
          await _saveUserSession();
          
          if (kDebugMode) {
            print('✅ Connexion réussie pour: ${_currentUser!.name}');
          }
        } else {
          throw Exception('Mot de passe incorrect');
        }
      } else {
        throw Exception('Utilisateur non trouvé');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur de connexion: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inscription d'un nouvel utilisateur
  Future<void> signUp(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulation d'un délai réseau
      await Future.delayed(const Duration(milliseconds: 2000));

      // Vérifier si l'utilisateur existe déjà
      if (_staticUsers.containsKey(email)) {
        throw Exception('Un compte avec cet email existe déjà');
      }

      // Créer un nouvel utilisateur
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      
      // Ajouter à la base statique
      _staticUsers[email] = {
        'password': password,
        'name': name,
        'id': userId,
      };

      _currentUser = User(
        id: userId,
        name: name,
        email: email,
        isGuest: false,
      );

      await _saveUserSession();

      if (kDebugMode) {
        print('✅ Inscription réussie pour: ${_currentUser!.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur d\'inscription: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Connexion en tant qu'invité
  void signInAsGuest() {
    _currentUser = User(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Invité',
      email: null,
      isGuest: true,
    );

    _saveUserSession();

    if (kDebugMode) {
      print('✅ Connexion en tant qu\'invité');
    }

    notifyListeners();
  }

  /// Déconnexion
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _currentUser = null;

      if (kDebugMode) {
        print('✅ Déconnexion réussie');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur de déconnexion: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sauvegarde la session utilisateur
  Future<void> _saveUserSession() async {
    if (_currentUser == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userIdKey, _currentUser!.id);
      await prefs.setString(_userNameKey, _currentUser!.name);
      await prefs.setBool(_isGuestKey, _currentUser!.isGuest);
      
      if (_currentUser!.email != null) {
        await prefs.setString(_userEmailKey, _currentUser!.email!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur sauvegarde session: $e');
      }
    }
  }

  /// Obtient la liste des utilisateurs de test (pour debug)
  List<Map<String, String>> getTestUsers() {
    return _staticUsers.entries.map((entry) {
      return {
        'email': entry.key,
        'password': entry.value['password']!,
        'name': entry.value['name']!,
      };
    }).toList();
  }

  /// Vérifie si un email est déjà utilisé
  bool isEmailTaken(String email) {
    return _staticUsers.containsKey(email);
  }

  /// Met à jour le profil utilisateur
  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulation d'un délai réseau
      await Future.delayed(const Duration(milliseconds: 1000));

      _currentUser = User(
        id: _currentUser!.id,
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        isGuest: _currentUser!.isGuest,
      );

      await _saveUserSession();

      if (kDebugMode) {
        print('✅ Profil mis à jour');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur mise à jour profil: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Réinitialise le mot de passe (simulation)
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulation d'un délai réseau
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!_staticUsers.containsKey(email)) {
        throw Exception('Aucun compte trouvé avec cet email');
      }

      // En mode statique, on ne peut pas vraiment réinitialiser
      // Mais on simule le processus
      if (kDebugMode) {
        print('✅ Email de réinitialisation envoyé à: $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur réinitialisation: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
