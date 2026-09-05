import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/job_model.dart';
import '../data/models/govt_job_model.dart';
import '../data/models/job_filter_criteria.dart';
import '../data/models/notification_model.dart';
import '../services/deadline_alert_service.dart';
import '../services/notification_service.dart';

class JobsProvider with ChangeNotifier {
  static const String _readNotifsPrefKey = 'jobvaani_read_notif_ids';

  final Set<String> _savedJobIds = {};
  final Set<String> _readNotifIds = {};
  final List<NotificationModel> _dynamicAlerts = [];
  String? _currentUserId;
  String _selectedHomeCategory = 'all'; // 'all', 'govt', 'private', 'internship'
  String _searchQuery = '';
  JobFilterCriteria _filterCriteria = JobFilterCriteria.empty;

  Set<String> get savedJobIds => _savedJobIds;
  String? get currentUserId => _currentUserId;
  String get selectedHomeCategory => _selectedHomeCategory;
  String get searchQuery => _searchQuery;
  JobFilterCriteria get filterCriteria => _filterCriteria;

  String _getUserPrefKey() => (_currentUserId != null && _currentUserId!.isNotEmpty)
      ? 'jobvaani_saved_jobs_${_currentUserId}'
      : 'jobvaani_saved_jobs_guest';

  JobsProvider() {
    _loadSavedJobs();
    _initPushNotifications();
  }

  void _initPushNotifications() {
    NotificationService.instance.initialize(
      onMessageReceived: (payload) {
        receivePushNotification(payload.toNotificationModel());
      },
    );
  }

  void receivePushNotification(NotificationModel notif) {
    _dynamicAlerts.insert(0, notif);
    notifyListeners();
  }

  Future<void> _loadSavedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('jobvaani_user_id');
      final list = prefs.getStringList(_getUserPrefKey());
      if (list != null) {
        _savedJobIds.addAll(list);
      }

      final readNotifs = prefs.getStringList(_readNotifsPrefKey);
      if (readNotifs != null) {
        _readNotifIds.addAll(readNotifs);
      }
      checkDeadlineAlerts();
      notifyListeners();
    } catch (_) {}
  }

  /// Scopes saved jobs to the currently authenticated user
  Future<void> loadSavedJobsForUser(String userId, {String? token}) async {
    _currentUserId = userId;
    _savedJobIds.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_getUserPrefKey());
      if (list != null) {
        _savedJobIds.addAll(list);
      }
      checkDeadlineAlerts();
      notifyListeners();
    } catch (_) {}
  }

  /// Clears in-memory saved jobs and unbinds user session on logout
  void clearUserSessionData() {
    _currentUserId = null;
    _savedJobIds.clear();
    notifyListeners();
  }

  /// Evaluates active saved applications against deadline milestones (7d, 3d, 1d, 0d)
  /// and generates notifications for valid, non-expired jobs (Step 22).
  void checkDeadlineAlerts() {
    final savedJobs = _allJobs.where((j) => _savedJobIds.contains(j.id)).toList();
    final newAlerts = DeadlineAlertService.evaluateSavedJobs(savedJobs);
    if (newAlerts.isNotEmpty) {
      _dynamicAlerts.insertAll(0, newAlerts);
    }
  }

  bool isSaved(String jobId) => _savedJobIds.contains(jobId);

  Future<bool> toggleSave(String jobId) async {
    final willSave = !_savedJobIds.contains(jobId);
    if (willSave) {
      _savedJobIds.add(jobId);
      checkDeadlineAlerts();
    } else {
      _savedJobIds.remove(jobId);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_getUserPrefKey(), _savedJobIds.toList());
    } catch (_) {}
    return willSave;
  }

  Future<void> clearAllSaved() async {
    _savedJobIds.clear();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_getUserPrefKey(), []);
    } catch (_) {}
  }

  void setSelectedHomeCategory(String category) {
    if (_selectedHomeCategory != category) {
      _selectedHomeCategory = category;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setFilterCriteria(JobFilterCriteria criteria) {
    _filterCriteria = criteria;
    notifyListeners();
  }

  void clearFilters() {
    _filterCriteria = JobFilterCriteria.empty;
    notifyListeners();
  }

  // --- Step 14: Notifications Architecture ---
  static final List<NotificationModel> _initialNotifications = [
    NotificationModel(
      id: 'notif_01',
      title: 'New Job Match: 98% Match',
      message: 'New Cybersecurity job matches your profile: Security Operations & Threat Hunter at Paytm.',
      type: NotificationType.newJobMatch,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      relatedJobId: 'job_paytm_cyber_04',
      targetRoute: 'job_details',
    ),
    NotificationModel(
      id: 'notif_02',
      title: 'Deadline Approaching',
      message: 'Your saved job closes tomorrow: UPSC Assistant Executive Engineer (Telecom). Complete your application now.',
      type: NotificationType.deadlineReminder,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      relatedJobId: 'job_upsc_02',
      targetRoute: 'job_details',
    ),
    NotificationModel(
      id: 'notif_03',
      title: 'Government Job Alert',
      message: "ISRO Scientist / Engineer 'SC' (Computer Science) 68 openings published at URSC/ISTRAC. Apply online.",
      type: NotificationType.govtJobAlert,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      relatedJobId: 'job_isro_01',
      targetRoute: 'job_details',
    ),
    NotificationModel(
      id: 'notif_04',
      title: 'Top Recommendation For You',
      message: 'Senior Mobile Flutter Engineer opening at Swiggy India (₹28L - ₹42L LPA) matches your technical profile.',
      type: NotificationType.recommendation,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      relatedJobId: 'job_swiggy_03',
      targetRoute: 'job_details',
    ),
    NotificationModel(
      id: 'notif_05',
      title: 'SSC CGL 2026 Notification',
      message: 'Staff Selection Commission announces 17,727 vacancies for Inspector / ASO across central ministries.',
      type: NotificationType.govtJobAlert,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      relatedJobId: 'govt_ssc_01',
      targetRoute: 'govt_job_details',
    ),
    NotificationModel(
      id: 'notif_06',
      title: 'Welcome to JobVaani 🎉',
      message: 'Your native language preference is set. You will receive verified government alerts, instant job matches, and deadline reminders here.',
      type: NotificationType.system,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      targetRoute: 'profile',
    ),
  ];

  final List<String> _deletedNotifIds = [];

  List<NotificationModel> get notifications {
    final combined = [..._dynamicAlerts, ..._initialNotifications];
    return combined
        .where((n) => !_deletedNotifIds.contains(n.id))
        .map((n) => n.copyWith(isRead: _readNotifIds.contains(n.id)))
        .toList();
  }

  int get unreadNotifications => notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get unreadNotificationList =>
      notifications.where((n) => !n.isRead).toList();

  Future<void> markNotificationAsRead(String id) async {
    if (!_readNotifIds.contains(id)) {
      _readNotifIds.add(id);
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_readNotifsPrefKey, _readNotifIds.toList());
      } catch (_) {}
    }
  }

  Future<void> toggleNotificationRead(String id) async {
    if (_readNotifIds.contains(id)) {
      _readNotifIds.remove(id);
    } else {
      _readNotifIds.add(id);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_readNotifsPrefKey, _readNotifIds.toList());
    } catch (_) {}
  }

  Future<void> markAllNotificationsAsRead() async {
    for (final n in _initialNotifications) {
      _readNotifIds.add(n.id);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_readNotifsPrefKey, _readNotifIds.toList());
    } catch (_) {}
  }

  void markNotificationsRead() {
    markAllNotificationsAsRead();
  }

  void deleteNotification(String id) {
    _deletedNotifIds.add(id);
    notifyListeners();
  }

  void clearAllNotifications() {
    for (final n in _initialNotifications) {
      _deletedNotifIds.add(n.id);
    }
    notifyListeners();
  }

  JobModel? getJobById(String id) {
    try {
      return _allJobs.firstWhere((j) => j.id == id);
    } catch (_) {
      try {
        final gj = _govtJobs.firstWhere((j) => j.id == id);
        return gj.toJobModel();
      } catch (_) {
        return null;
      }
    }
  }

  GovtJobModel? getGovtJobById(String id) {
    try {
      return _govtJobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Curated Multi-Category Dataset ---
  static final List<JobModel> _allJobs = [
    // 1. Govt - ISRO
    JobModel(
      id: 'job_isro_01',
      title: "Scientist / Engineer 'SC' (Computer Science)",
      company: "ISRO",
      organization: "Department of Space, Govt. of India",
      location: "Bengaluru, Karnataka",
      salary: "₹12L - ₹16L LPA (Level 10)",
      minSalaryLpa: 12.0,
      jobType: "Government",
      category: "govt",
      subCategory: "software_dev",
      deadline: "12 Oct 2026",
      deadlineDate: DateTime(2026, 10, 12),
      postedDate: DateTime.now().subtract(const Duration(days: 1)),
      matchPercentage: 96,
      experienceLevel: "Fresher",
      qualification: "Graduate",
      skills: ["C++", "Python", "Operating Systems", "Computer Networks", "Algorithms"],
      vacancies: 68,
      isClosingSoon: false,
      isGovernmentAlert: true,
      isRecommended: true,
      description: "Recruitment of Scientist/Engineer 'SC' in Level 10 of Pay Matrix at URSC/ISTRAC. Responsible for satellite ground stations, mission data pipelines, and embedded aerospace flight software.",
      eligibility: "B.E/B.Tech in CS/IT with aggregate 65% marks or CGPA 6.84/10 + valid GATE score.",
      applyUrl: "https://www.isro.gov.in/careers",
    ),

    // 2. Govt - UPSC
    JobModel(
      id: 'job_upsc_02',
      title: "Assistant Executive Engineer (Electronics & Telecom)",
      company: "UPSC",
      organization: "Union Public Service Commission",
      location: "New Delhi (Pan-India)",
      salary: "₹14L - ₹18L LPA (7th CPC)",
      minSalaryLpa: 14.0,
      jobType: "Government",
      category: "govt",
      subCategory: "other",
      deadline: "18 Sep 2026",
      deadlineDate: DateTime(2026, 9, 18),
      postedDate: DateTime.now().subtract(const Duration(days: 3)),
      matchPercentage: 92,
      experienceLevel: "1-3 Years",
      qualification: "Graduate",
      skills: ["Telecom", "Signal Processing", "RF Systems", "Embedded Systems", "General Studies"],
      vacancies: 112,
      isClosingSoon: true,
      isGovernmentAlert: true,
      isRecommended: true,
      description: "Combined Engineering Services Examination for Central Telecom & Signal Cadres. Leadership opportunities across national defence and civil communication networks.",
      eligibility: "Degree in Electronics & Communication / Telecommunication Engineering from a recognized university.",
      applyUrl: "https://upsconline.nic.in",
    ),

    // 3. Private - Software Dev: Swiggy
    JobModel(
      id: 'job_swiggy_03',
      title: "Senior Mobile Flutter Engineer (Consumer App)",
      company: "Swiggy India",
      organization: "Bundl Technologies Pvt Ltd",
      location: "Bengaluru, Karnataka (Hybrid)",
      salary: "₹28L - ₹42L LPA + ESOPs",
      minSalaryLpa: 28.0,
      jobType: "Full Time",
      category: "private",
      subCategory: "software_dev",
      deadline: "30 Sep 2026",
      deadlineDate: DateTime(2026, 9, 30),
      postedDate: DateTime.now().subtract(const Duration(hours: 6)),
      matchPercentage: 98,
      experienceLevel: "3-5 Years",
      qualification: "Graduate",
      skills: ["Flutter", "Dart", "State Management", "REST APIs", "CI/CD", "App Performance"],
      vacancies: 6,
      isClosingSoon: false,
      isGovernmentAlert: false,
      isRecommended: true,
      description: "Build high-throughput mobile user experiences for 50M+ active food & grocery delivery shoppers across 500+ Indian cities.",
      eligibility: "B.Tech/MCA with 3+ years architecting production Flutter applications with Bloc or Provider.",
      applyUrl: "https://careers.swiggy.com",
    ),

    // 4. Private - Cybersecurity: Paytm
    JobModel(
      id: 'job_paytm_cyber_04',
      title: "Security Operations & Threat Hunter",
      company: "Paytm",
      organization: "One97 Communications Ltd",
      location: "Noida / Delhi NCR",
      salary: "₹18L - ₹26L LPA",
      minSalaryLpa: 18.0,
      jobType: "Full Time",
      category: "private",
      subCategory: "cybersecurity",
      deadline: "08 Oct 2026",
      deadlineDate: DateTime(2026, 10, 8),
      postedDate: DateTime.now().subtract(const Duration(hours: 18)),
      matchPercentage: 91,
      experienceLevel: "1-3 Years",
      qualification: "Graduate",
      skills: ["SIEM", "SOC", "Incident Response", "Network Security", "Threat Intelligence", "Python"],
      vacancies: 5,
      isClosingSoon: false,
      isGovernmentAlert: false,
      isRecommended: true,
      description: "Safeguard millions of digital financial transactions every day. Monitor SIEM telemetry, investigate threat vectors, and secure cloud microservices.",
      eligibility: "B.Tech in CS/IT or CEH/CISSP certification with 2+ years security operations experience.",
      applyUrl: "https://paytm.com/careers",
    ),

    // 4b. Featured AI Recommendation Match: 87% Match (Steps 20 & 21)
    JobModel(
      id: 'job_cyber_sec_ops_05',
      title: "Cybersecurity Operations & Infrastructure Engineer",
      company: "Paytm Security Labs",
      organization: "One97 Communications Ltd",
      location: "Noida / Delhi NCR",
      salary: "₹18L - ₹28L LPA",
      minSalaryLpa: 18.0,
      jobType: "Full Time",
      category: "private",
      subCategory: "cybersecurity",
      deadline: "20 Sep 2026",
      deadlineDate: DateTime(2026, 9, 20),
      postedDate: DateTime.now().subtract(const Duration(hours: 8)),
      matchPercentage: 87,
      experienceLevel: "1-3 Years",
      qualification: "Graduate",
      skills: ["Python", "SQL", "Linux", "Cybersecurity", "Networking"],
      vacancies: 6,
      isClosingSoon: false,
      isGovernmentAlert: false,
      isRecommended: true,
      description: "Safeguard high-throughput payment microservices against advanced persistent threats. Monitor SIEM telemetry, automate incident response playbooks with Python, and configure secure Linux bastions.",
      eligibility: "B.Tech/BE in CS/IT or BCA/MCA with knowledge of Linux administration, SQL queries, Python automation, and computer networking fundamentals.",
      applyUrl: "https://paytm.com/careers",
    ),

    // 5. Private - Data Science: Flipkart
    JobModel(
      id: 'job_flipkart_ds_05',
      title: "Lead Data Scientist (E-Commerce & Supply Chain)",
      company: "Flipkart",
      organization: "Flipkart Internet Pvt Ltd",
      location: "Bengaluru, Karnataka",
      salary: "₹26L - ₹38L LPA",
      minSalaryLpa: 26.0,
      jobType: "Full Time",
      category: "private",
      subCategory: "data_science",
      deadline: "14 Oct 2026",
      deadlineDate: DateTime(2026, 10, 14),
      postedDate: DateTime.now().subtract(const Duration(days: 1)),
      matchPercentage: 94,
      experienceLevel: "3-5 Years",
      qualification: "Graduate",
      skills: ["Python", "Pandas", "PySpark", "Machine Learning", "Demand Forecasting", "SQL"],
      vacancies: 4,
      isClosingSoon: false,
      isGovernmentAlert: false,
      isRecommended: true,
      description: "Develop optimization models, customer lifetime value algorithms, and delivery route forecasting models serving India's premier festive sales.",
      eligibility: "Bachelor's or Master's in Computer Science, Statistics, Mathematics or Data Science.",
      applyUrl: "https://www.flipkartcareers.com",
    ),

    // 6. Private - AI/ML: Sarvam AI
    JobModel(
      id: 'job_sarvam_aiml_06',
      title: "Machine Learning Engineer (Indic LLMs & GenAI)",
      company: "Sarvam AI",
      organization: "Sarvam Artificial Intelligence Pvt Ltd",
      location: "Bengaluru, Karnataka (Onsite)",
      salary: "₹30L - ₹45L LPA + Equity",
      minSalaryLpa: 30.0,
      jobType: "Full Time",
      category: "private",
      subCategory: "ai_ml",
      deadline: "22 Sep 2026",
      deadlineDate: DateTime(2026, 9, 22),
      postedDate: DateTime.now().subtract(const Duration(hours: 12)),
      matchPercentage: 97,
      experienceLevel: "1-3 Years",
      qualification: "Post Graduate",
      skills: ["PyTorch", "Transformers", "LLMs", "Indic NLP", "Distributed Training", "CUDA"],
      vacancies: 3,
      isClosingSoon: true,
      isGovernmentAlert: false,
      isRecommended: true,
      description: "Train and align state-of-the-art generative artificial intelligence foundation models across 22 scheduled Indian languages for enterprise adoption.",
      eligibility: "Master's or PhD with hands-on research in NLP, LLM pre-training, fine-tuning, or speech synthesis.",
      applyUrl: "https://sarvam.ai/careers",
    ),

    // 7. Private - Cloud: Microsoft India
    JobModel(
      id: 'job_micro_cloud_07',
      title: "Cloud Solutions Architect (Azure Enterprise)",
      company: "Microsoft India",
      organization: "Microsoft India Development Center (IDC)",
      location: "Hyderabad, Telangana",
      salary: "₹32L - ₹48L LPA + Stocks",
      minSalaryLpa: 32.0,
      jobType: "Full Time",
      category: "private",
      subCategory: "cloud",
      deadline: "05 Oct 2026",
      deadlineDate: DateTime(2026, 10, 5),
      postedDate: DateTime.now().subtract(const Duration(hours: 14)),
      matchPercentage: 95,
      experienceLevel: "3-5 Years",
      qualification: "Graduate",
      skills: ["Azure", "Cloud Architecture", "Microservices", "Security", "Kubernetes", "DevOps"],
      vacancies: 8,
      isClosingSoon: false,
      isGovernmentAlert: false,
      isRecommended: true,
      description: "Guide large Indian enterprises and public institutions through zero-trust cloud migration, scalable architectures, and intelligent hybrid deployments.",
      eligibility: "Bachelor's degree in CS/ECE or equivalent with 3+ years software/cloud engineering experience.",
      applyUrl: "https://careers.microsoft.com",
    ),

    // 8. Private - DevOps: TCS Digital
    JobModel(
      id: 'job_tcs_devops_08',
      title: "Cloud DevOps & Platform Specialist",
      company: "TCS",
      organization: "Tata Consultancy Services Digital",
      location: "Hyderabad, Telangana",
      salary: "₹10L - ₹15L LPA",
      minSalaryLpa: 10.0,
      jobType: "Full Time",
      category: "private",
      subCategory: "devops",
      deadline: "15 Oct 2026",
      deadlineDate: DateTime(2026, 10, 15),
      postedDate: DateTime.now().subtract(const Duration(days: 5)),
      matchPercentage: 85,
      experienceLevel: "1-3 Years",
      qualification: "Graduate",
      skills: ["AWS", "Kubernetes", "Docker", "Terraform", "Linux", "Python"],
      vacancies: 25,
      isClosingSoon: false,
      isGovernmentAlert: false,
      isRecommended: false,
      description: "Design and maintain resilient cloud infrastructure, automated GitOps pipelines, and microservices observability for global banking clients.",
      eligibility: "B.E/B.Tech/MCA with hands-on experience in AWS or GCP, container orchestration, and IaC.",
      applyUrl: "https://www.tcs.com/careers",
    ),

    // 9. Private - Testing: Zomato
    JobModel(
      id: 'job_zomato_test_09',
      title: "Lead Quality Assurance Engineer (Test Automation)",
      company: "Zomato",
      organization: "Zomato Ltd",
      location: "Gurugram, Haryana",
      salary: "₹16L - ₹24L LPA",
      minSalaryLpa: 16.0,
      jobType: "Full Time",
      category: "private",
      subCategory: "testing",
      deadline: "24 Sep 2026",
      deadlineDate: DateTime(2026, 9, 24),
      postedDate: DateTime.now().subtract(const Duration(days: 2)),
      matchPercentage: 89,
      experienceLevel: "3-5 Years",
      qualification: "Graduate",
      skills: ["Selenium", "Appium", "Java", "TestNG", "RestAssured", "Performance Testing"],
      vacancies: 6,
      isClosingSoon: true,
      isGovernmentAlert: false,
      isRecommended: true,
      description: "Own end-to-end automation pipelines for iOS and Android delivery apps, real-time tracking systems, and restaurant merchant dashboards.",
      eligibility: "B.Tech/MCA with 3+ years writing robust test automation suites and load testing frameworks.",
      applyUrl: "https://www.zomato.com/careers",
    ),

    // 10. Private - Sales: Freshworks
    JobModel(
      id: 'job_freshworks_sales_10',
      title: "Enterprise Account Executive (SaaS Solutions)",
      company: "Freshworks",
      organization: "Freshworks Technologies India",
      location: "Chennai, Tamil Nadu",
      salary: "₹14L - ₹22L LPA + Incentives",
      minSalaryLpa: 14.0,
      jobType: "Full Time",
      category: "private",
      subCategory: "sales",
      deadline: "12 Oct 2026",
      deadlineDate: DateTime(2026, 10, 12),
      postedDate: DateTime.now().subtract(const Duration(days: 3)),
      matchPercentage: 86,
      experienceLevel: "1-3 Years",
      qualification: "Graduate",
      skills: ["B2B Sales", "SaaS", "Negotiation", "Client Pitching", "CRM", "Revenue Growth"],
      vacancies: 8,
      isClosingSoon: false,
      isGovernmentAlert: false,
      isRecommended: false,
      description: "Drive cloud software expansion across mid-market and enterprise accounts in India and Southeast Asia for customer support and CRM products.",
      eligibility: "Bachelor's degree with 2+ years proven track record closing software B2B deals.",
      applyUrl: "https://www.freshworks.com/company/careers",
    ),

    // 11. Private - Marketing: Zepto
    JobModel(
      id: 'job_zepto_mktg_11',
      title: "Growth & Performance Marketing Lead",
      company: "Zepto",
      organization: "KiranaKart Technologies Pvt Ltd",
      location: "Mumbai, Maharashtra",
      salary: "₹18L - ₹28L LPA",
      minSalaryLpa: 18.0,
      jobType: "Full Time",
      category: "private",
      subCategory: "marketing",
      deadline: "20 Sep 2026",
      deadlineDate: DateTime(2026, 9, 20),
      postedDate: DateTime.now().subtract(const Duration(days: 1)),
      matchPercentage: 90,
      experienceLevel: "1-3 Years",
      qualification: "Graduate",
      skills: ["Growth Marketing", "Google Ads", "Meta Ads", "App Installs", "Retention", "Cohort Analysis"],
      vacancies: 3,
      isClosingSoon: true,
      isGovernmentAlert: false,
      isRecommended: true,
      description: "Scale user acquisition, app engagement, and quick-commerce basket values through data-driven campaigns and localized customer experiments.",
      eligibility: "Graduate with strong analytical skills, experience handling digital ad budgets of ₹1Cr+.",
      applyUrl: "https://www.zeptonow.com/careers",
    ),

    // 12. Private - Finance: HDFC Bank
    JobModel(
      id: 'job_hdfc_fin_12',
      title: "Corporate Finance & Investment Banking Analyst",
      company: "HDFC Bank",
      organization: "HDFC Bank Ltd",
      location: "Mumbai, Maharashtra",
      salary: "₹15L - ₹22L LPA",
      minSalaryLpa: 15.0,
      jobType: "Full Time",
      category: "private",
      subCategory: "finance",
      deadline: "16 Oct 2026",
      deadlineDate: DateTime(2026, 10, 16),
      postedDate: DateTime.now().subtract(const Duration(days: 4)),
      matchPercentage: 88,
      experienceLevel: "1-3 Years",
      qualification: "Post Graduate",
      skills: ["Financial Modeling", "Valuation", "Credit Analysis", "Mergers & Acquisitions", "Excel"],
      vacancies: 10,
      isClosingSoon: false,
      isGovernmentAlert: false,
      isRecommended: false,
      description: "Analyze corporate balance sheets, structure debt financing proposals, and prepare investment memoranda for top Indian corporate syndicates.",
      eligibility: "CA / MBA Finance / CFA with 1-3 years experience in banking, equity research or treasury.",
      applyUrl: "https://www.hdfcbank.com/careers",
    ),

    // 13. Private - HR: Infosys
    JobModel(
      id: 'job_infosys_hr_13',
      title: "Senior Talent Acquisition Specialist (Tech)",
      company: "Infosys",
      organization: "Infosys Ltd",
      location: "Pune, Maharashtra",
      salary: "₹11L - ₹16L LPA",
      minSalaryLpa: 11.0,
      jobType: "Full Time",
      category: "private",
      subCategory: "hr",
      deadline: "11 Oct 2026",
      deadlineDate: DateTime(2026, 10, 11),
      postedDate: DateTime.now().subtract(const Duration(days: 2)),
      matchPercentage: 87,
      experienceLevel: "1-3 Years",
      qualification: "Graduate",
      skills: ["Technical Recruiting", "Sourcing", "HRBP", "Candidate Experience", "LinkedIn Recruiter"],
      vacancies: 12,
      isClosingSoon: false,
      isGovernmentAlert: false,
      isRecommended: false,
      description: "Spearhead lateral technical hiring for AI, Cloud, and full-stack engineering cohorts. Manage candidate pipeline and campus outreach programs.",
      eligibility: "MBA in HR or Bachelor's with 2+ years technology staffing experience.",
      applyUrl: "https://www.infosys.com/careers",
    ),

    // 14. Private - Other: Ola Mobility
    JobModel(
      id: 'job_ola_other_14',
      title: "Technical Product Manager (EV & Fleet Tech)",
      company: "Ola Mobility",
      organization: "ANI Technologies Pvt Ltd",
      location: "Bengaluru, Karnataka",
      salary: "₹25L - ₹38L LPA",
      minSalaryLpa: 25.0,
      jobType: "Full Time",
      category: "private",
      subCategory: "other",
      deadline: "28 Sep 2026",
      deadlineDate: DateTime(2026, 9, 28),
      postedDate: DateTime.now().subtract(const Duration(days: 3)),
      matchPercentage: 93,
      experienceLevel: "3-5 Years",
      qualification: "Graduate",
      skills: ["Product Roadmap", "Fleet Telematics", "IoT", "Agile", "User Experience", "Data Analytics"],
      vacancies: 2,
      isClosingSoon: false,
      isGovernmentAlert: false,
      isRecommended: true,
      description: "Define product roadmap for electric two-wheeler IoT telematics, battery charging networks, and driver partner mobile apps.",
      eligibility: "B.Tech + MBA with 3+ years managing software or hardware-integrated tech products.",
      applyUrl: "https://www.olaelectric.com/careers",
    ),

    // 15. Internship - Google India
    JobModel(
      id: 'job_google_04',
      title: "Software Engineering Summer Intern 2026",
      company: "Google India",
      organization: "Alphabet India Tech Hub",
      location: "Bengaluru / Hyderabad",
      salary: "₹1,25,000 / month",
      minSalaryLpa: 15.0,
      jobType: "Internship",
      category: "internship",
      subCategory: "software_dev",
      deadline: "20 Sep 2026",
      deadlineDate: DateTime(2026, 9, 20),
      postedDate: DateTime.now().subtract(const Duration(days: 2)),
      matchPercentage: 94,
      experienceLevel: "Fresher",
      qualification: "Graduate",
      skills: ["Data Structures", "Algorithms", "Java", "Python", "Distributed Systems"],
      vacancies: 40,
      isClosingSoon: true,
      isGovernmentAlert: false,
      isRecommended: true,
      description: "12-week summer internship working on core Google Search, Android ecosystem, Payments, and Google Cloud with Pre-Placement Offer (PPO) opportunities.",
      eligibility: "Enrolled in Bachelor's or Master's program in Computer Science graduating in 2027.",
      applyUrl: "https://careers.google.com/jobs",
    ),

    // 16. Govt - SSC CGL
    JobModel(
      id: 'job_ssc_05',
      title: "SSC Combined Graduate Level (CGL) - Inspector Posts",
      company: "SSC",
      organization: "Staff Selection Commission (Govt. of India)",
      location: "Pan-India Posting",
      salary: "₹7.5L - ₹11L LPA (Level 7)",
      minSalaryLpa: 7.5,
      jobType: "Government",
      category: "govt",
      subCategory: "other",
      deadline: "15 Sep 2026",
      deadlineDate: DateTime(2026, 9, 15),
      postedDate: DateTime.now().subtract(const Duration(days: 4)),
      matchPercentage: 88,
      experienceLevel: "Fresher",
      qualification: "Graduate",
      skills: ["Quantitative Aptitude", "Reasoning", "English Comprehension", "General Awareness"],
      vacancies: 8400,
      isClosingSoon: true,
      isGovernmentAlert: true,
      isRecommended: false,
      description: "Recruitment for Inspector (Central Excise), Preventive Officer, Examiner, and Assistant Section Officer in Central Ministries and Departments.",
      eligibility: "Bachelor's Degree in any discipline from a recognized University. Age: 18-30 years.",
      applyUrl: "https://ssc.gov.in",
    ),

    // 17. Govt - RBI
    JobModel(
      id: 'job_rbi_07',
      title: "Officer Grade 'B' (General / DEPR / DSIM)",
      company: "RBI",
      organization: "Reserve Bank of India",
      location: "Mumbai, Maharashtra",
      salary: "₹24L - ₹28L CTC (Level B)",
      minSalaryLpa: 24.0,
      jobType: "Government",
      category: "govt",
      subCategory: "finance",
      deadline: "10 Oct 2026",
      deadlineDate: DateTime(2026, 10, 10),
      postedDate: DateTime.now().subtract(const Duration(days: 2)),
      matchPercentage: 90,
      experienceLevel: "Fresher",
      qualification: "Post Graduate",
      skills: ["Economics", "Finance", "Management", "Statistics", "Quantitative Aptitude"],
      vacancies: 290,
      isClosingSoon: false,
      isGovernmentAlert: true,
      isRecommended: true,
      description: "Direct entry central banking executive role driving monetary policy, financial stability, foreign exchange supervision, and banking regulation in India.",
      eligibility: "Graduation with minimum 60% marks (50% for SC/ST/PwBD) or Post-Graduation with 55% marks.",
      applyUrl: "https://www.rbi.org.in/careers",
    ),

    // 18. Internship - IIT Madras
    JobModel(
      id: 'job_iit_09',
      title: "Generative AI Research & Development Intern",
      company: "IIT Madras",
      organization: "Center for Innovation & AI Research, IIT Madras",
      location: "Chennai, Tamil Nadu (Onsite)",
      salary: "₹45,000 / month",
      minSalaryLpa: 5.4,
      jobType: "Internship",
      category: "internship",
      subCategory: "ai_ml",
      deadline: "16 Sep 2026",
      deadlineDate: DateTime(2026, 9, 16),
      postedDate: DateTime.now().subtract(const Duration(days: 3)),
      matchPercentage: 89,
      experienceLevel: "Fresher",
      qualification: "Graduate",
      skills: ["PyTorch", "Python", "Transformers", "NLP", "Indic Languages"],
      vacancies: 12,
      isClosingSoon: true,
      isGovernmentAlert: false,
      isRecommended: true,
      description: "Research Indian language speech-to-text models, Indic LLMs, and multilingual document synthesis with leading research faculties.",
      eligibility: "Pre-final or final year engineering students with demonstrated projects in ML or Deep Learning.",
      applyUrl: "https://www.iitm.ac.in",
    ),

    // 19. Govt - Railway RRB
    JobModel(
      id: 'job_rrb_10',
      title: "Junior Engineer (JE) - Signal & Telecommunication",
      company: "Indian Railways",
      organization: "Railway Recruitment Control Board (RRB)",
      location: "Secunderabad / South Central Railway",
      salary: "₹6L - ₹9L LPA (Level 6)",
      minSalaryLpa: 6.0,
      jobType: "Government",
      category: "govt",
      subCategory: "other",
      deadline: "14 Sep 2026",
      deadlineDate: DateTime(2026, 9, 14),
      postedDate: DateTime.now().subtract(const Duration(days: 6)),
      matchPercentage: null,
      experienceLevel: "Fresher",
      qualification: "Diploma",
      skills: ["Electronic Circuits", "Signaling Systems", "Microprocessors", "Safety Standards"],
      vacancies: 1850,
      isClosingSoon: true,
      isGovernmentAlert: true,
      isRecommended: false,
      description: "Supervise electronic interlocking, Kavach anti-collision train safety systems, and optical fiber telemetry networks across Indian Railways.",
      eligibility: "Three years Diploma or B.Tech in Electrical / Electronics / IT / Computer Science.",
      applyUrl: "https://www.rrbcdg.gov.in",
    ),

    // 20. Private - Software Dev: Razorpay
    JobModel(
      id: 'job_startup_12',
      title: "Backend Go Developer (FinTech Infra)",
      company: "Razorpay",
      organization: "Razorpay Software Pvt Ltd",
      location: "Bengaluru, Karnataka (Remote Optional)",
      salary: null, // Nullable salary test
      minSalaryLpa: 0.0,
      jobType: "Full Time",
      category: "private",
      subCategory: "software_dev",
      deadline: "10 Oct 2026",
      deadlineDate: DateTime(2026, 10, 10),
      postedDate: DateTime.now().subtract(const Duration(days: 2)),
      matchPercentage: 91,
      experienceLevel: "1-3 Years",
      qualification: "Graduate",
      skills: ["Golang", "PostgreSQL", "Kafka", "Redis", "Distributed Systems", "UPI APIs"],
      vacancies: 4,
      isClosingSoon: false,
      isGovernmentAlert: false,
      isRecommended: true,
      description: "Build robust payment settlement pipelines processing millions of transactions per hour with 99.999% availability.",
      eligibility: "Strong coding proficiency in Go or C++, understanding of database transactions and concurrent architectures.",
      applyUrl: "https://razorpay.com/jobs",
    ),
  ];

  List<JobModel> get allJobs => _allJobs;

  List<JobModel> get savedJobs {
    final list = _allJobs.where((j) => _savedJobIds.contains(j.id)).toList();
    for (final gj in _govtJobs) {
      if (_savedJobIds.contains(gj.id) && !list.any((j) => j.id == gj.id)) {
        list.add(gj.toJobModel());
      }
    }
    return list;
  }

  List<JobModel> get savedPrivateJobs =>
      savedJobs.where((j) => j.category == 'private').toList();

  List<JobModel> get savedGovtJobs =>
      savedJobs.where((j) => j.isGovt).toList();

  List<JobModel> get savedInternships =>
      savedJobs.where((j) => j.isInternship).toList();

  // Step 9: Private Sector Jobs Getters
  List<JobModel> get privateJobs =>
      _allJobs.where((j) => j.category == 'private').toList();

  List<JobModel> getPrivateJobsBySubCategory(String? subCategory, {String query = ''}) {
    var list = _allJobs.where((j) => j.category == 'private').toList();
    if (subCategory != null && subCategory.isNotEmpty && subCategory != 'all') {
      list = list.where((j) => j.subCategory == subCategory).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((j) =>
          j.title.toLowerCase().contains(q) ||
          j.company.toLowerCase().contains(q) ||
          j.location.toLowerCase().contains(q) ||
          j.skills.any((s) => s.toLowerCase().contains(q))).toList();
    }
    return list;
  }

  // Step 7: Home Screen Required Sections
  List<JobModel> get latestJobs {
    final filtered = _filterByHomeCategory(_allJobs);
    final list = List<JobModel>.from(filtered);
    list.sort((a, b) => b.postedDate.compareTo(a.postedDate));
    return list.take(6).toList();
  }

  List<JobModel> get recommendedJobs {
    final filtered = _filterByHomeCategory(_allJobs);
    final list = filtered.where((j) => j.isRecommended || (j.matchPercentage != null && j.matchPercentage! >= 85)).toList();
    list.sort((a, b) => (b.matchPercentage ?? 0).compareTo(a.matchPercentage ?? 0));
    return list.take(6).toList();
  }

  List<JobModel> get closingSoonJobs {
    final filtered = _filterByHomeCategory(_allJobs);
    final list = filtered.where((j) => j.isClosingSoon || j.deadlineDate.difference(DateTime.now()).inDays <= 14).toList();
    list.sort((a, b) => a.deadlineDate.compareTo(b.deadlineDate));
    return list.take(6).toList();
  }

  List<JobModel> get governmentAlerts {
    final list = _allJobs.where((j) => j.isGovt).toList();
    list.sort((a, b) => b.postedDate.compareTo(a.postedDate));
    return list.take(6).toList();
  }

  List<JobModel> _filterByHomeCategory(List<JobModel> list) {
    if (_selectedHomeCategory == 'all') return list;
    if (_selectedHomeCategory == 'govt') return list.where((j) => j.category == 'govt' || j.isGovernmentAlert).toList();
    if (_selectedHomeCategory == 'private') return list.where((j) => j.category == 'private').toList();
    if (_selectedHomeCategory == 'internship') return list.where((j) => j.isInternship).toList();
    return list;
  }

  // Step 8: Search Screen Filtering
  List<JobModel> get searchResults {
    List<JobModel> results = List.from(_allJobs);

    // 1. Text Query Filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      results = results.where((j) {
        final titleMatch = j.title.toLowerCase().contains(q);
        final companyMatch = j.company.toLowerCase().contains(q);
        final orgMatch = j.organization.toLowerCase().contains(q);
        final locationMatch = j.location.toLowerCase().contains(q);
        final skillMatch = j.skills.any((s) => s.toLowerCase().contains(q));
        return titleMatch || companyMatch || orgMatch || locationMatch || skillMatch;
      }).toList();
    }

    // 2. Category Filter
    if (_filterCriteria.category != null && _filterCriteria.category != 'all') {
      results = results.where((j) {
        if (_filterCriteria.category == 'govt') return j.isGovt;
        if (_filterCriteria.category == 'private') return j.category == 'private';
        if (_filterCriteria.category == 'internship') return j.isInternship;
        return true;
      }).toList();
    }

    // 3. Job Type Filter
    if (_filterCriteria.jobType != null && _filterCriteria.jobType != 'All Job Types') {
      results = results.where((j) => j.jobType.toLowerCase().contains(_filterCriteria.jobType!.toLowerCase())).toList();
    }

    // 4. Location Filter
    if (_filterCriteria.location != null && _filterCriteria.location != 'All Locations') {
      final loc = _filterCriteria.location!.toLowerCase();
      results = results.where((j) => j.location.toLowerCase().contains(loc)).toList();
    }

    // 5. Minimum Salary Filter
    if (_filterCriteria.minSalaryLpa != null && _filterCriteria.minSalaryLpa! > 0) {
      results = results.where((j) => j.minSalaryLpa >= _filterCriteria.minSalaryLpa!).toList();
    }

    // 6. Experience Level Filter
    if (_filterCriteria.experience != null && _filterCriteria.experience!.isNotEmpty) {
      results = results.where((j) => j.experienceLevel.toLowerCase() == _filterCriteria.experience!.toLowerCase()).toList();
    }

    // 7. Qualification Filter
    if (_filterCriteria.qualification != null && _filterCriteria.qualification!.isNotEmpty) {
      results = results.where((j) => j.qualification.toLowerCase() == _filterCriteria.qualification!.toLowerCase()).toList();
    }

    // 8. Skills Filter
    if (_filterCriteria.skills.isNotEmpty) {
      results = results.where((j) {
        return _filterCriteria.skills.every((reqSkill) =>
            j.skills.any((s) => s.toLowerCase().contains(reqSkill.toLowerCase())));
      }).toList();
    }

    // 9. Posted Date Filter
    if (_filterCriteria.postedDateFilter != null && _filterCriteria.postedDateFilter != 'all') {
      final now = DateTime.now();
      results = results.where((j) {
        final diff = now.difference(j.postedDate);
        if (_filterCriteria.postedDateFilter == '24h') return diff.inHours <= 24;
        if (_filterCriteria.postedDateFilter == 'week') return diff.inDays <= 7;
        if (_filterCriteria.postedDateFilter == 'month') return diff.inDays <= 30;
        return true;
      }).toList();
    }

    // 10. Deadline Filter
    if (_filterCriteria.deadlineFilter != null && _filterCriteria.deadlineFilter != 'all') {
      final now = DateTime.now();
      results = results.where((j) {
        final days = j.deadlineDate.difference(now).inDays;
        if (_filterCriteria.deadlineFilter == '3days') return days >= 0 && days <= 3;
        if (_filterCriteria.deadlineFilter == 'week') return days >= 0 && days <= 7;
        if (_filterCriteria.deadlineFilter == 'month') return days >= 0 && days <= 30;
        return true;
      }).toList();
    }

    // 11. Sorting
    switch (_filterCriteria.sortBy) {
      case 'match':
        results.sort((a, b) => (b.matchPercentage ?? 0).compareTo(a.matchPercentage ?? 0));
        break;
      case 'deadline':
        results.sort((a, b) => a.deadlineDate.compareTo(b.deadlineDate));
        break;
      case 'latest':
      default:
        results.sort((a, b) => b.postedDate.compareTo(a.postedDate));
        break;
    }

    return results;
  }

  // --- Step 10: Curated Government Recruitment Dataset ---
  static final List<GovtJobModel> _govtJobs = [
    GovtJobModel(
      id: 'govt_ssc_01',
      organization: 'Staff Selection Commission (SSC)',
      department: 'Department of Personnel and Training, Ministry of Personnel',
      postName: 'Combined Graduate Level (CGL) 2026 - Inspector / ASO / Tax Assistant',
      vacancies: 17727,
      qualification: "Bachelor's Degree in any discipline from a recognized University or Institute",
      ageLimit: '18 - 30 Years (Relaxation as per Govt of India rules)',
      applicationFee: 'General / OBC / EWS: ₹100; SC / ST / PwD / Women: Exempted (Nil)',
      selectionProcess: [
        'Tier 1: Computer Based Objective Examination (CBT)',
        'Tier 2: Paper-I (Quantitative, Reasoning, English, Computer Knowledge) + DEST Typing Test',
        'Document Verification & Medical Fitness Test',
      ],
      importantDates: {
        'Official Notification': '24 Jun 2026',
        'Application Start Date': '24 Jun 2026',
        'Last Date to Apply Online': '24 Jul 2026 (23:00 Hrs)',
        'Last Date for Online Fee Payment': '25 Jul 2026',
        'Tier 1 CBT Examination': 'Sep - Oct 2026',
      },
      jobDescription: 'Recruitment for Group B (Gazetted & Non-Gazetted) and Group C executive positions including Assistant Section Officer in Central Secretariat, Central Excise Inspector, Income Tax Inspector, Enforcement Officer, and Sub-Inspector in CBI across Ministries of the Government of India.',
      applicationStartDate: '24 Jun 2026',
      lastDate: '24 Jul 2026',
      lastDateObj: DateTime(2026, 7, 24),
      category: 'ssc',
      status: GovtJobStatus.open,
      payScale: 'Pay Level 4 (₹25,500) to Pay Level 8 (₹47,600 - ₹1,51,100)',
      notificationPdfUrl: 'https://ssc.gov.in/cgl_notification_2026.pdf',
      officialWebsite: 'https://ssc.gov.in',
      applyUrl: 'https://ssc.gov.in',
    ),
    GovtJobModel(
      id: 'govt_upsc_02',
      organization: 'Union Public Service Commission (UPSC)',
      department: 'Ministry of Personnel, Public Grievances and Pensions',
      postName: 'Civil Services Examination (CSE) 2026 - IAS / IPS / IFS / IRS',
      vacancies: 1056,
      qualification: 'Graduate Degree in any discipline from an Indian University incorporated by Act of Parliament',
      ageLimit: '21 - 32 Years as on 1st August 2026 (Age relaxation applicable for reserved categories)',
      applicationFee: 'General / Male: ₹100; Female / SC / ST / Persons with Benchmark Disability: Exempted',
      selectionProcess: [
        'Civil Services (Preliminary) Examination (Objective 2 Papers)',
        'Civil Services (Main) Written Examination (9 Descriptive Papers)',
        'Personality Test / Interview at Dholpur House, New Delhi',
      ],
      importantDates: {
        'Notification Release Date': '14 Feb 2026',
        'Online Registration Opens': '14 Feb 2026',
        'Last Date for Form Submission': '05 Mar 2026 (18:00 Hrs)',
        'Preliminary Examination Date': '24 May 2026',
        'Main Written Examination': 'Sep 2026 (5 Days)',
      },
      jobDescription: 'Direct recruitment examination to the premier civil services of the Republic of India including Indian Administrative Service (IAS), Indian Police Service (IPS), Indian Foreign Service (IFS), and Indian Revenue Service (IRS).',
      applicationStartDate: '14 Feb 2026',
      lastDate: '05 Mar 2026',
      lastDateObj: DateTime(2026, 3, 5),
      category: 'upsc',
      status: GovtJobStatus.open,
      payScale: 'Pay Level 10 (Junior Time Scale ₹56,100 to Apex Cabinet Secretary ₹2,50,000)',
      notificationPdfUrl: 'https://upsconline.nic.in/cse_2026_notification.pdf',
      officialWebsite: 'https://upsc.gov.in',
      applyUrl: 'https://upsconline.nic.in',
    ),
    GovtJobModel(
      id: 'govt_rrb_03',
      organization: 'Railway Recruitment Board (RRB)',
      department: 'Ministry of Railways, Government of India',
      postName: 'Assistant Loco Pilot (ALP) & Technicians CEN 01/2026',
      vacancies: 18799,
      qualification: 'Matriculation / 10th Pass + ITI / Act Apprenticeship in designated trade OR 3-year Engineering Diploma',
      ageLimit: '18 - 33 Years as on 01.07.2026',
      applicationFee: 'SC / ST / Ex-Servicemen / Female / EBC: ₹250 (Refundable upon CBT); All others: ₹500',
      selectionProcess: [
        'First Stage CBT (CBT-1: Screening)',
        'Second Stage CBT (CBT-2: Part A & Part B Trade Test)',
        'Computer Based Aptitude Test (CBAT - for ALP only)',
        'Document Verification and Medical Examination (A1 Medical Standard)',
      ],
      importantDates: {
        'CEN Notification Published': '20 Jan 2026',
        'Opening of Online Application': '20 Jan 2026',
        'Closing Date for Registration': '19 Feb 2026 (23:59 Hrs)',
        'CBT-1 Tentative Window': 'Jun - Aug 2026',
        'CBAT Aptitude Test': 'Nov 2026',
      },
      jobDescription: 'Piloting locomotives, ensuring strict adherence to railway signaling, operating Kavach collision prevention systems, and maintaining train safety standards across 16 Zonal Railways.',
      applicationStartDate: '20 Jan 2026',
      lastDate: '19 Feb 2026',
      lastDateObj: DateTime(2026, 2, 19),
      category: 'railway',
      status: GovtJobStatus.newAlert,
      payScale: 'Pay Level 2 of 7th CPC (Initial Basic Pay ₹19,900 + Running Allowance)',
      notificationPdfUrl: 'https://rrbcdg.gov.in/cen_01_2026_alp.pdf',
      officialWebsite: 'https://indianrailways.gov.in',
      applyUrl: 'https://www.rrbapply.gov.in',
    ),
    GovtJobModel(
      id: 'govt_sbi_04',
      organization: 'State Bank of India (SBI)',
      department: 'Central Recruitment & Promotion Department, Corporate Centre Mumbai',
      postName: 'Probationary Officers (PO) - Central Recruitment Drive',
      vacancies: 2000,
      qualification: 'Graduation in any discipline from a recognized University or equivalent qualification',
      ageLimit: '21 - 30 Years as on 01.04.2026',
      applicationFee: 'General / EWS / OBC: ₹750; SC / ST / PwBD: Nil (Exempted)',
      selectionProcess: [
        'Phase-I: Preliminary Examination (100 Marks Objective)',
        'Phase-II: Main Examination (Objective 200 Marks + Descriptive 50 Marks)',
        'Phase-III: Psychometric Evaluation + Group Exercise & Personal Interview (50 Marks)',
      ],
      importantDates: {
        'Recruitment Circular Issued': '07 Sep 2026',
        'Online Registration Opens': '07 Sep 2026',
        'Last Date to Apply Online': '27 Sep 2026',
        'Phase-I Online Preliminary Exam': 'Nov 2026',
        'Phase-II Main Exam': 'Dec 2026',
      },
      jobDescription: 'General banking operations, credit appraisal, treasury operations, customer onboarding, and branch management across SBI domestic branches nationwide.',
      applicationStartDate: '07 Sep 2026',
      lastDate: '27 Sep 2026',
      lastDateObj: DateTime(2026, 9, 27),
      category: 'banking',
      status: GovtJobStatus.closingSoon,
      payScale: 'Basic Pay ₹41,960 (with 4 advance increments in ₹36,000-63,840 scale, CTC ~₹18L LPA)',
      notificationPdfUrl: 'https://sbi.co.in/careers/crpd_po_2026.pdf',
      officialWebsite: 'https://sbi.co.in/web/careers',
      applyUrl: 'https://bank.sbi/careers',
    ),
    GovtJobModel(
      id: 'govt_army_05',
      organization: 'Indian Army',
      department: 'Directorate General of Recruiting, Integrated HQ of MoD (Army)',
      postName: 'Technical Graduate Course (TGC-140) Commissioned Officers',
      vacancies: 350,
      qualification: 'Passed engineering degree or in the final year of engineering degree stream',
      ageLimit: '20 - 27 Years at the time of commencement of course at IMA Dehradun',
      applicationFee: 'No Application Fee for all candidates (Free of charge)',
      selectionProcess: [
        'Shortlisting of applications based on cumulative engineering cut-off percentage',
        'Services Selection Board (SSB) Interview at Centre (5-day testing)',
        'Medical Examination at Military Hospital',
        'All-India Merit List & Joining Letter for Indian Military Academy (IMA)',
      ],
      importantDates: {
        'Notification Open on Portal': '10 Apr 2026',
        'Applications Window Starts': '10 Apr 2026',
        'Last Date to Apply': '09 May 2026 (15:00 Hrs)',
        'SSB Interviews': 'Jul - Sep 2026',
        'Course Commencement at IMA': 'Jan 2027',
      },
      jobDescription: 'Permanent Commission in the Indian Army as Lieutenant in Technical Corps: Corps of Engineers, Signals, and Electronics and Mechanical Engineers (EME).',
      applicationStartDate: '10 Apr 2026',
      lastDate: '09 May 2026',
      lastDateObj: DateTime(2026, 5, 9),
      category: 'defence',
      status: GovtJobStatus.open,
      payScale: 'Lieutenant Level 10 (₹56,100 - ₹1,77,500 + Military Service Pay ₹15,500 pm)',
      notificationPdfUrl: 'https://joinindianarmy.nic.in/tgc140_advt.pdf',
      officialWebsite: 'https://joinindianarmy.nic.in',
      applyUrl: 'https://joinindianarmy.nic.in',
    ),
    GovtJobModel(
      id: 'govt_police_06',
      organization: 'Delhi Police / CAPFs',
      department: 'Ministry of Home Affairs, Government of India',
      postName: 'Sub-Inspector (Executive) & Central Armed Police Forces',
      vacancies: 4187,
      qualification: "Educational qualification of Bachelor's degree from a recognized university + Valid LMV Driving License",
      ageLimit: '20 - 25 Years as on 01.08.2026',
      applicationFee: 'General / OBC: ₹100; Women / SC / ST / ESM: Nil',
      selectionProcess: [
        'Paper-I: Computer Based Examination (200 Marks)',
        'Physical Standard Test (PST) & Physical Endurance Test (PET)',
        'Paper-II: English Language & Comprehension (200 Marks)',
        'Detailed Medical Examination (DME) by CAPF Medical Boards',
      ],
      importantDates: {
        'Detailed Notice Uploaded': '04 Mar 2026',
        'Start Date for Online Form': '04 Mar 2026',
        'Closing Date for Receipt of Application': '28 Mar 2026 (23:00 Hrs)',
        'Paper-I CBT Scheduled': 'May - Jun 2026',
        'PET / PST Schedule': 'Aug 2026',
      },
      jobDescription: 'Law enforcement, crime investigation, border security (BSF, ITBP, SSB), and industrial protection (CISF, CRPF) under the Ministry of Home Affairs.',
      applicationStartDate: '04 Mar 2026',
      lastDate: '28 Mar 2026',
      lastDateObj: DateTime(2026, 3, 28),
      category: 'police',
      status: GovtJobStatus.newAlert,
      payScale: 'Pay Level 6 of 7th CPC (₹35,400 - ₹1,12,400)',
      notificationPdfUrl: 'https://ssc.gov.in/delhi_police_si_2026.pdf',
      officialWebsite: 'https://delhipolice.gov.in',
      applyUrl: 'https://ssc.gov.in',
    ),
    GovtJobModel(
      id: 'govt_kvs_07',
      organization: 'Kendriya Vidyalaya Sangathan (KVS)',
      department: 'Department of School Education and Literacy, Ministry of Education',
      postName: 'Post Graduate Teacher (PGT) & Trained Graduate Teacher (TGT)',
      vacancies: 13404,
      qualification: 'Master / Bachelor Degree in relevant subject with 50%+ aggregate + B.Ed + CTET Paper II qualified',
      ageLimit: 'PGT: Maximum 40 Years; TGT: Maximum 35 Years (Women candidate concession of 10 years)',
      applicationFee: 'PGT/TGT: ₹1,500; SC / ST / PwD: Nil (Exempted)',
      selectionProcess: [
        'Computer Based Test (CBT - 180 Questions / 180 Marks)',
        'Professional Competency Test (Demo Teaching 30 Marks + Interview 30 Marks)',
        'Merit weightage ratio: 70% CBT + 30% Interview',
      ],
      importantDates: {
        'Advertisement Published': '05 Dec 2025',
        'Online Registration Starts': '05 Dec 2025',
        'Last Date for Submission': '02 Jan 2026 (23:59 Hrs)',
        'Admit Card Release': 'Feb 2026',
        'CBT Examination Date': 'Feb - Mar 2026',
      },
      jobDescription: 'Teaching secondary and senior secondary students across 1,250+ Kendriya Vidyalayas in India and abroad, preparing syllabi and participating in co-curricular student mentoring.',
      applicationStartDate: '05 Dec 2025',
      lastDate: '02 Jan 2026',
      lastDateObj: DateTime(2026, 1, 2),
      category: 'teaching',
      status: GovtJobStatus.open,
      payScale: 'PGT: Level 8 (₹47,600 - ₹1,51,100); TGT: Level 7 (₹44,900 - ₹1,42,400)',
      notificationPdfUrl: 'https://kvsangathan.nic.in/kvs_direct_recruitment.pdf',
      officialWebsite: 'https://kvsangathan.nic.in',
      applyUrl: 'https://kvsangathan.nic.in',
    ),
    GovtJobModel(
      id: 'govt_isro_08',
      organization: 'ISRO - Indian Space Research Organisation',
      department: 'Department of Space, Government of India',
      postName: "Scientist / Engineer 'SC' (Electronics, Mechanical, Computer Science)",
      vacancies: 68,
      qualification: 'B.E / B.Tech or equivalent in First Class with aggregate minimum 65% marks or CGPA 6.84/10 + Valid GATE Score',
      ageLimit: '18 - 28 Years as on closing date (Relaxation for SC/ST/OBC/PwD)',
      applicationFee: 'Application Fee: ₹250 + Processing Fee: ₹750 (Processing fee refunded to candidates appearing for written test)',
      selectionProcess: [
        'Screening based on valid GATE score card / Written Test',
        'Technical Discipline Interview by ISRO Apex Selection Board (Minimum 60% qualifying)',
      ],
      importantDates: {
        'ICRB Advertisement Released': '25 Aug 2026',
        'Online Portal Opens': '25 Aug 2026',
        'Last Date for Online Submission': '15 Sep 2026 (17:00 Hrs)',
        'Written Test Date': 'Oct 2026',
        'Interview Dates': 'Nov 2026',
      },
      jobDescription: 'Design, development, integration, and mission testing of launch vehicle structures, avionics telemetry systems, payload sensors, and deep space ground station communication software.',
      applicationStartDate: '25 Aug 2026',
      lastDate: '15 Sep 2026',
      lastDateObj: DateTime(2026, 9, 15),
      category: 'psu',
      status: GovtJobStatus.closingSoon,
      payScale: 'Level 10 of Pay Matrix (₹56,100 - ₹1,77,500 Gross ~₹14L - ₹16L LPA)',
      notificationPdfUrl: 'https://isro.gov.in/careers/scientist_sc_notice.pdf',
      officialWebsite: 'https://www.isro.gov.in',
      applyUrl: 'https://www.isro.gov.in/careers',
    ),
    GovtJobModel(
      id: 'govt_appsc_09',
      organization: 'Andhra Pradesh PSC (APPSC)',
      department: 'General Administration Department, Government of Andhra Pradesh',
      postName: 'Group 1 Services - Deputy Collector, DSP, Commercial Tax Officer',
      vacancies: 89,
      qualification: 'A Bachelor Degree of any recognized University in India incorporated by or under a Central Act',
      ageLimit: '18 - 42 Years as on 01.07.2026 (For DSP post: 21 - 30 Years with physical standards)',
      applicationFee: 'Application Fee: ₹250 + Examination Fee: ₹120 (Reserved categories exempt from Exam Fee)',
      selectionProcess: [
        'Preliminary Screening Test (Offline OMR based objective exam)',
        'Mains Written Examination (Conventional Descriptive 5 Papers)',
        'Verification of Original Certificates & Oral Interview',
      ],
      importantDates: {
        'Notification Gazette Published': '01 Jan 2026',
        'Online Application Starts': '01 Jan 2026',
        'Closing Date of Application': '28 Jan 2026 (11:59 PM)',
        'Preliminary Screening Exam': 'Mar 2026',
        'Mains Examination Schedule': 'Aug 2026',
      },
      jobDescription: 'Executive administrative leadership across state districts, revenue administration, sub-divisional police command, commercial tax enforcement, and municipal administration in Andhra Pradesh.',
      applicationStartDate: '01 Jan 2026',
      lastDate: '28 Jan 2026',
      lastDateObj: DateTime(2026, 1, 28),
      category: 'state_govt',
      status: GovtJobStatus.open,
      payScale: 'RPS 2022 Pay Scale (₹61,960 - ₹1,51,370 + DA, HRA, Medical Allowances)',
      notificationPdfUrl: 'https://psc.ap.gov.in/group1_services_notif.pdf',
      officialWebsite: 'https://psc.ap.gov.in',
      applyUrl: 'https://psc.ap.gov.in',
    ),
    GovtJobModel(
      id: 'govt_upsc_cms_10',
      organization: 'Union Public Service Commission (UPSC)',
      department: 'Ministry of Health and Family Welfare, Govt of India',
      postName: 'Combined Medical Services (CMS) Examination 2025',
      vacancies: 827,
      qualification: 'Passed written and practical parts of final MBBS examination',
      ageLimit: 'Not attained the age of 32 Years as on 1st August 2025',
      applicationFee: 'General / OBC: ₹200; Female / SC / ST / PwBD: Nil',
      selectionProcess: [
        'Part-I: Computer Based Examination (2 Papers, 250 Marks each)',
        'Part-II: Personality Test / Interview (100 Marks)',
      ],
      importantDates: {
        'Notice Released': '10 Apr 2025',
        'Application Window': '10 Apr 2025 - 30 Apr 2025',
        'Status': 'Application Cycle Completed',
      },
      jobDescription: 'Medical Officers in Central Health Service, Assistant Divisional Medical Officer in Railways, General Duty Medical Officer in New Delhi Municipal Council.',
      applicationStartDate: '10 Apr 2025',
      lastDate: '30 Apr 2025',
      lastDateObj: DateTime(2025, 4, 30),
      category: 'upsc',
      status: GovtJobStatus.expired,
      payScale: 'Level 10 (₹56,100 + NPA as per 7th CPC)',
      notificationPdfUrl: 'https://upsconline.nic.in/cms_2025.pdf',
      officialWebsite: 'https://upsc.gov.in',
      applyUrl: 'https://upsconline.nic.in',
    ),
    GovtJobModel(
      id: 'govt_ssc_chsl_11',
      organization: 'Staff Selection Commission (SSC)',
      department: 'Department of Personnel & Training',
      postName: 'Combined Higher Secondary (10+2) Level Examination 2025',
      vacancies: 3712,
      qualification: '12th Standard or equivalent exam from recognized Board',
      ageLimit: '18 - 27 Years',
      applicationFee: '₹100 (Exempted for Women/SC/ST)',
      selectionProcess: [
        'Tier-I: Computer Based Examination',
        'Tier-II: Objective + Skill Test / Typing Test',
      ],
      importantDates: {
        'Notice Release': '08 Apr 2025',
        'Deadline': '07 May 2025',
        'Status': 'Completed',
      },
      jobDescription: 'Lower Division Clerk (LDC), Junior Secretariat Assistant (JSA), and Data Entry Operator (DEO) in Central Ministries.',
      applicationStartDate: '08 Apr 2025',
      lastDate: '07 May 2025',
      lastDateObj: DateTime(2025, 5, 7),
      category: 'ssc',
      status: GovtJobStatus.expired,
      payScale: 'Level 2 & 4 (₹19,900 - ₹81,100)',
      notificationPdfUrl: 'https://ssc.gov.in/chsl_2025.pdf',
      officialWebsite: 'https://ssc.gov.in',
      applyUrl: 'https://ssc.gov.in',
    ),
    GovtJobModel(
      id: 'govt_drdo_12',
      organization: 'DRDO - Recruitment & Assessment Centre (RAC)',
      department: 'Department of Defence R&D, Ministry of Defence',
      postName: "Scientist 'B' in Defence Research & Development Organisation",
      vacancies: 204,
      qualification: "First Class Master's Degree in Science or First Class Bachelor's in Engg + Valid GATE Score",
      ageLimit: 'Up to 35 Years for Unreserved category',
      applicationFee: 'General / OBC / EWS: ₹100; SC / ST / Women: Nil',
      selectionProcess: [
        'Screening through valid GATE Score',
        'Personal Interview at RAC, Delhi (80% GATE + 20% Interview)',
      ],
      importantDates: {
        'Advertisement Uploaded': '28 Aug 2026',
        'Application Opens': '28 Aug 2026',
        'Closing Date': '29 Sep 2026',
        'Interviews': 'Nov 2026',
      },
      jobDescription: 'Research, development, simulation, and live range trials for defense systems, radar sensors, aerospace missile systems, and secure communications.',
      applicationStartDate: '28 Aug 2026',
      lastDate: '29 Sep 2026',
      lastDateObj: DateTime(2026, 9, 29),
      category: 'psu',
      status: GovtJobStatus.newAlert,
      payScale: 'Level 10 of Pay Matrix (₹56,100 - ₹1,77,500 Gross ~₹13L - ₹15L LPA)',
      notificationPdfUrl: 'https://rac.gov.in/scientist_b_advt.pdf',
      officialWebsite: 'https://rac.gov.in',
      applyUrl: 'https://rac.gov.in',
    ),
  ];

  List<GovtJobModel> get allGovtJobs => _govtJobs;

  List<GovtJobModel> getGovtJobsFiltered({
    String category = 'all',
    String status = 'all',
    String query = '',
  }) {
    var list = List<GovtJobModel>.from(_govtJobs);
    if (category != 'all') {
      list = list.where((j) => j.category.toLowerCase() == category.toLowerCase()).toList();
    }
    if (status != 'all') {
      list = list.where((j) => j.status.name.toLowerCase() == status.toLowerCase()).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((j) =>
          j.organization.toLowerCase().contains(q) ||
          j.postName.toLowerCase().contains(q) ||
          j.qualification.toLowerCase().contains(q) ||
          j.category.toLowerCase().contains(q)).toList();
    }
    return list;
  }

}
