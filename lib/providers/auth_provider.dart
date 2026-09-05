import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/auth_models.dart';
import '../data/repositories/auth_repository.dart';
import '../services/secure_storage_service.dart';

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
  final ISecureStorageService _secureStorage;

  // Unauthenticated by default until token verification succeeds
  bool _isAuthenticated = false;
  String? _token;
  String _userName = 'Job Seeker';
  String _userEmail = '';
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

  AuthProvider({
    IAuthRepository? authRepository,
    ISecureStorageService? secureStorage,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _secureStorage = secureStorage ?? SecureStorageService() {
    checkAuthState();
  }

  /// Verifies secure token storage on startup
  Future<void> checkAuthState() async {
    try {
      final savedToken = await _secureStorage.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();
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

        notifyListeners();
      } else {
        _isAuthenticated = false;
        _token = null;
        notifyListeners();
      }
    } catch (_) {
      _isAuthenticated = false;
      _token = null;
    }
  }

  /// Sends login request through AuthRepository with validation and secure token storage
  Future<AuthResult> login(String email, String password) async {
    final result = await _authRepository.login(email, password);

    if (result.isSuccess && result.token != null) {
      _isAuthenticated = true;
      _token = result.token;

      if (result.user != null) {
        _userName = result.user!.name;
        _userEmail = result.user!.email;
        if (result.user!.phone != null) _userPhone = result.user!.phone!;
        if (result.user!.education != null) _education = result.user!.education!;
        if (result.user!.skills != null) _skills = result.user!.skills!;
        if (result.user!.locations != null) _preferredLocations = result.user!.locations!;
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);
        await prefs.setString(_userNameKey, _userName);
        await prefs.setString(_userEmailKey, _userEmail);
      } catch (_) {}

      notifyListeners();
    }

    return result;
  }

  Future<bool> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 700));
    _isAuthenticated = true;
    _token = 'google_oauth_${DateTime.now().millisecondsSinceEpoch}';
    _userName = 'Mowli Kumar';
    _userEmail = 'mowlikumar@gmail.com';

    await _secureStorage.saveToken(_token!);

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
    return _authRepository.sendPasswordReset(email);
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? education,
    String? college,
    String? graduationYear,
    String? experience,
  }) async {
    if (name != null) _userName = name;
    if (phone != null) _userPhone = phone;
    if (education != null) _education = education;
    if (college != null) _college = college;
    if (graduationYear != null) _graduationYear = graduationYear;
    if (experience != null) _experience = experience;
    _isProfileCompleted = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (name != null) await prefs.setString(_userNameKey, name);
      if (phone != null) await prefs.setString(_userPhoneKey, phone);
      if (education != null) await prefs.setString(_educationKey, education);
      if (college != null) await prefs.setString(_collegeKey, college);
      if (graduationYear != null) await prefs.setString(_gradYearKey, graduationYear);
      if (experience != null) await prefs.setString(_experienceKey, experience);
      await prefs.setBool(_profileCompletedKey, true);
    } catch (_) {}
  }

  Future<void> updateSkills(List<String> newSkills) async {
    _skills = List.from(newSkills);
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
    double? minSalary,
  }) async {
    if (locations != null) _preferredLocations = List.from(locations);
    if (categories != null) _jobCategories = List.from(categories);
    if (jobTypes != null) _preferredJobTypes = List.from(jobTypes);
    if (minSalary != null) _minSalaryLpa = minSalary;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (locations != null) await prefs.setStringList(_locationsKey, _preferredLocations);
      if (categories != null) await prefs.setStringList(_categoriesKey, _jobCategories);
      if (jobTypes != null) await prefs.setStringList(_jobTypesKey, _preferredJobTypes);
      if (minSalary != null) await prefs.setDouble(_minSalaryKey, _minSalaryLpa);
    } catch (_) {}
  }

  Future<void> updateJobPreferencesFull({
    List<String>? locations,
    List<String>? categories,
    List<String>? jobTypes,
    double? minSalary,
    String? experience,
    List<String>? govtCategories,
    bool? govtAlerts,
    bool? jobMatches,
    bool? deadlines,
    bool? recommendations,
  }) async {
    if (locations != null) _preferredLocations = List.from(locations);
    if (categories != null) _jobCategories = List.from(categories);
    if (jobTypes != null) _preferredJobTypes = List.from(jobTypes);
    if (minSalary != null) _minSalaryLpa = minSalary;
    if (experience != null) _experience = experience;
    if (govtCategories != null) _preferredGovtCategories = List.from(govtCategories);
    if (govtAlerts != null) _notifGovtAlerts = govtAlerts;
    if (jobMatches != null) _notifJobMatches = jobMatches;
    if (deadlines != null) _notifDeadlines = deadlines;
    if (recommendations != null) _notifRecommendations = recommendations;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (locations != null) await prefs.setStringList(_locationsKey, _preferredLocations);
      if (categories != null) await prefs.setStringList(_categoriesKey, _jobCategories);
      if (jobTypes != null) await prefs.setStringList(_jobTypesKey, _preferredJobTypes);
      if (minSalary != null) await prefs.setDouble(_minSalaryKey, _minSalaryLpa);
      if (experience != null) await prefs.setString(_experienceKey, _experience);
      if (govtCategories != null) await prefs.setStringList(_govtCategoriesKey, _preferredGovtCategories);
      if (govtAlerts != null) await prefs.setBool(_notifGovtKey, _notifGovtAlerts);
      if (jobMatches != null) await prefs.setBool(_notifMatchesKey, _notifJobMatches);
      if (deadlines != null) await prefs.setBool(_notifDeadlinesKey, _notifDeadlines);
      if (recommendations != null) await prefs.setBool(_notifRecommendationsKey, _notifRecommendations);
    } catch (_) {}
  }

  Future<void> updateResume(String fileName, {DateTime? uploadedAt}) async {
    _resumeFileName = fileName;
    _resumeUploadedAt = uploadedAt ?? DateTime.now();
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

    await _secureStorage.clearAll();

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
