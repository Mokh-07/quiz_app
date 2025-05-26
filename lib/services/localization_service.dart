import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion de la localisation
class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  static const String _localeKey = 'selected_locale';
  
  // Langues supportées
  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'), // Français
    Locale('en', 'US'), // Anglais
    Locale('ar', 'SA'), // Arabe
    Locale('es', 'ES'), // Espagnol
  ];

  // Noms des langues pour l'affichage
  static const Map<String, String> languageNames = {
    'fr_FR': 'Français',
    'en_US': 'English',
    'ar_SA': 'العربية',
    'es_ES': 'Español',
  };

  // Drapeaux des langues
  static const Map<String, String> languageFlags = {
    'fr_FR': '🇫🇷',
    'en_US': '🇺🇸',
    'ar_SA': '🇸🇦',
    'es_ES': '🇪🇸',
  };

  Locale _currentLocale = const Locale('fr', 'FR');
  bool _isInitialized = false;

  Locale get currentLocale => _currentLocale;
  bool get isInitialized => _isInitialized;
  
  String get currentLanguageCode => _currentLocale.languageCode;
  String get currentCountryCode => _currentLocale.countryCode ?? '';
  String get currentLocaleString => '${_currentLocale.languageCode}_${_currentLocale.countryCode}';

  /// Initialise le service de localisation
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);
      
      if (savedLocale != null) {
        final parts = savedLocale.split('_');
        if (parts.length == 2) {
          _currentLocale = Locale(parts[0], parts[1]);
        }
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // En cas d'erreur, utiliser la locale par défaut
      _currentLocale = const Locale('fr', 'FR');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Change la langue de l'application
  Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale) return;

    _currentLocale = locale;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, '${locale.languageCode}_${locale.countryCode}');
    } catch (e) {
      // Ignorer l'erreur de sauvegarde
    }
    
    notifyListeners();
  }

  /// Obtient le nom de la langue actuelle
  String getCurrentLanguageName() {
    return languageNames[currentLocaleString] ?? 'Français';
  }

  /// Obtient le drapeau de la langue actuelle
  String getCurrentLanguageFlag() {
    return languageFlags[currentLocaleString] ?? '🇫🇷';
  }

  /// Vérifie si une locale est supportée
  bool isLocaleSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode &&
        supportedLocale.countryCode == locale.countryCode);
  }

  /// Obtient la prochaine langue dans la liste
  Locale getNextLocale() {
    final currentIndex = supportedLocales.indexWhere((locale) =>
        locale.languageCode == _currentLocale.languageCode &&
        locale.countryCode == _currentLocale.countryCode);
    
    final nextIndex = (currentIndex + 1) % supportedLocales.length;
    return supportedLocales[nextIndex];
  }
}
