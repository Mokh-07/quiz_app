import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Types de vibrations haptiques disponibles
enum HapticType { selection, success, error, warning, heavy }

/// Service pour gérer les vibrations haptiques de l'application
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _isInitialized = false;
  bool _hasVibrator = false;

  /// Initialise le service haptique
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Sur le web, utiliser HapticFeedback de Flutter
      if (kIsWeb) {
        _hasVibrator = true; // Toujours disponible sur web
        _isInitialized = true;
        if (kDebugMode) {
          print('HapticService initialisé pour le web');
        }
        return;
      }

      // Vérifier si l'appareil supporte les vibrations sur mobile
      _hasVibrator = await Vibration.hasVibrator() ?? false;
      _isInitialized = true;

      if (kDebugMode) {
        print('HapticService initialisé - Vibration supportée: $_hasVibrator');
      }
    } catch (e) {
      if (kDebugMode) {
        print('HapticService initialisé avec fallback: $e');
      }
      _hasVibrator =
          kIsWeb; // Toujours true sur web, false sur mobile en cas d'erreur
      _isInitialized = true;
    }
  }

  /// Déclenche une vibration haptique
  Future<void> vibrate(HapticType type, {bool enabled = true}) async {
    if (!enabled || !_isInitialized) return;

    try {
      // Sur le web, toujours essayer HapticFeedback
      if (kIsWeb) {
        if (kDebugMode) {
          print('📳 Vibration simulée: ${type.name}');
        }
      }

      // Si pas de vibrator disponible, ne pas continuer sur mobile
      if (!kIsWeb && !_hasVibrator) return;

      switch (type) {
        case HapticType.selection:
          await _lightVibration();
          break;
        case HapticType.success:
          await _successVibration();
          break;
        case HapticType.error:
          await _errorVibration();
          break;
        case HapticType.warning:
          await _warningVibration();
          break;
        case HapticType.heavy:
          await _heavyVibration();
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la vibration ${type.name}: $e');
      }
    }
  }

  /// Vibration légère pour la sélection
  Future<void> _lightVibration() async {
    if (kIsWeb) {
      // Sur le web, utiliser les vibrations du navigateur si disponibles
      await HapticFeedback.selectionClick();
    } else {
      // Sur mobile, utiliser une vibration courte
      await Vibration.vibrate(duration: 50,);
    }
  }

  /// Vibration de succès (pattern court et agréable)
  Future<void> _successVibration() async {
    if (kIsWeb) {
      await HapticFeedback.lightImpact();
    } else {
      // Pattern: court-pause-court
      await Vibration.vibrate(pattern: [0, 100, 50, 100]);
    }
  }

  /// Vibration d'erreur (pattern plus long et intense)
  Future<void> _errorVibration() async {
    if (kIsWeb) {
      await HapticFeedback.heavyImpact();
    } else {
      // Pattern: long-pause-long-pause-long
      await Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200]);
    }
  }

  /// Vibration d'avertissement (pattern moyen)
  Future<void> _warningVibration() async {
    if (kIsWeb) {
      await HapticFeedback.mediumImpact();
    } else {
      // Pattern: moyen-pause-moyen
      await Vibration.vibrate(pattern: [0, 150, 75, 150]);
    }
  }

  /// Vibration forte
  Future<void> _heavyVibration() async {
    if (kIsWeb) {
      await HapticFeedback.heavyImpact();
    } else {
      await Vibration.vibrate(duration: 300);
    }
  }

  /// Vibration de sélection
  Future<void> selectionVibration({bool enabled = true}) async {
    await vibrate(HapticType.selection, enabled: enabled);
  }

  /// Vibration de succès
  Future<void> successVibration({bool enabled = true}) async {
    await vibrate(HapticType.success, enabled: enabled);
  }

  /// Vibration d'erreur
  Future<void> errorVibration({bool enabled = true}) async {
    await vibrate(HapticType.error, enabled: enabled);
  }

  /// Vibration d'avertissement (fin de temps)
  Future<void> warningVibration({bool enabled = true}) async {
    await vibrate(HapticType.warning, enabled: enabled);
  }

  /// Vibration forte
  Future<void> heavyVibration({bool enabled = true}) async {
    await vibrate(HapticType.heavy, enabled: enabled);
  }

  /// Vérifie si l'appareil supporte les vibrations
  bool get hasVibrator => _hasVibrator;

  /// Vérifie si le service est initialisé
  bool get isInitialized => _isInitialized;
}
