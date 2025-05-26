import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service audio simple pour jouer les sons vocaux
class SimpleAudioService {
  static final SimpleAudioService _instance = SimpleAudioService._internal();
  factory SimpleAudioService() => _instance;
  SimpleAudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  /// Initialise le service audio
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configuration pour le web
      if (kIsWeb) {
        await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      }
      _isInitialized = true;
      if (kDebugMode) {
        print('🎵 SimpleAudioService initialisé');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur initialisation audio: $e');
      }
    }
  }

  /// Joue un son vocal
  Future<void> _playSound(String fileName) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _audioPlayer.stop(); // Arrêter le son précédent

      // Vérifier si le fichier existe avant de le jouer
      final source = AssetSource('sounds/$fileName');
      await _audioPlayer.play(source);

      if (kDebugMode) {
        print('🎵 Lecture réussie: $fileName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fichier audio non trouvé ou erreur: $fileName');
        print('💡 Assurez-vous que le fichier existe dans assets/sounds/');
        print('💡 Formats supportés: MP3, WAV, OGG');
      }
      // Ne pas faire planter l'app si le son ne peut pas être joué
    }
  }

  /// Joue le son de réponse correcte
  Future<void> playCorrectSound() async {
    await _playSound('correct.mp3');
  }

  /// Joue le son de réponse incorrecte
  Future<void> playWrongSound() async {
    await _playSound('wrong.mp3');
  }

  /// Joue le son de quiz terminé
  Future<void> playCompleteSound() async {
    await _playSound('complete.mp3');
  }

  /// Arrête tous les sons
  Future<void> stopAllSounds() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur arrêt audio: $e');
      }
    }
  }

  /// Teste si tous les fichiers audio sont disponibles
  Future<void> testAllSounds() async {
    if (kDebugMode) {
      print('🔍 Test des fichiers audio...');
    }

    final files = ['correct.mp3', 'wrong.mp3', 'complete.mp3'];

    for (String file in files) {
      try {
        final source = AssetSource('sounds/$file');
        await _audioPlayer.play(source);
        await _audioPlayer.stop();

        if (kDebugMode) {
          print('✅ $file - OK');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ $file - MANQUANT ou ERREUR');
        }
      }
    }

    if (kDebugMode) {
      print('🔍 Test terminé');
    }
  }

  /// Libère les ressources
  void dispose() {
    _audioPlayer.dispose();
  }
}
