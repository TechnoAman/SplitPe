import 'package:flutter/material.dart';

/// Supported Languages in SplitPe
enum AppLanguage {
  english('en', 'English', 'English', '🇬🇧', 'EN'),
  hindi('hi', 'Hindi', 'हिन्दी', '🇮🇳', 'हि'),
  hinglish('hi_latn', 'Hinglish', 'Hinglish (Colloquial)', '⚡', 'HING'),
  marathi('mr', 'Marathi', 'मराठी', '🇮🇳', 'म'),
  gujarati('gu', 'Gujarati', 'ગુજરાતી', '🇮🇳', 'ગુ'),
  tamil('ta', 'Tamil', 'தமிழ்', '🇮🇳', 'த'),
  telugu('te', 'Telugu', 'తెలుగు', '🇮🇳', 'తె'),
  kannada('kn', 'Kannada', 'ಕನ್ನಡ', '🇮🇳', 'ಕ'),
  bengali('bn', 'Bengali', 'বাংলা', '🇮🇳', 'বা');

  final String code;
  final String englishName;
  final String nativeName;
  final String flag;
  final String shortCode;

  const AppLanguage(
    this.code,
    this.englishName,
    this.nativeName,
    this.flag,
    this.shortCode,
  );
}

/// Global Controller for reactive language switching across the entire app
class LocaleController {
  static final ValueNotifier<AppLanguage> currentLanguage =
      ValueNotifier<AppLanguage>(AppLanguage.english);

  static AppLanguage get language => currentLanguage.value;

  static void setLanguage(AppLanguage lang) {
    currentLanguage.value = lang;
  }
}
