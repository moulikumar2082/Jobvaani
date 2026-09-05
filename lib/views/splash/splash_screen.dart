import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_flow_provider.dart';
import '../../providers/jobs_provider.dart';
import '../../widgets/jobvaani_logo.dart';
import '../onboarding/onboarding_screen.dart';
import '../language/language_selection_screen.dart';
import '../auth/login_screen.dart';
import '../main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _animController.forward();
    _handleRouting();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRouting() async {
    // Keep splash visible for minimum 2.2 seconds for brand perception
    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final appFlow = Provider.of<AppFlowProvider>(context, listen: false);

    // Ensure providers finished loading local storage
    if (!appFlow.isInitialized) {
      await appFlow.initFlowState();
    }

    Widget destination;

    if (!appFlow.hasCompletedOnboarding) {
      destination = const OnboardingScreen();
    } else if (!appFlow.hasSelectedLanguage) {
      destination = const LanguageSelectionScreen();
    } else if (!auth.isAuthenticated) {
      destination = const LoginScreen();
    } else {
      final jobs = Provider.of<JobsProvider>(context, listen: false);
      if (auth.currentUser != null) {
        await jobs.loadSavedJobsForUser(auth.currentUser!.id, token: auth.token);
      }
      destination = const MainNavigationScreen();
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // JobVaani Logo
                  JobVaaniLogo(
                    size: 96,
                    showText: false,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  // App Name
                  Text(
                    l10n.appName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline: "Every Opportunity, In Your Language."
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      l10n.tagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Loading indicator
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? const Color(0xFF38BDF8) : const Color(0xFF1E3A8A),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Localized loading hint
                  Text(
                    l10n.splashLoading,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
