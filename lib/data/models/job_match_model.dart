import 'dart:math';
import 'job_model.dart';

/// 5-Factor weighted scoring model breakdown (Step 21):
/// - Skill Match: 40% (0.40)
/// - Qualification: 20% (0.20)
/// - Location: 15% (0.15)
/// - Category: 15% (0.15)
/// - Experience: 10% (0.10)
class WeightedScoreBreakdown {
  final double skillScore; // 0.0 to 1.0
  final double qualificationScore; // 0.0 to 1.0
  final double locationScore; // 0.0 to 1.0
  final double categoryScore; // 0.0 to 1.0
  final double experienceScore; // 0.0 to 1.0

  static const double skillWeight = 0.40;
  static const double qualificationWeight = 0.20;
  static const double locationWeight = 0.15;
  static const double categoryWeight = 0.15;
  static const double experienceWeight = 0.10;

  const WeightedScoreBreakdown({
    required this.skillScore,
    required this.qualificationScore,
    required this.locationScore,
    required this.categoryScore,
    required this.experienceScore,
  });

  /// Calculates the weighted composite score (0 to 100)
  int get calculatedPercentage {
    final composite = (skillScore * skillWeight) +
        (qualificationScore * qualificationWeight) +
        (locationScore * locationWeight) +
        (categoryScore * categoryWeight) +
        (experienceScore * experienceWeight);
    return (composite * 100).round().clamp(0, 100);
  }

  double get skillContribution => skillScore * skillWeight * 100;
  double get qualificationContribution => qualificationScore * qualificationWeight * 100;
  double get locationContribution => locationScore * locationWeight * 100;
  double get categoryContribution => categoryScore * categoryWeight * 100;
  double get experienceContribution => experienceScore * experienceWeight * 100;

  factory WeightedScoreBreakdown.demo87() {
    return const WeightedScoreBreakdown(
      skillScore: 0.80, // 4 of 5 skills = 32.0%
      qualificationScore: 1.0, // Meets graduate degree = 20.0%
      locationScore: 0.80, // Preferred region match = 12.0%
      categoryScore: 1.0, // Primary domain = 15.0%
      experienceScore: 0.80, // 1-3 years fit = 8.0%
      // Total: 32 + 20 + 12 + 15 + 8 = 87%
    );
  }

  Map<String, dynamic> toJson() => {
        'skillScore': skillScore,
        'qualificationScore': qualificationScore,
        'locationScore': locationScore,
        'categoryScore': categoryScore,
        'experienceScore': experienceScore,
        'calculatedPercentage': calculatedPercentage,
      };

  factory WeightedScoreBreakdown.fromJson(Map<String, dynamic> json) =>
      WeightedScoreBreakdown(
        skillScore: (json['skillScore'] as num?)?.toDouble() ?? 0.0,
        qualificationScore: (json['qualificationScore'] as num?)?.toDouble() ?? 0.0,
        locationScore: (json['locationScore'] as num?)?.toDouble() ?? 0.0,
        categoryScore: (json['categoryScore'] as num?)?.toDouble() ?? 0.0,
        experienceScore: (json['experienceScore'] as num?)?.toDouble() ?? 0.0,
      );
}

/// Structured AI Match Result model consumed by UI components (Step 20 & 21).
/// All computation resides in the service/backend layer.
class JobMatchResult {
  final String jobId;
  final int matchPercentage;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final WeightedScoreBreakdown breakdown;
  final String matchGrade; // 'Exceptional Match', 'Strong Match', 'Moderate Match', 'Potential Match'
  final String summary;
  final String? upskillAdvice;
  final double semanticConfidence;
  final DateTime computedAt;

  const JobMatchResult({
    required this.jobId,
    required this.matchPercentage,
    required this.matchedSkills,
    required this.missingSkills,
    required this.breakdown,
    required this.matchGrade,
    required this.summary,
    this.upskillAdvice,
    this.semanticConfidence = 0.94,
    required this.computedAt,
  });

  bool get isStrongMatch => matchPercentage >= 75;
  bool get hasMissingSkills => missingSkills.isNotEmpty;

  /// Default demo result adhering to prompt specifications:
  /// “87% Match”
  /// Matched skills: ✓ Python, ✓ SQL, ✓ Linux, ✓ Cybersecurity
  /// Missing: Networking
  factory JobMatchResult.demo87({String jobId = 'job_cyber_sec_ops_05'}) {
    return JobMatchResult(
      jobId: jobId,
      matchPercentage: 87,
      matchedSkills: const ['Python', 'SQL', 'Linux', 'Cybersecurity'],
      missingSkills: const ['Networking'],
      breakdown: WeightedScoreBreakdown.demo87(),
      matchGrade: 'Strong Match',
      summary:
          'Your profile demonstrates strong technical alignment across 4 core competencies. Adding Networking to your skillset will elevate your match to 95%+.',
      upskillAdvice:
          'Consider completing an introductory Computer Networking & TCP/IP course to meet all technical requirements for this role.',
      semanticConfidence: 0.95,
      computedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'jobId': jobId,
        'matchPercentage': matchPercentage,
        'matchedSkills': matchedSkills,
        'missingSkills': missingSkills,
        'breakdown': breakdown.toJson(),
        'matchGrade': matchGrade,
        'summary': summary,
        'upskillAdvice': upskillAdvice,
        'semanticConfidence': semanticConfidence,
        'computedAt': computedAt.toIso8601String(),
      };

  factory JobMatchResult.fromJson(Map<String, dynamic> json) => JobMatchResult(
        jobId: json['jobId'] as String? ?? '',
        matchPercentage: json['matchPercentage'] as int? ?? 0,
        matchedSkills: (json['matchedSkills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        missingSkills: (json['missingSkills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        breakdown: json['breakdown'] != null
            ? WeightedScoreBreakdown.fromJson(
                json['breakdown'] as Map<String, dynamic>)
            : WeightedScoreBreakdown.demo87(),
        matchGrade: json['matchGrade'] as String? ?? 'Strong Match',
        summary: json['summary'] as String? ?? '',
        upskillAdvice: json['upskillAdvice'] as String?,
        semanticConfidence:
            (json['semanticConfidence'] as num?)?.toDouble() ?? 0.90,
        computedAt: DateTime.tryParse(json['computedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

/// Model for AI-curated personalized recommendation list items
class RecommendationItem {
  final JobModel job;
  final JobMatchResult matchResult;
  final String recommendationReason;
  final DateTime generatedAt;

  const RecommendationItem({
    required this.job,
    required this.matchResult,
    required this.recommendationReason,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
        'job': job.toJson(),
        'matchResult': matchResult.toJson(),
        'recommendationReason': recommendationReason,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory RecommendationItem.fromJson(Map<String, dynamic> json) =>
      RecommendationItem(
        job: JobModel.fromJson(json['job'] as Map<String, dynamic>),
        matchResult: JobMatchResult.fromJson(
            json['matchResult'] as Map<String, dynamic>),
        recommendationReason: json['recommendationReason'] as String? ??
            'Recommended based on profile similarity',
        generatedAt: DateTime.tryParse(json['generatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

/// Model for Resume NLP parser output from FastAPI service
class ResumeAnalysisResult {
  final String resumeId;
  final List<String> extractedSkills;
  final String primaryDomain;
  final double readinessScore; // 0.0 to 1.0
  final List<String> suggestedKeywords;

  const ResumeAnalysisResult({
    required this.resumeId,
    required this.extractedSkills,
    required this.primaryDomain,
    required this.readinessScore,
    required this.suggestedKeywords,
  });

  Map<String, dynamic> toJson() => {
        'resumeId': resumeId,
        'extractedSkills': extractedSkills,
        'primaryDomain': primaryDomain,
        'readinessScore': readinessScore,
        'suggestedKeywords': suggestedKeywords,
      };

  factory ResumeAnalysisResult.fromJson(Map<String, dynamic> json) =>
      ResumeAnalysisResult(
        resumeId: json['resumeId'] as String? ?? '',
        extractedSkills: (json['extractedSkills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        primaryDomain: json['primaryDomain'] as String? ?? 'General Tech',
        readinessScore:
            (json['readinessScore'] as num?)?.toDouble() ?? 0.85,
        suggestedKeywords: (json['suggestedKeywords'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
}
