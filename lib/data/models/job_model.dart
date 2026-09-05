class JobModel {
  final String id;
  final String title;
  final String company;
  final String organization;
  final String location;
  final String? salary;
  final double minSalaryLpa;
  final String jobType;
  final String category; // 'govt', 'private', 'internship'
  final String? subCategory; // 'software_dev', 'cybersecurity', 'data_science', 'ai_ml', 'cloud', 'devops', 'testing', 'sales', 'marketing', 'finance', 'hr', 'other'
  final String deadline;
  final DateTime deadlineDate;
  final DateTime postedDate;
  final int? matchPercentage;
  final String experienceLevel; // 'Fresher', '1-3 Years', '3-5 Years', '5+ Years'
  final String qualification; // '10th/12th Pass', 'Diploma', 'Graduate', 'Post Graduate'
  final List<String> skills;
  final List<String> responsibilities;
  final int? vacancies;
  final bool isClosingSoon;
  final bool isGovernmentAlert;
  final bool isRecommended;
  final String? description;
  final String? eligibility;
  final String? applyUrl;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.organization,
    required this.location,
    this.salary,
    this.minSalaryLpa = 0.0,
    required this.jobType,
    required this.category,
    this.subCategory,
    required this.deadline,
    required this.deadlineDate,
    required this.postedDate,
    this.matchPercentage,
    required this.experienceLevel,
    required this.qualification,
    required this.skills,
    this.responsibilities = const [],
    this.vacancies,
    this.isClosingSoon = false,
    this.isGovernmentAlert = false,
    this.isRecommended = false,
    this.description,
    this.eligibility,
    this.applyUrl,
  });

  bool get isGovt => category == 'govt' || isGovernmentAlert;
  bool get isInternship => category == 'internship' || jobType.toLowerCase().contains('intern');
  bool get hasSalary => salary != null && salary!.trim().isNotEmpty;
  bool get hasMatch => matchPercentage != null && matchPercentage! > 0;

  List<String> get displayResponsibilities {
    if (responsibilities.isNotEmpty) return responsibilities;
    if (isGovt) {
      return const [
        'Execute departmental responsibilities under central / state government frameworks.',
        'Ensure regulatory compliance, transparent documentation, and statutory audits.',
        'Coordinate with administrative officers and citizens for seamless public service delivery.',
        'Participate in project assessments, technical audits, and field evaluations.',
      ];
    }
    return const [
      'Design, build, and maintain scalable solutions aligning with core user needs.',
      'Collaborate across engineering, product, and design teams on key deliverables.',
      'Maintain code quality, conduct peer code reviews, and automate test suites.',
      'Monitor application metrics, diagnose production issues, and optimize latency.',
    ];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'company': company,
        'organization': organization,
        'location': location,
        'salary': salary,
        'minSalaryLpa': minSalaryLpa,
        'jobType': jobType,
        'category': category,
        'subCategory': subCategory,
        'deadline': deadline,
        'deadlineDate': deadlineDate.toIso8601String(),
        'postedDate': postedDate.toIso8601String(),
        'matchPercentage': matchPercentage,
        'experienceLevel': experienceLevel,
        'qualification': qualification,
        'skills': skills,
        'responsibilities': responsibilities,
        'vacancies': vacancies,
        'isClosingSoon': isClosingSoon,
        'isGovernmentAlert': isGovernmentAlert,
        'isRecommended': isRecommended,
        'description': description,
        'eligibility': eligibility,
        'applyUrl': applyUrl,
      };

  factory JobModel.fromJson(Map<String, dynamic> json) => JobModel(
        id: json['id'] as String,
        title: json['title'] as String,
        company: json['company'] as String,
        organization: (json['organization'] as String?) ?? (json['company'] as String),
        location: json['location'] as String,
        salary: json['salary'] as String?,
        minSalaryLpa: (json['minSalaryLpa'] as num?)?.toDouble() ?? 0.0,
        jobType: json['jobType'] as String,
        category: json['category'] as String,
        subCategory: json['subCategory'] as String?,
        deadline: json['deadline'] as String,
        deadlineDate: DateTime.tryParse(json['deadlineDate'] as String? ?? '') ?? DateTime.now().add(const Duration(days: 14)),
        postedDate: DateTime.tryParse(json['postedDate'] as String? ?? '') ?? DateTime.now(),
        matchPercentage: json['matchPercentage'] as int?,
        experienceLevel: json['experienceLevel'] as String? ?? 'Fresher',
        qualification: json['qualification'] as String? ?? 'Graduate',
        skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        responsibilities: (json['responsibilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        vacancies: json['vacancies'] as int?,
        isClosingSoon: json['isClosingSoon'] as bool? ?? false,
        isGovernmentAlert: json['isGovernmentAlert'] as bool? ?? false,
        isRecommended: json['isRecommended'] as bool? ?? false,
        description: json['description'] as String?,
        eligibility: json['eligibility'] as String?,
        applyUrl: json['applyUrl'] as String?,
      );
}
