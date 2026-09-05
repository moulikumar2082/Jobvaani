import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'jobvaani_selected_locale';
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  LocaleProvider() {
    _loadPersistedLocale();
  }

  Future<void> _loadPersistedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_localeKey);
      if (code != null && ['en', 'te', 'hi', 'pa'].contains(code)) {
        _currentLocale = Locale(code);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'te', 'hi', 'pa'].contains(locale.languageCode)) return;
    _currentLocale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (_) {}
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'te':
        return 'తెలుగు (Telugu)';
      case 'hi':
        return 'हिन्दी (Hindi)';
      case 'pa':
        return 'ਪੰਜਾਬੀ (Punjabi)';
      case 'en':
      default:
        return 'English';
    }
  }

  String getNativeName(String code) {
    switch (code) {
      case 'te':
        return 'తెలుగు';
      case 'hi':
        return 'हिन्दी';
      case 'pa':
        return 'ਪੰਜਾਬੀ';
      case 'en':
      default:
        return 'English';
    }
  }
}
