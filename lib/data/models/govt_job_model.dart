import 'job_model.dart';

enum GovtJobStatus {
  newAlert,
  open,
  closingSoon,
  expired,
}

class GovtJobModel {
  final String id;
  final String organization;
  final String department;
  final String postName;
  final int vacancies;
  final String qualification;
  final String ageLimit;
  final String applicationFee;
  final List<String> selectionProcess;
  final Map<String, String> importantDates;
  final String jobDescription;
  final String applicationStartDate;
  final String lastDate;
  final DateTime lastDateObj;
  final String category; // 'ssc', 'upsc', 'railway', 'banking', 'defence', 'police', 'teaching', 'psu', 'state_govt', 'other'
  final GovtJobStatus status;
  final String? payScale;
  final String notificationPdfUrl;
  final String officialWebsite;
  final String applyUrl;

  const GovtJobModel({
    required this.id,
    required this.organization,
    required this.department,
    required this.postName,
    required this.vacancies,
    required this.qualification,
    required this.ageLimit,
    required this.applicationFee,
    required this.selectionProcess,
    required this.importantDates,
    required this.jobDescription,
    required this.applicationStartDate,
    required this.lastDate,
    required this.lastDateObj,
    required this.category,
    required this.status,
    this.payScale,
    required this.notificationPdfUrl,
    required this.officialWebsite,
    required this.applyUrl,
  });

  JobModel toJobModel() => JobModel(
        id: id,
        title: postName,
        company: organization,
        organization: department,
        location: 'Pan-India',
        salary: payScale ?? '7th CPC Pay Scale',
        minSalaryLpa: 8.0,
        jobType: 'Government',
        category: 'govt',
        subCategory: category,
        deadline: lastDate,
        deadlineDate: lastDateObj,
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        matchPercentage: 92,
        experienceLevel: 'Fresher / All Eligible',
        qualification: qualification,
        skills: const ['General Studies', 'Aptitude', 'Reasoning', 'Official Conduct'],
        responsibilities: selectionProcess,
        vacancies: vacancies,
        isClosingSoon: status == GovtJobStatus.closingSoon,
        isGovernmentAlert: true,
        isRecommended: true,
        description: jobDescription,
        eligibility: '$qualification. Age Limit: $ageLimit. Fee: $applicationFee',
        applyUrl: applyUrl,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'organization': organization,
        'department': department,
        'postName': postName,
        'vacancies': vacancies,
        'qualification': qualification,
        'ageLimit': ageLimit,
        'applicationFee': applicationFee,
        'selectionProcess': selectionProcess,
        'importantDates': importantDates,
        'jobDescription': jobDescription,
        'applicationStartDate': applicationStartDate,
        'lastDate': lastDate,
        'lastDateObj': lastDateObj.toIso8601String(),
        'category': category,
        'status': status.name,
        'payScale': payScale,
        'notificationPdfUrl': notificationPdfUrl,
        'officialWebsite': officialWebsite,
        'applyUrl': applyUrl,
      };

  factory GovtJobModel.fromJson(Map<String, dynamic> json) => GovtJobModel(
        id: json['id'] as String,
        organization: json['organization'] as String,
        department: json['department'] as String? ?? json['organization'] as String,
        postName: json['postName'] as String,
        vacancies: json['vacancies'] as int,
        qualification: json['qualification'] as String,
        ageLimit: json['ageLimit'] as String? ?? '18 - 30 Years',
        applicationFee: json['applicationFee'] as String? ?? 'General/OBC: ₹100, SC/ST/Women: Exempted',
        selectionProcess: (json['selectionProcess'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const ['Computer Based Test (CBT)', 'Document Verification'],
        importantDates: (json['importantDates'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v.toString())) ?? {},
        jobDescription: json['jobDescription'] as String? ?? 'Official government recruitment notification.',
        applicationStartDate: json['applicationStartDate'] as String,
        lastDate: json['lastDate'] as String,
        lastDateObj: DateTime.tryParse(json['lastDateObj'] as String? ?? '') ?? DateTime.now(),
        category: json['category'] as String,
        status: GovtJobStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => GovtJobStatus.open,
        ),
        payScale: json['payScale'] as String?,
        notificationPdfUrl: json['notificationPdfUrl'] as String? ?? 'https://jobvaani.in/notification.pdf',
        officialWebsite: json['officialWebsite'] as String? ?? 'https://india.gov.in',
        applyUrl: json['applyUrl'] as String? ?? 'https://india.gov.in',
      );
}
