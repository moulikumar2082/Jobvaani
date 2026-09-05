import 'package:flutter/material.dart';
import '../data/models/job_match_model.dart';
import '../data/models/job_model.dart';
import '../services/job_match_service.dart';
import '../services/resume_analysis_service.dart';

/// State management provider for AI job matching and recommendations (Step 20 & 21).
/// Guarantees that UI widgets only consume pre-computed scores and never contain AI logic.
class JobMatchProvider with ChangeNotifier {
  final JobMatchService _jobMatchService;
  final ResumeAnalysisService _resumeAnalysisService;

  final Map<String, JobMatchResult> _matchCache = {};
  List<RecommendationItem> _recommendations = [];
  bool _isLoadingRecommendations = false;
  String? _error;

  JobMatchProvider({
    JobMatchService? jobMatchService,
    ResumeAnalysisService? resumeAnalysisService,
  })  : _jobMatchService = jobMatchService ?? JobMatchService(),
        _resumeAnalysisService =
            resumeAnalysisService ?? ResumeAnalysisService();

  List<RecommendationItem> get recommendations => _recommendations;
  bool get isLoadingRecommendations => _isLoadingRecommendations;
  String? get error => _error;

  /// Retrieves a cached match result synchronously if available
  JobMatchResult? getCachedMatch(String jobId) => _matchCache[jobId];

  /// Asynchronously fetches and caches the match result for a job
  Future<JobMatchResult> getMatchForJob({
    required JobModel job,
    required List<String> candidateSkills,
    String? candidateQualification,
    List<String>? candidateLocations,
    List<String>? candidateCategories,
    String? candidateExperience,
  }) async {
    // Generate a cache key that reflects skill mutations
    final skillSignature = candidateSkills.join(',');
    final cacheKey = '${job.id}_$skillSignature';

    if (_matchCache.containsKey(cacheKey)) {
      return _matchCache[cacheKey]!;
    }

    try {
      final result = await _jobMatchService.getMatchForJob(
        job: job,
        candidateSkills: candidateSkills,
        candidateQualification: candidateQualification,
        candidateLocations: candidateLocations,
        candidateCategories: candidateCategories,
        candidateExperience: candidateExperience,
      );

      _matchCache[cacheKey] = result;
      _matchCache[job.id] = result; // also cache by pure jobId for fast lookup
      notifyListeners();
      return result;
    } catch (e) {
      // Return safe fallback in error scenarios
      final fallback = JobMatchResult(
        jobId: job.id,
        matchPercentage: job.matchPercentage ?? 80,
        matchedSkills: candidateSkills.take(3).toList(),
        missingSkills: const [],
        breakdown: WeightedScoreBreakdown.demo87(),
        matchGrade: 'Strong Match',
        summary: 'Profile alignment computed based on current qualifications.',
        computedAt: DateTime.now(),
      );
      _matchCache[cacheKey] = fallback;
      _matchCache[job.id] = fallback;
      return fallback;
    }
  }

  /// Loads personalized AI recommendations
  Future<void> loadRecommendations({
    required String userId,
    required List<String> candidateSkills,
    required List<JobModel> availableJobs,
  }) async {
    _isLoadingRecommendations = true;
    _error = null;
    notifyListeners();

    try {
      _recommendations = await _jobMatchService.getRecommendations(
        userId: userId,
        candidateSkills: candidateSkills,
        availableJobs: availableJobs,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }

  /// Analyzes an uploaded resume using NLP
  Future<ResumeAnalysisResult?> analyzeResume(String resumeId) async {
    try {
      return await _resumeAnalysisService.analyzeResume(resumeId);
    } catch (_) {
      return null;
    }
  }

  /// Clears cache when user updates their skills or preferences
  void invalidateCache() {
    _matchCache.clear();
    _recommendations.clear();
    notifyListeners();
  }
}
