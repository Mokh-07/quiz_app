import 'package:flutter/material.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_es.dart';

/// Classe de base pour les localisations
abstract class AppLocalizations {
  AppLocalizations(this.localeName);

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizationsFr();
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'),
    Locale('en', 'US'),
    Locale('ar', 'SA'),
    Locale('es', 'ES'),
  ];

  // Textes de l'application
  String get appTitle;
  String get welcomeTitle;
  String get welcomeSubtitle;
  String get startQuiz;
  String get viewHistory;
  String get about;
  String get settings;
  String get testAudio;
  String get selectCategory;
  String get selectDifficulty;
  String get numberOfQuestions;
  String get timeLimit;
  String get easy;
  String get medium;
  String get hard;
  String get minutes;
  String get unlimited;
  String get start;
  String get question;
  String get ofText;
  String get timeRemaining;
  String get nextQuestion;
  String get quizCompleted;
  String get yourScore;
  String get correct;
  String get incorrect;
  String get time;
  String get playAgain;
  String get backToHome;
  String get questionReview;
  String get yourAnswer;
  String get correctAnswer;
  String get excellent;
  String get goodJob;
  String get needsImprovement;
  String get tryAgain;
  String get language;
  String get changeLanguage;
  String get theme;
  String get vibration;
  String get soundEffects;
  String get testSounds;
  String get testVibration;
  String get resetSettings;
  String get close;
  String get cancel;
  String get confirm;
  String get loading;
  String get error;
  String get retry;
  String get noQuestionsAvailable;
  String get connectionError;
  String get lastQuiz;
  String get categories;
  String get quickFun;
  String get progressTracking;
  String get varied;
  String get questions;
  String get personal;

  // Page À propos
  String get aboutApp;
  String get appDescription;
  String get features;
  String get multipleCategories;
  String get difficultyLevels;
  String get audioFeedback;
  String get multiLanguage;
  String get darkModeSupport;
  String get apiInformation;
  String get apiDescription;
  String get apiProvider;
  String get apiWebsite;
  String get apiFeatures;
  String get freeToUse;
  String get noRegistration;
  String get regularUpdates;
  String get qualityQuestions;
  String get technicalInfo;
  String get builtWith;
  String get version;
  String get developer;
  String get contact;
  String get visitWebsite;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en', 'ar', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return AppLocalizationsEn(locale.toString());
      case 'ar':
        return AppLocalizationsAr(locale.toString());
      case 'es':
        return AppLocalizationsEs(locale.toString());
      case 'fr':
      default:
        return AppLocalizationsFr(locale.toString());
    }
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
