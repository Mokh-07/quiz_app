import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer les paramètres utilisateur
class SettingsService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _soundEnabledKey = 'sound_enabled';

  late SharedPreferences _prefs;

  // État des paramètres
  ThemeMode _themeMode = ThemeMode.system;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  bool _isInitialized = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get isInitialized => _isInitialized;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Initialise le service avec les préférences sauvegardées
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    _isInitialized = true;
    notifyListeners();
  }

  /// Charge les paramètres depuis le stockage local
  Future<void> _loadSettings() async {
    // Charger le mode de thème
    final themeIndex = _prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];

    // Charger les préférences de vibration
    _vibrationEnabled = _prefs.getBool(_vibrationEnabledKey) ?? true;

    // Charger les préférences de son
    _soundEnabled = _prefs.getBool(_soundEnabledKey) ?? true;
  }

  /// Change le mode de thème
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _prefs.setInt(_themeKey, mode.index);
      notifyListeners();
    }
  }

  /// Active/désactive les vibrations
  Future<void> setVibrationEnabled(bool enabled) async {
    if (_vibrationEnabled != enabled) {
      _vibrationEnabled = enabled;
      await _prefs.setBool(_vibrationEnabledKey, enabled);
      notifyListeners();
    }
  }

  /// Active/désactive les sons
  Future<void> setSoundEnabled(bool enabled) async {
    if (_soundEnabled != enabled) {
      _soundEnabled = enabled;
      await _prefs.setBool(_soundEnabledKey, enabled);
      notifyListeners();
    }
  }

  /// Remet tous les paramètres à leurs valeurs par défaut
  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _vibrationEnabled = true;
    _soundEnabled = true;

    await _prefs.setInt(_themeKey, _themeMode.index);
    await _prefs.setBool(_vibrationEnabledKey, _vibrationEnabled);
    await _prefs.setBool(_soundEnabledKey, _soundEnabled);

    notifyListeners();
  }

  /// Obtient une description textuelle du mode de thème actuel
  String get themeModeDescription {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Système';
    }
  }
}
