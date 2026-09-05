import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/auth_models.dart';
import '../data/repositories/auth_repository.dart';
import '../services/secure_storage_service.dart';

class AuthProvider with ChangeNotifier {
  static const String _tokenKey = 'jobvaani_auth_token';
  static const String _userIdKey = 'jobvaani_user_id';
  static const String _userNameKey = 'jobvaani_user_name';
  static const String _userEmailKey = 'jobvaani_user_email';
  static const String _userPhoneKey = 'jobvaani_user_phone';
  static const String _userLanguageKey = 'jobvaani_user_language';
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
  AuthUser? _currentUser;

  String _userName = 'Job Seeker';
  String _userEmail = '';
  String _userPhone = '';
  String _userLanguage = 'en';
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
  String? _resumeFileName = 'Resume.pdf';
  DateTime? _resumeUploadedAt;
  bool _isProfileCompleted = false;
  bool _notifGovtAlerts = true;
  bool _notifJobMatches = true;
  bool _notifDeadlines = true;
  bool _notifRecommendations = true;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  AuthUser? get currentUser => _currentUser;
  String? get userId => _currentUser?.id;
  String get userName => _currentUser?.name ?? _userName;
  String get userEmail => _currentUser?.email ?? _userEmail;
  String get userPhone => _currentUser?.phone ?? _userPhone;
  String get userLanguage => _currentUser?.language ?? _userLanguage;
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

  /// Verifies secure token storage and authenticates user on app startup
  Future<void> checkAuthState() async {
    try {
      final savedToken = await _secureStorage.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        _isAuthenticated = true;

        final userData = await _secureStorage.getUserData();
        if (userData != null) {
          _currentUser = AuthUser.fromJson(userData);
          _userName = _currentUser!.name;
          _userEmail = _currentUser!.email;
          if (_currentUser!.phone != null) _userPhone = _currentUser!.phone!;
          _userLanguage = _currentUser!.language;
        } else {
          final prefs = await SharedPreferences.getInstance();
          final email = prefs.getString(_userEmailKey) ?? '';
          final name = prefs.getString(_userNameKey) ?? 'Candidate';
          final id = prefs.getString(_userIdKey) ?? 'usr_${email.hashCode.abs()}';
          final lang = prefs.getString(_userLanguageKey) ?? 'en';
          _currentUser = AuthUser(id: id, name: name, email: email, language: lang);
          _userName = name;
          _userEmail = email;
          _userLanguage = lang;
        }

        final prefs = await SharedPreferences.getInstance();
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
        _currentUser = null;
        notifyListeners();
      }
    } catch (_) {
      _isAuthenticated = false;
      _token = null;
      _currentUser = null;
    }
  }

  /// Registers new user account with complete isolation
  Future<AuthResult> register(
    String name,
    String email,
    String password, {
    String? phone,
    String language = 'en',
  }) async {
    final result = await _authRepository.register(
      name: name,
      email: email,
      password: password,
      mobile: phone,
      language: language,
    );

    if (result.isSuccess && result.token != null) {
      _isAuthenticated = true;
      _token = result.token;
      _currentUser = result.user ??
          AuthUser(
            id: 'usr_${email.hashCode.abs()}',
            name: name,
            email: email,
            phone: phone,
            language: language,
          );

      _userName = _currentUser!.name;
      _userEmail = _currentUser!.email;
      _userPhone = _currentUser!.phone ?? '';
      _userLanguage = _currentUser!.language;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);
        await prefs.setString(_userIdKey, _currentUser!.id);
        await prefs.setString(_userNameKey, _userName);
        await prefs.setString(_userEmailKey, _userEmail);
        await prefs.setString(_userPhoneKey, _userPhone);
        await prefs.setString(_userLanguageKey, _userLanguage);
      } catch (_) {}

      notifyListeners();
    }

    return result;
  }

  /// Sends login request through AuthRepository with validation and secure token storage
  Future<AuthResult> login(String email, String password) async {
    final result = await _authRepository.login(email, password);

    if (result.isSuccess && result.token != null) {
      _isAuthenticated = true;
      _token = result.token;
      _currentUser = result.user ??
          AuthUser(
            id: 'usr_${email.hashCode.abs()}',
            name: email.contains('@') ? email.split('@').first : 'Candidate',
            email: email,
          );

      _userName = _currentUser!.name;
      _userEmail = _currentUser!.email;
      if (_currentUser!.phone != null) _userPhone = _currentUser!.phone!;
      _userLanguage = _currentUser!.language;
      if (_currentUser!.education != null) _education = _currentUser!.education!;
      if (_currentUser!.skills != null) _skills = _currentUser!.skills!;
      if (_currentUser!.locations != null) _preferredLocations = _currentUser!.locations!;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);
        await prefs.setString(_userIdKey, _currentUser!.id);
        await prefs.setString(_userNameKey, _userName);
        await prefs.setString(_userEmailKey, _userEmail);
        await prefs.setString(_userPhoneKey, _userPhone);
        await prefs.setString(_userLanguageKey, _userLanguage);
      } catch (_) {}

      notifyListeners();
    }

    return result;
  }

  Future<bool> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 700));
    _isAuthenticated = true;
    _token = 'google_oauth_${DateTime.now().millisecondsSinceEpoch}';
    _currentUser = AuthUser(
      id: 'usr_google_auth',
      name: 'Mowli Kumar',
      email: 'mowlikumar@gmail.com',
      phone: '+91 98765 43210',
      language: 'en',
    );
    _userName = _currentUser!.name;
    _userEmail = _currentUser!.email;
    _userPhone = _currentUser!.phone ?? '';

    await _secureStorage.saveToken(_token!);
    await _secureStorage.saveUserData(_currentUser!.toJson());

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
      await prefs.setString(_userIdKey, _currentUser!.id);
      await prefs.setString(_userNameKey, _userName);
      await prefs.setString(_userEmailKey, _userEmail);
    } catch (_) {}

    notifyListeners();
    return true;
  }

  Future<ForgotPasswordResponse> sendPasswordReset(String email) async {
    return _authRepository.sendPasswordReset(email);
  }

  Future<void> updateProfileDetails({
    String? name,
    String? email,
    String? phone,
    String? education,
  }) async {
    if (name != null && name.isNotEmpty) _userName = name;
    if (email != null && email.isNotEmpty) _userEmail = email;
    if (phone != null) _userPhone = phone;
    if (education != null) _education = education;

    if (_currentUser != null) {
      _currentUser = AuthUser(
        id: _currentUser!.id,
        name: _userName,
        email: _userEmail,
        phone: _userPhone,
        language: _currentUser!.language,
        education: _education,
        skills: _skills,
        locations: _preferredLocations,
      );
      await _secureStorage.saveUserData(_currentUser!.toJson());
    }

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, _userName);
      await prefs.setString(_userEmailKey, _userEmail);
      await prefs.setString(_userPhoneKey, _userPhone);
      await prefs.setString(_educationKey, _education);
    } catch (_) {}
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

    if (_currentUser != null) {
      _currentUser = AuthUser(
        id: _currentUser!.id,
        name: _userName,
        email: _userEmail,
        phone: _userPhone,
        language: _currentUser!.language,
        education: _education,
        skills: _skills,
        locations: _preferredLocations,
      );
      await _secureStorage.saveUserData(_currentUser!.toJson());
    }

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
    _currentUser = null;
    _userName = 'Job Seeker';
    _userEmail = '';
    _userPhone = '';
    _userLanguage = 'en';
    _education = '';
    _skills = [];
    _preferredLocations = [];
    _jobCategories = [];
    _isProfileCompleted = false;

    await _secureStorage.clearAll();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userPhoneKey);
      await prefs.remove(_userLanguageKey);
      await prefs.remove(_educationKey);
      await prefs.remove(_skillsKey);
      await prefs.remove(_locationsKey);
      await prefs.remove(_categoriesKey);
      await prefs.remove(_profileCompletedKey);
    } catch (_) {}

    notifyListeners();
  }
}
