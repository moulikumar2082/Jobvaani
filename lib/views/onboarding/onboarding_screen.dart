import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_flow_provider.dart';
import '../language/language_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _finishOnboarding() {
    Provider.of<AppFlowProvider>(context, listen: false).completeOnboarding();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => const LanguageSelectionScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final slides = [
      _OnboardingPageData(
        type: _IllustrationType.discover,
        accentColor: const Color(0xFF2563EB), // Royal Indian Blue
        badgeText: "Private • Govt • Internships",
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
      ),
      _OnboardingPageData(
        type: _IllustrationType.govtAlerts,
        accentColor: const Color(0xFFD97706), // Amber / Gold
        badgeText: "Central & State Sarkari",
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
      ),
      _OnboardingPageData(
        type: _IllustrationType.deadline,
        accentColor: const Color(0xFF0D9488), // Professional Teal
        badgeText: "Admit Cards & Exam Dates",
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              l10n.skip,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // Attractive lightweight vector illustration
                        _buildIllustration(slide.type, slide.accentColor, isDark),

                        const SizedBox(height: 36),

                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: slide.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: slide.accentColor.withOpacity(0.25)),
                          ),
                          child: Text(
                            slide.badgeText,
                            style: TextStyle(
                              color: slide.accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Main Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Smooth Indicator Dots
                  Row(
                    children: List.generate(
                      slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == i ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? const Color(0xFF1E3A8A)
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started Action Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == slides.length - 1 ? l10n.getStarted : l10n.next,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == slides.length - 1
                              ? Icons.check_circle_outline_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(_IllustrationType type, Color color, bool isDark) {
    return Container(
      width: 220,
      height: 200,
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withOpacity(0.18), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background concentric radar rings
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.15), width: 1),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2), width: 1.2),
            ),
          ),

          // Central Icon Hero Box
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(_getCenterIcon(type), size: 36, color: Colors.white),
          ),

          // Floating Feature Badges
          if (type == _IllustrationType.discover) ...[
            Positioned(
              top: 24,
              right: 20,
              child: _buildBadge(Icons.work_outline_rounded, "Tech Jobs", Colors.blue, isDark),
            ),
            Positioned(
              bottom: 24,
              left: 20,
              child: _buildBadge(Icons.school_outlined, "₹1.25L Stipend", Colors.teal, isDark),
            ),
          ] else if (type == _IllustrationType.govtAlerts) ...[
            Positioned(
              top: 24,
              left: 20,
              child: _buildBadge(Icons.account_balance_outlined, "UPSC / ISRO", Colors.amber, isDark),
            ),
            Positioned(
              bottom: 24,
              right: 20,
              child: _buildBadge(Icons.verified_outlined, "7th CPC", Colors.green, isDark),
            ),
          ] else ...[
            Positioned(
              top: 24,
              right: 20,
              child: _buildBadge(Icons.timer_outlined, "3 Days Left", Colors.redAccent, isDark),
            ),
            Positioned(
              bottom: 24,
              left: 20,
              child: _buildBadge(Icons.notifications_active_outlined, "Exam Alert", Colors.teal, isDark),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color badgeColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: badgeColor.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCenterIcon(_IllustrationType type) {
    switch (type) {
      case _IllustrationType.discover:
        return Icons.travel_explore_rounded;
      case _IllustrationType.govtAlerts:
        return Icons.account_balance_rounded;
      case _IllustrationType.deadline:
        return Icons.event_available_rounded;
    }
  }
}

enum _IllustrationType { discover, govtAlerts, deadline }

class _OnboardingPageData {
  final _IllustrationType type;
  final Color accentColor;
  final String badgeText;
  final String title;
  final String description;

  _OnboardingPageData({
    required this.type,
    required this.accentColor,
    required this.badgeText,
    required this.title,
    required this.description,
  });
}
