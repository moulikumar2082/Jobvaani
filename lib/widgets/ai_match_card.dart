import 'package:flutter/material.dart';
import '../data/models/job_match_model.dart';
import '../l10n/app_localizations.dart';

/// Reusable presentation widget for AI Job Match breakdown and weighted scoring (Steps 20 & 21).
/// Adheres strictly to Clean Architecture: receives precomputed [JobMatchResult] and contains ZERO AI logic.
class AiMatchCard extends StatefulWidget {
  final JobMatchResult matchResult;
  final VoidCallback? onUpskillTap;

  const AiMatchCard({
    Key? key,
    required this.matchResult,
    this.onUpskillTap,
  }) : super(key: key);

  @override
  State<AiMatchCard> createState() => _AiMatchCardState();
}

class _AiMatchCardState extends State<AiMatchCard> {
  bool _isBreakdownExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = widget.matchResult;
    final breakdown = result.breakdown;

    final primaryColor = result.matchPercentage >= 80
        ? const Color(0xFF059669)
        : (result.matchPercentage >= 60
            ? const Color(0xFFD97706)
            : const Color(0xFF3B82F6));

    final containerBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(isDark ? 0.15 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Banner with Match Score & Grade
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        primaryColor.withOpacity(0.22),
                        const Color(0xFF0F172A),
                      ]
                    : [
                        primaryColor.withOpacity(0.12),
                        const Color(0xFFF8FAFC),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              children: [
                // Circular Match Badge
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 2.5),
                  ),
                  child: Center(
                    child: Text(
                      '${result.matchPercentage}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Title, Grade & Engine Tag
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome_rounded, size: 12, color: primaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  result.matchGrade,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            l10n.matchPercentage(result.matchPercentage),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.aiMatchAnalysisTitle,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Description
                Text(
                  result.summary,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Matched Skills Section
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.matchedSkillsLabel,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: result.matchedSkills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF059669).withOpacity(0.30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.done_rounded,
                            size: 14,
                            color: Color(0xFF059669),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            skill,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                // 3. Missing Skills Section (When present)
                if (result.hasMissingSkills) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.missingSkillsLabel,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: result.missingSkills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFD97706).withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.school_outlined,
                              size: 14,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              skill,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706).withOpacity(0.20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.upskillRecommended,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // 4. Step 21: 5-Factor Weighted Scoring Model Breakdown
                InkWell(
                  onTap: () {
                    setState(() {
                      _isBreakdownExpanded = !_isBreakdownExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.analytics_outlined,
                          size: 18,
                          color: Color(0xFF1E3A8A),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.weightedScoringModelTitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Icon(
                          _isBreakdownExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_isBreakdownExpanded) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        _FactorProgressRow(
                          label: l10n.factorSkillMatch,
                          weightText: '40%',
                          score: breakdown.skillScore,
                          contributionText:
                              '${breakdown.skillContribution.toStringAsFixed(1)}% pts',
                          color: const Color(0xFF059669),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _FactorProgressRow(
                          label: l10n.factorQualification,
                          weightText: '20%',
                          score: breakdown.qualificationScore,
                          contributionText:
                              '${breakdown.qualificationContribution.toStringAsFixed(1)}% pts',
                          color: const Color(0xFF3B82F6),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _FactorProgressRow(
                          label: l10n.factorLocation,
                          weightText: '15%',
                          score: breakdown.locationScore,
                          contributionText:
                              '${breakdown.locationContribution.toStringAsFixed(1)}% pts',
                          color: const Color(0xFF8B5CF6),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _FactorProgressRow(
                          label: l10n.factorCategory,
                          weightText: '15%',
                          score: breakdown.categoryScore,
                          contributionText:
                              '${breakdown.categoryContribution.toStringAsFixed(1)}% pts',
                          color: const Color(0xFFEC4899),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _FactorProgressRow(
                          label: l10n.factorExperience,
                          weightText: '10%',
                          score: breakdown.experienceScore,
                          contributionText:
                              '${breakdown.experienceContribution.toStringAsFixed(1)}% pts',
                          color: const Color(0xFFF59E0B),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // 5. Step 21: Legal Non-Guarantee Disclaimer Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.aiRecommendationNonGuaranteeDisclaimer,
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.45,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FactorProgressRow extends StatelessWidget {
  final String label;
  final String weightText;
  final double score; // 0.0 to 1.0
  final String contributionText;
  final Color color;
  final bool isDark;

  const _FactorProgressRow({
    required this.label,
    required this.weightText,
    required this.score,
    required this.contributionText,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$label ($weightText)',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                ),
              ),
            ),
            Text(
              contributionText,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
