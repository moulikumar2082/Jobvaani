import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppFlowProvider with ChangeNotifier {
  static const String _onboardingKey = 'jobvaani_onboarding_completed';
  static const String _languageSelectedKey = 'jobvaani_language_selected';

  bool _hasCompletedOnboarding = false;
  bool _hasSelectedLanguage = false;
  bool _isInitialized = false;
  int _currentTabIndex = 0;

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get hasSelectedLanguage => _hasSelectedLanguage;
  bool get isInitialized => _isInitialized;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  AppFlowProvider() {
    initFlowState();
  }

  Future<void> initFlowState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasCompletedOnboarding = prefs.getBool(_onboardingKey) ?? false;
      _hasSelectedLanguage = prefs.getBool(_languageSelectedKey) ?? false;
      _isInitialized = true;
      notifyListeners();
    } catch (_) {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (_) {}
  }

  Future<void> setLanguageSelected() async {
    _hasSelectedLanguage = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_languageSelectedKey, true);
    } catch (_) {}
  }
}
