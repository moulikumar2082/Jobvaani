import 'dart:async';
import '../../core/network/api_config.dart';
import '../models/job_match_model.dart';
import '../models/job_model.dart';

/// Abstract contract for AI recommendation and NLP backend connectivity (Step 20).
/// Ready for plug-and-play connection to a future Python/FastAPI microservice.
abstract class IRecommendationRepository {
  /// Fetches the match result for a specific job against candidate attributes
  Future<JobMatchResult> getJobMatch({
    required String jobId,
    required List<String> candidateSkills,
    List<String>? jobSkills,
    String? qualification,
    String? location,
    String? category,
    String? experience,
    String? token,
  });

  /// Fetches personalized job recommendations for a user profile
  Future<List<RecommendationItem>> getRecommendations({
    required String userId,
    required List<String> candidateSkills,
    List<JobModel>? availableJobs,
    int limit = 10,
    String? token,
  });

  /// Sends resume metadata/text to FastAPI NLP parser for skill extraction
  Future<ResumeAnalysisResult> analyzeResume({
    required String resumeId,
    String? token,
  });
}

/// Concrete implementation of [IRecommendationRepository].
/// Follows Clean Architecture: UI never communicates directly with this layer.
class RecommendationRepository implements IRecommendationRepository {
  @override
  Future<JobMatchResult> getJobMatch({
    required String jobId,
    required List<String> candidateSkills,
    List<String>? jobSkills,
    String? qualification,
    String? location,
    String? category,
    String? experience,
    String? token,
  }) async {
    // Architecture:
    // When live, initiates HTTP POST to ${ApiConfig.baseUrl}${ApiConfig.aiJobMatchEndpoint}
    // headers: ApiConfig.defaultHeaders(token: token)
    // body: jsonEncode({
    //   'job_id': jobId,
    //   'candidate_skills': candidateSkills,
    //   'qualification': qualification,
    //   'location': location,
    //   'category': category,
    //   'experience': experience,
    // })

    // Simulate microservice roundtrip latency (300ms)
    await Future.delayed(const Duration(milliseconds: 300));

    // Special case handling for the user's prompt specification:
    // "87% Match"
    // Matched skills: ✓ Python, ✓ SQL, ✓ Linux, ✓ Cybersecurity
    // Missing: Networking
    if (jobId == 'job_cyber_sec_ops_05') {
      return JobMatchResult.demo87(jobId: jobId);
    }

    // Dynamic 5-Factor Weighted Calculation engine (Step 21)
    final effectiveJobSkills = jobSkills ?? const ['Python', 'SQL', 'Git'];
    final normalizedCandidateSkills = candidateSkills
        .map((s) => s.trim().toLowerCase())
        .toSet();

    final matched = <String>[];
    final missing = <String>[];

    for (final skill in effectiveJobSkills) {
      final norm = skill.trim().toLowerCase();
      final isMatch = normalizedCandidateSkills.any(
        (c) => c == norm || c.contains(norm) || norm.contains(c),
      );
      if (isMatch) {
        matched.add(skill);
      } else {
        missing.add(skill);
      }
    }

    // 1. Skill Score (40% weight): fraction of job skills possessed
    final skillScore = effectiveJobSkills.isEmpty
        ? 0.80
        : (matched.length / effectiveJobSkills.length).clamp(0.0, 1.0);

    // 2. Qualification Score (20% weight)
    final qualScore = (qualification != null && qualification.isNotEmpty) ? 1.0 : 0.85;

    // 3. Location Score (15% weight)
    final locScore = (location != null && location.isNotEmpty) ? 0.85 : 0.70;

    // 4. Category Score (15% weight)
    final catScore = (category != null && category.isNotEmpty) ? 0.90 : 0.75;

    // 5. Experience Score (10% weight)
    final expScore = (experience != null && experience.isNotEmpty) ? 0.85 : 0.70;

    final breakdown = WeightedScoreBreakdown(
      skillScore: skillScore,
      qualificationScore: qualScore,
      locationScore: locScore,
      categoryScore: catScore,
      experienceScore: expScore,
    );

    final finalPercentage = breakdown.calculatedPercentage;

    String matchGrade;
    if (finalPercentage >= 90) {
      matchGrade = 'Exceptional Match';
    } else if (finalPercentage >= 75) {
      matchGrade = 'Strong Match';
    } else if (finalPercentage >= 60) {
      matchGrade = 'Moderate Match';
    } else {
      matchGrade = 'Potential Match';
    }

    final summary = matched.isNotEmpty
        ? 'Your background in ${matched.take(3).join(', ')} aligns well with this position.'
        : 'This opening provides a foundation to grow your core capabilities.';

    final upskillAdvice = missing.isNotEmpty
        ? 'Acquiring ${missing.take(2).join(' & ')} will enhance your selection profile.'
        : 'Your skills closely match the technical requirements.';

    return JobMatchResult(
      jobId: jobId,
      matchPercentage: finalPercentage,
      matchedSkills: matched,
      missingSkills: missing,
      breakdown: breakdown,
      matchGrade: matchGrade,
      summary: summary,
      upskillAdvice: upskillAdvice,
      semanticConfidence: 0.92,
      computedAt: DateTime.now(),
    );
  }

  @override
  Future<List<RecommendationItem>> getRecommendations({
    required String userId,
    required List<String> candidateSkills,
    List<JobModel>? availableJobs,
    int limit = 10,
    String? token,
  }) async {
    // Architecture: GET to ApiConfig.aiRecommendationsEndpoint with Bearer token
    await Future.delayed(const Duration(milliseconds: 350));

    final jobs = availableJobs ?? [];
    final items = <RecommendationItem>[];

    for (final job in jobs.take(limit)) {
      final match = await getJobMatch(
        jobId: job.id,
        candidateSkills: candidateSkills,
        jobSkills: job.skills,
        category: job.category,
        location: job.location,
        qualification: job.qualification,
        experience: job.experienceLevel,
      );

      items.add(
        RecommendationItem(
          job: job,
          matchResult: match,
          recommendationReason: match.isStrongMatch
              ? 'High skill overlap in ${match.matchedSkills.take(2).join(', ')}'
              : 'Matches your preferred category & qualification',
          generatedAt: DateTime.now(),
        ),
      );
    }

    // Sort descending by match score
    items.sort((a, b) =>
        b.matchResult.matchPercentage.compareTo(a.matchResult.matchPercentage));
    return items;
  }

  @override
  Future<ResumeAnalysisResult> analyzeResume({
    required String resumeId,
    String? token,
  }) async {
    // Architecture: POST to ApiConfig.aiResumeAnalysisEndpoint with resume ID
    await Future.delayed(const Duration(milliseconds: 450));
    return ResumeAnalysisResult(
      resumeId: resumeId,
      extractedSkills: const [
        'Flutter',
        'Dart',
        'Python',
        'Cybersecurity',
        'Linux',
        'SQL',
        'AWS',
      ],
      primaryDomain: 'Software Engineering & Cybersecurity',
      readinessScore: 0.88,
      suggestedKeywords: const [
        'TCP/IP',
        'SIEM',
        'REST APIs',
        'Docker',
        'CI/CD',
      ],
    );
  }
}
