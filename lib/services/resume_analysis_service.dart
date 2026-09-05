import 'dart:async';
import '../data/models/job_match_model.dart';
import '../data/repositories/recommendation_repository.dart';

/// Service dedicated to NLP resume analysis and skill entity extraction (Step 20).
/// Ready to connect to FastAPI spaCy/SentenceTransformers microservices.
class ResumeAnalysisService {
  final IRecommendationRepository _repository;

  ResumeAnalysisService({IRecommendationRepository? repository})
      : _repository = repository ?? RecommendationRepository();

  /// Analyzes an uploaded PDF resume and returns extracted skill entities
  Future<ResumeAnalysisResult> analyzeResume(String resumeId, {String? token}) async {
    return await _repository.analyzeResume(resumeId: resumeId, token: token);
  }

  /// Helper to extract skill tokens from raw user input or notes
  Future<List<String>> extractSkillsFromText(String text) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final knownKeywords = [
      'python',
      'java',
      'c++',
      'sql',
      'cybersecurity',
      'linux',
      'aws',
      'react',
      'flutter',
      'networking',
      'docker',
      'kubernetes',
      'dart',
      'git',
    ];

    final lower = text.toLowerCase();
    return knownKeywords.where((kw) => lower.contains(kw)).map((s) {
      if (s == 'c++') return 'C++';
      if (s == 'sql') return 'SQL';
      if (s == 'aws') return 'AWS';
      return s[0].toUpperCase() + s.substring(1);
    }).toList();
  }
}
