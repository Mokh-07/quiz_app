import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Types d'effets sonores disponibles
enum SoundEffect { selection, correct, incorrect, completion, tick }

/// Types d'effets vocaux disponibles
enum VocalEffect {
  welcome,
  instructions,
  timeWarning,
  excellent,
  goodJob,
  tryAgain,
  quizComplete,
  highScore,
  resultsReady,
}

/// Service pour gérer les effets sonores de l'application
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  /// Mapping des effets sonores vers leurs fichiers audio
  static const Map<SoundEffect, String> _soundFiles = {
    SoundEffect.selection: 'assets/audio/selection.mp3',
    SoundEffect.correct: 'assets/audio/correct.mp3',
    SoundEffect.incorrect: 'assets/audio/incorrect.mp3',
    SoundEffect.completion: 'assets/audio/completion.mp3',
    SoundEffect.tick: 'assets/audio/tick.mp3',
  };

  /// Mapping des effets vocaux vers leurs fichiers audio
  static const Map<VocalEffect, String> _vocalFiles = {
    VocalEffect.welcome: 'assets/vocal/welcome.mp3',
    VocalEffect.instructions: 'assets/vocal/instructions.mp3',
    VocalEffect.timeWarning: 'assets/vocal/time_warning.mp3',
    VocalEffect.excellent: 'assets/vocal/excellent.mp3',
    VocalEffect.goodJob: 'assets/vocal/good_job.mp3',
    VocalEffect.tryAgain: 'assets/vocal/try_again.mp3',
    VocalEffect.quizComplete: 'assets/vocal/quiz_complete.mp3',
    VocalEffect.highScore: 'assets/vocal/high_score.mp3',
    VocalEffect.resultsReady: 'assets/vocal/results_ready.mp3',
  };

  /// Initialise le service audio
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configuration du player audio pour toutes les plateformes
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(0.7);
      _isInitialized = true;

      if (kDebugMode) {
        if (kIsWeb) {
          print('AudioService initialisé pour le web avec sons activés');
        } else {
          print('AudioService initialisé avec succès');
        }
      }
    } catch (e) {
      // En cas d'erreur, initialiser en mode silencieux
      _isInitialized = true;
      if (kDebugMode) {
        print('AudioService initialisé en mode silencieux: $e');
      }
    }
  }

  /// Joue un effet sonore spécifique
  Future<void> playSound(SoundEffect effect, {bool enabled = true}) async {
    if (!enabled || !_isInitialized) return;

    try {
      final soundFile = _soundFiles[effect];
      if (soundFile != null) {
        await _audioPlayer.play(AssetSource(_getSoundFileName(effect)));
        if (kDebugMode) {
          print('🔊 Son joué: ${effect.name}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la lecture du son ${effect.name}: $e');
        // Fallback: afficher un message si le son ne peut pas être joué
        print('🔊 Son simulé: ${effect.name}');
      }
    }
  }

  /// Joue un effet vocal spécifique
  Future<void> playVocal(VocalEffect effect, {bool enabled = true}) async {
    if (!enabled || !_isInitialized) return;

    try {
      final vocalFile = _vocalFiles[effect];
      if (vocalFile != null) {
        await _audioPlayer.play(AssetSource(_getVocalFileName(effect)));
        if (kDebugMode) {
          print('🎤 Vocal joué: ${effect.name}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la lecture du vocal ${effect.name}: $e');
        // Fallback: afficher un message si le vocal ne peut pas être joué
        print('🎤 Vocal simulé: ${effect.name}');
      }
    }
  }

  /// Obtient le nom du fichier audio pour un effet donné
  String _getSoundFileName(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.selection:
        return 'audio/selection.mp3';
      case SoundEffect.correct:
        return 'audio/correct.mp3';
      case SoundEffect.incorrect:
        return 'audio/incorrect.mp3';
      case SoundEffect.completion:
        return 'audio/completion.mp3';
      case SoundEffect.tick:
        return 'audio/tick.mp3';
    }
  }

  /// Obtient le nom du fichier vocal pour un effet donné
  String _getVocalFileName(VocalEffect effect) {
    switch (effect) {
      case VocalEffect.welcome:
        return 'vocal/welcome.mp3';
      case VocalEffect.instructions:
        return 'vocal/instructions.mp3';
      case VocalEffect.timeWarning:
        return 'vocal/time_warning.mp3';
      case VocalEffect.excellent:
        return 'vocal/excellent.mp3';
      case VocalEffect.goodJob:
        return 'vocal/good_job.mp3';
      case VocalEffect.tryAgain:
        return 'vocal/try_again.mp3';
      case VocalEffect.quizComplete:
        return 'vocal/quiz_complete.mp3';
      case VocalEffect.highScore:
        return 'vocal/high_score.mp3';
      case VocalEffect.resultsReady:
        return 'vocal/results_ready.mp3';
    }
  }

  /// Joue le son de sélection
  Future<void> playSelectionSound({bool enabled = true}) async {
    await playSound(SoundEffect.selection, enabled: enabled);
  }

  /// Joue le son de réponse correcte
  Future<void> playCorrectSound({bool enabled = true}) async {
    await playSound(SoundEffect.correct, enabled: enabled);
  }

  /// Joue le son de réponse incorrecte
  Future<void> playIncorrectSound({bool enabled = true}) async {
    await playSound(SoundEffect.incorrect, enabled: enabled);
  }

  /// Joue le son de fin de quiz
  Future<void> playCompletionSound({bool enabled = true}) async {
    await playSound(SoundEffect.completion, enabled: enabled);
  }

  /// Joue le son de tick du timer
  Future<void> playTickSound({bool enabled = true}) async {
    await playSound(SoundEffect.tick, enabled: enabled);
  }

  // === MÉTHODES VOCALES ===

  /// Joue le message de bienvenue
  Future<void> playWelcomeVocal({bool enabled = true}) async {
    await playVocal(VocalEffect.welcome, enabled: enabled);
  }

  /// Joue les instructions du quiz
  Future<void> playInstructionsVocal({bool enabled = true}) async {
    await playVocal(VocalEffect.instructions, enabled: enabled);
  }

  /// Joue l'avertissement de temps
  Future<void> playTimeWarningVocal({bool enabled = true}) async {
    await playVocal(VocalEffect.timeWarning, enabled: enabled);
  }

  /// Joue les félicitations "Excellent"
  Future<void> playExcellentVocal({bool enabled = true}) async {
    await playVocal(VocalEffect.excellent, enabled: enabled);
  }

  /// Joue l'encouragement "Bon travail"
  Future<void> playGoodJobVocal({bool enabled = true}) async {
    await playVocal(VocalEffect.goodJob, enabled: enabled);
  }

  /// Joue l'encouragement "Essayez encore"
  Future<void> playTryAgainVocal({bool enabled = true}) async {
    await playVocal(VocalEffect.tryAgain, enabled: enabled);
  }

  /// Joue l'annonce de fin de quiz
  Future<void> playQuizCompleteVocal({bool enabled = true}) async {
    await playVocal(VocalEffect.quizComplete, enabled: enabled);
  }

  /// Joue les félicitations pour un score élevé
  Future<void> playHighScoreVocal({bool enabled = true}) async {
    await playVocal(VocalEffect.highScore, enabled: enabled);
  }

  /// Joue l'annonce que les résultats sont prêts
  Future<void> playResultsReadyVocal({bool enabled = true}) async {
    await playVocal(VocalEffect.resultsReady, enabled: enabled);
  }

  /// Arrête tous les sons en cours
  Future<void> stopAllSounds() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'arrêt des sons: $e');
      }
    }
  }

  /// Libère les ressources
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _isInitialized = false;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la libération des ressources audio: $e');
      }
    }
  }

  /// Définit le volume global (0.0 à 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du réglage du volume: $e');
      }
    }
  }
}
