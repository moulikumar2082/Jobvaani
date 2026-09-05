import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/auth_models.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  static const String _tokenKey = 'jobvaani_auth_token';
  static const String _userNameKey = 'jobvaani_user_name';
  static const String _userEmailKey = 'jobvaani_user_email';
  static const String _userPhoneKey = 'jobvaani_user_phone';
  static const String _educationKey = 'jobvaani_user_education';
  static const String _skillsKey = 'jobvaani_user_skills';
  static const String _locationsKey = 'jobvaani_user_locations';
  static const String _categoriesKey = 'jobvaani_user_categories';
  static const String _jobTypesKey = 'jobvaani_user_job_types';
  static const String _collegeKey = 'jobvaani_user_college';
  static const String _gradYearKey = 'jobvaani_user_grad_year';
  static const String _experienceKey = 'jobvaani_user_experience';
  static const String _minSalaryKey = 'jobvaani_pref_min_salary';
  static const String _govtCategoriesKey = 'jobvaani_pref_govt_categories';
  static const String _resumeFileNameKey = 'jobvaani_resume_file_name';
  static const String _profileCompletedKey = 'jobvaani_profile_completed';
  static const String _notifGovtKey = 'jobvaani_notif_govt';
  static const String _notifMatchesKey = 'jobvaani_notif_matches';
  static const String _notifDeadlinesKey = 'jobvaani_notif_deadlines';
  static const String _notifRecommendationsKey = 'jobvaani_notif_recommendations';

  final IAuthRepository _authRepository;

  bool _isAuthenticated = true;
  String? _token = 'jwt_demo_token';
  String _userName = 'Mowli Kumar';
  String _userEmail = 'mowlikumar@gmail.com';
  String _userPhone = '+91 98765 43210';
  String _education = 'B.Tech in Computer Science & Engineering';
  String _college = 'National Institute of Technology';
  String _graduationYear = '2025';
  String _experience = '1-3 Years';
  double _minSalaryLpa = 6.0;
  List<String> _preferredGovtCategories = ['UPSC', 'SSC', 'Railway', 'Banking', 'PSU'];
  List<String> _skills = ['Flutter', 'Dart', 'Python', 'Cybersecurity', 'Cloud / AWS', 'SQL'];
  List<String> _preferredLocations = ['Bengaluru', 'Hyderabad', 'Remote', 'Delhi NCR'];
  List<String> _jobCategories = ['Software Development', 'Cybersecurity', 'Government Jobs'];
  List<String> _preferredJobTypes = ['Full Time', 'Government'];
  String? _resumeFileName = 'Mowli_Kumar_Resume.pdf';
  DateTime? _resumeUploadedAt = DateTime(2026, 9, 1);
  bool _isProfileCompleted = true;
  bool _notifGovtAlerts = true;
  bool _notifJobMatches = true;
  bool _notifDeadlines = true;
  bool _notifRecommendations = true;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get education => _education;
  String get college => _college;
  String get graduationYear => _graduationYear;
  String get experience => _experience;
  double get minSalaryLpa => _minSalaryLpa;
  List<String> get preferredGovtCategories => _preferredGovtCategories;
  List<String> get skills => _skills;
  List<String> get preferredLocations => _preferredLocations;
  List<String> get jobCategories => _jobCategories;
  List<String> get preferredJobTypes => _preferredJobTypes;
  String? get resumeFileName => _resumeFileName;
  DateTime? get resumeUploadedAt => _resumeUploadedAt;
  bool get isProfileCompleted => _isProfileCompleted;
  bool get notifGovtAlerts => _notifGovtAlerts;
  bool get notifJobMatches => _notifJobMatches;
  bool get notifDeadlines => _notifDeadlines;
  bool get notifRecommendations => _notifRecommendations;

  AuthProvider({IAuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    checkAuthState();
  }

  Future<void> checkAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);
      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        _userName = prefs.getString(_userNameKey) ?? _userName;
        _userEmail = prefs.getString(_userEmailKey) ?? _userEmail;
        _userPhone = prefs.getString(_userPhoneKey) ?? _userPhone;
        _education = prefs.getString(_educationKey) ?? _education;
        _college = prefs.getString(_collegeKey) ?? _college;
        _graduationYear = prefs.getString(_gradYearKey) ?? _graduationYear;
        _experience = prefs.getString(_experienceKey) ?? _experience;
        _skills = prefs.getStringList(_skillsKey) ?? _skills;
        _preferredLocations = prefs.getStringList(_locationsKey) ?? _preferredLocations;
        _jobCategories = prefs.getStringList(_categoriesKey) ?? _jobCategories;
        _preferredJobTypes = prefs.getStringList(_jobTypesKey) ?? _preferredJobTypes;
        _minSalaryLpa = prefs.getDouble(_minSalaryKey) ?? _minSalaryLpa;
        _preferredGovtCategories = prefs.getStringList(_govtCategoriesKey) ?? _preferredGovtCategories;
        _resumeFileName = prefs.getString(_resumeFileNameKey) ?? _resumeFileName;
        _isProfileCompleted = prefs.getBool(_profileCompletedKey) ?? true;
        _notifGovtAlerts = prefs.getBool(_notifGovtKey) ?? true;
        _notifJobMatches = prefs.getBool(_notifMatchesKey) ?? true;
        _notifDeadlines = prefs.getBool(_notifDeadlinesKey) ?? true;
        _notifRecommendations = prefs.getBool(_notifRecommendationsKey) ?? true;
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (email.trim().isEmpty || password.length < 6) {
      return false;
    }

    _isAuthenticated = true;
    _token = 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    _userName = email.contains('@') ? email.split('@').first : 'Candidate';
    _userEmail = email;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
      await prefs.setString(_userNameKey, _userName);
      await prefs.setString(_userEmailKey, _userEmail);
    } catch (_) {}

    notifyListeners();
    return true;
  }

  Future<bool> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 700));
    _isAuthenticated = true;
    _token = 'google_oauth_${DateTime.now().millisecondsSinceEpoch}';
    _userName = 'Job Seeker';
    _userEmail = 'seeker@jobvaani.in';

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
      await prefs.setString(_userNameKey, _userName);
      await prefs.setString(_userEmailKey, _userEmail);
    } catch (_) {}

    notifyListeners();
    return true;
  }

  Future<ForgotPasswordResponse> sendPasswordReset(String email) async {
    return await _authRepository.sendPasswordReset(email);
  }

  Future<bool> register(
    String name,
    String email,
    String password, {
    String? phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _isAuthenticated = true;
    _token = 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    _userName = name.isNotEmpty ? name : 'Candidate';
    _userEmail = email;
    _userPhone = phone ?? '';

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
      await prefs.setString(_userNameKey, _userName);
      await prefs.setString(_userEmailKey, _userEmail);
      if (phone != null && phone.isNotEmpty) {
        await prefs.setString(_userPhoneKey, phone);
      }
    } catch (_) {}

    notifyListeners();
    return true;
  }

  Future<void> updateProfile({
    String? education,
    List<String>? skills,
    List<String>? locations,
    List<String>? categories,
  }) async {
    if (education != null) _education = education;
    if (skills != null) _skills = skills;
    if (locations != null) _preferredLocations = locations;
    if (categories != null) _jobCategories = categories;
    _isProfileCompleted = true;

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (education != null) await prefs.setString(_educationKey, education);
      if (skills != null) await prefs.setStringList(_skillsKey, skills);
      if (locations != null) await prefs.setStringList(_locationsKey, locations);
      if (categories != null) await prefs.setStringList(_categoriesKey, categories);
      await prefs.setBool(_profileCompletedKey, true);
    } catch (_) {}
  }

  Future<void> updateProfileDetails({
    String? name,
    String? email,
    String? phone,
    String? education,
  }) async {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (phone != null) _userPhone = phone;
    if (education != null) _education = education;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (name != null) await prefs.setString(_userNameKey, name);
      if (email != null) await prefs.setString(_userEmailKey, email);
      if (phone != null) await prefs.setString(_userPhoneKey, phone);
      if (education != null) await prefs.setString(_educationKey, education);
    } catch (_) {}
  }

  Future<void> updateSkills(List<String> newSkills) async {
    _skills = List<String>.from(newSkills);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_skillsKey, _skills);
    } catch (_) {}
  }

  Future<void> updateJobPreferences({
    List<String>? locations,
    List<String>? categories,
    List<String>? jobTypes,
  }) async {
    if (locations != null) _preferredLocations = List<String>.from(locations);
    if (categories != null) _jobCategories = List<String>.from(categories);
    if (jobTypes != null) _preferredJobTypes = List<String>.from(jobTypes);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (locations != null) await prefs.setStringList(_locationsKey, _preferredLocations);
      if (categories != null) await prefs.setStringList(_categoriesKey, _jobCategories);
      if (jobTypes != null) await prefs.setStringList(_jobTypesKey, _preferredJobTypes);
    } catch (_) {}
  }

  Future<void> updateJobPreferencesFull({
    required List<String> categories,
    required List<String> locations,
    required List<String> jobTypes,
    required double minSalaryLpa,
    required String experienceLevel,
    required List<String> govtCategories,
    required bool notifGovtAlerts,
    required bool notifJobMatches,
    required bool notifDeadlines,
    required bool notifRecommendations,
  }) async {
    _jobCategories = List<String>.from(categories);
    _preferredLocations = List<String>.from(locations);
    _preferredJobTypes = List<String>.from(jobTypes);
    _minSalaryLpa = minSalaryLpa;
    _experience = experienceLevel;
    _preferredGovtCategories = List<String>.from(govtCategories);
    _notifGovtAlerts = notifGovtAlerts;
    _notifJobMatches = notifJobMatches;
    _notifDeadlines = notifDeadlines;
    _notifRecommendations = notifRecommendations;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_categoriesKey, _jobCategories);
      await prefs.setStringList(_locationsKey, _preferredLocations);
      await prefs.setStringList(_jobTypesKey, _preferredJobTypes);
      await prefs.setDouble(_minSalaryKey, _minSalaryLpa);
      await prefs.setString(_experienceKey, _experience);
      await prefs.setStringList(_govtCategoriesKey, _preferredGovtCategories);
      await prefs.setBool(_notifGovtKey, _notifGovtAlerts);
      await prefs.setBool(_notifMatchesKey, _notifJobMatches);
      await prefs.setBool(_notifDeadlinesKey, _notifDeadlines);
      await prefs.setBool(_notifRecommendationsKey, _notifRecommendations);
    } catch (_) {}
  }

  Future<void> updateFullProfile({
    required String name,
    required String qualification,
    required String college,
    required String graduationYear,
    required List<String> skills,
    required String experience,
    required List<String> preferredLocations,
    required List<String> preferredCategories,
    required List<String> preferredJobTypes,
  }) async {
    _userName = name;
    _education = qualification;
    _college = college;
    _graduationYear = graduationYear;
    _skills = List<String>.from(skills);
    _experience = experience;
    _preferredLocations = List<String>.from(preferredLocations);
    _jobCategories = List<String>.from(preferredCategories);
    _preferredJobTypes = List<String>.from(preferredJobTypes);
    _isProfileCompleted = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, name);
      await prefs.setString(_educationKey, qualification);
      await prefs.setString(_collegeKey, college);
      await prefs.setString(_gradYearKey, graduationYear);
      await prefs.setStringList(_skillsKey, _skills);
      await prefs.setString(_experienceKey, experience);
      await prefs.setStringList(_locationsKey, _preferredLocations);
      await prefs.setStringList(_categoriesKey, _jobCategories);
      await prefs.setStringList(_jobTypesKey, _preferredJobTypes);
      await prefs.setBool(_profileCompletedKey, true);
    } catch (_) {}
  }

  Future<void> uploadResume(String fileName) async {
    _resumeFileName = fileName;
    _resumeUploadedAt = DateTime.now();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_resumeFileNameKey, fileName);
    } catch (_) {}
  }

  Future<void> removeResume() async {
    _resumeFileName = null;
    _resumeUploadedAt = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_resumeFileNameKey);
    } catch (_) {}
  }

  Future<void> updateNotificationSettings({
    bool? govtAlerts,
    bool? jobMatches,
    bool? deadlines,
    bool? recommendations,
  }) async {
    if (govtAlerts != null) _notifGovtAlerts = govtAlerts;
    if (jobMatches != null) _notifJobMatches = jobMatches;
    if (deadlines != null) _notifDeadlines = deadlines;
    if (recommendations != null) _notifRecommendations = recommendations;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (govtAlerts != null) await prefs.setBool(_notifGovtKey, govtAlerts);
      if (jobMatches != null) await prefs.setBool(_notifMatchesKey, jobMatches);
      if (deadlines != null) await prefs.setBool(_notifDeadlinesKey, deadlines);
      if (recommendations != null) await prefs.setBool(_notifRecommendationsKey, recommendations);
    } catch (_) {}
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _userName = 'Job Seeker';
    _userEmail = '';
    _userPhone = '';
    _education = '';
    _skills = [];
    _preferredLocations = [];
    _jobCategories = [];
    _isProfileCompleted = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userPhoneKey);
      await prefs.remove(_educationKey);
      await prefs.remove(_skillsKey);
      await prefs.remove(_locationsKey);
      await prefs.remove(_categoriesKey);
      await prefs.remove(_profileCompletedKey);
    } catch (_) {}

    notifyListeners();
  }
}
