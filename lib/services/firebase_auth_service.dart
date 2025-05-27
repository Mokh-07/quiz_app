import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user.dart' as app_user;
import 'high_score_service.dart';
import 'quiz_provider.dart';

/// Service d'authentification Firebase
class FirebaseAuthService extends ChangeNotifier {
  FirebaseAuth? _auth;
  app_user.User? _currentUser;
  bool _isLoading = false;

  // Services connectés pour la synchronisation des données
  HighScoreService? _highScoreService;
  QuizProvider? _quizProvider;

  app_user.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isGuest => _currentUser?.isGuest ?? false;

  /// Connecte les services pour la synchronisation des données
  void connectServices({
    HighScoreService? highScoreService,
    QuizProvider? quizProvider,
  }) {
    _highScoreService = highScoreService;
    _quizProvider = quizProvider;
  }

  /// Initialise le service Firebase
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialiser Firebase
      await Firebase.initializeApp(
        options:
            kIsWeb
                ? const FirebaseOptions(
                  // 🔥 CONFIGURATION FIREBASE RÉELLE 🔥
                  apiKey: "AIzaSyAXQNRP6ubidjX7X7W3V37SN_GdP5qNxnw",
                  authDomain: "quiz-app-firebase-5d348.firebaseapp.com",
                  projectId: "quiz-app-firebase-5d348",
                  storageBucket: "quiz-app-firebase-5d348.firebasestorage.app",
                  messagingSenderId: "202628820831",
                  appId: "1:202628820831:web:ec4de7df7acc9739a410ea",
                  measurementId: "G-SME68GQZ8P",
                )
                : null,
      );

      // Initialiser l'instance FirebaseAuth
      _auth = FirebaseAuth.instance;

      // Écouter les changements d'état d'authentification
      _auth!.authStateChanges().listen(_onAuthStateChanged);

      if (kDebugMode) {
        print('🔥 Firebase Auth Service initialisé');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur initialisation Firebase: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gère les changements d'état d'authentification
  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser != null) {
      _currentUser = app_user.User(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Utilisateur',
        email: firebaseUser.email,
        isGuest: false,
      );

      // Notifier les services du changement d'utilisateur
      _highScoreService?.setCurrentUser(firebaseUser.uid);
      _quizProvider?.setCurrentUser(firebaseUser.uid);

      if (kDebugMode) {
        print(
          '🔥 Utilisateur connecté: ${_currentUser?.displayName} (${firebaseUser.uid})',
        );
      }
    } else {
      _currentUser = null;

      // Notifier les services de la déconnexion
      _highScoreService?.setCurrentUser(null);
      _quizProvider?.setCurrentUser(null);

      if (kDebugMode) {
        print('🔥 Utilisateur déconnecté');
      }
    }

    notifyListeners();

    if (kDebugMode) {
      print(
        '🔥 État auth changé: ${_currentUser?.displayName ?? 'Déconnecté'}',
      );
    }
  }

  /// Connexion avec email et mot de passe
  Future<void> signIn(String email, String password) async {
    if (_auth == null) throw Exception('Firebase non initialisé');

    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('✅ Connexion Firebase réussie: ${credential.user?.email}');
      }
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      if (kDebugMode) {
        print('❌ Erreur connexion Firebase: ${e.code} - $message');
      }
      throw Exception(message);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur connexion: $e');
      }
      throw Exception('Erreur de connexion');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inscription avec email et mot de passe
  Future<void> signUp(String email, String password, String name) async {
    if (_auth == null) throw Exception('Firebase non initialisé');

    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour le profil avec le nom
      await credential.user?.updateDisplayName(name);

      if (kDebugMode) {
        print('✅ Inscription Firebase réussie: ${credential.user?.email}');
      }
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      if (kDebugMode) {
        print('❌ Erreur inscription Firebase: ${e.code} - $message');
      }
      throw Exception(message);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur inscription: $e');
      }
      throw Exception('Erreur d\'inscription');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Connexion en tant qu'invité
  void signInAsGuest() {
    _currentUser = app_user.User(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Invité',
      email: null,
      isGuest: true,
    );

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
      if (!isGuest && _auth != null) {
        await _auth!.signOut();
      } else {
        _currentUser = null;
      }

      if (kDebugMode) {
        print('✅ Déconnexion Firebase réussie');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur déconnexion Firebase: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    if (_auth == null) throw Exception('Firebase non initialisé');

    _isLoading = true;
    notifyListeners();

    try {
      await _auth!.sendPasswordResetEmail(email: email);

      if (kDebugMode) {
        print('✅ Email de réinitialisation envoyé à: $email');
      }
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      if (kDebugMode) {
        print('❌ Erreur réinitialisation Firebase: ${e.code} - $message');
      }
      throw Exception(message);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur réinitialisation: $e');
      }
      throw Exception('Erreur de réinitialisation');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Met à jour le profil utilisateur
  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null || isGuest) return;

    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth?.currentUser;
      if (user != null) {
        if (name != null) {
          await user.updateDisplayName(name);
        }
        if (email != null) {
          await user.verifyBeforeUpdateEmail(email);
        }
        await user.reload();
      }

      if (kDebugMode) {
        print('✅ Profil Firebase mis à jour');
      }
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      if (kDebugMode) {
        print('❌ Erreur mise à jour profil Firebase: ${e.code} - $message');
      }
      throw Exception(message);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur mise à jour profil: $e');
      }
      throw Exception('Erreur de mise à jour');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Convertit les codes d'erreur Firebase en messages lisibles
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email';
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'invalid-email':
        return 'Adresse email invalide';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      case 'operation-not-allowed':
        return 'Opération non autorisée';
      case 'requires-recent-login':
        return 'Veuillez vous reconnecter pour cette opération';
      default:
        return 'Une erreur est survenue';
    }
  }

  /// Vérifie si l'utilisateur est connecté
  bool get isSignedIn => _auth?.currentUser != null || isGuest;

  /// Obtient l'utilisateur Firebase actuel
  User? get firebaseUser => _auth?.currentUser;
}
