import 'package:flutter/material.dart';

/// Centralized Color Palette for JobVaani (Step 25).
/// Enforces consistent Material 3 tokens across light and dark modes,
/// ensuring zero hardcoded color values inside individual widgets.
class AppColors {
  AppColors._();

  // Core Brand Colors
  static const Color navyPrimary = Color(0xFF1E3A8A); // Deep Indian Navy Blue
  static const Color blueAccent = Color(0xFF3B82F6);  // Interactive Blue
  static const Color tealAccent = Color(0xFF0D9488);  // Professional Teal
  static const Color indigoAccent = Color(0xFF6366F1); // Modern Accent

  // Domain & Status Colors
  static const Color sarkariAmber = Color(0xFFD97706); // Government/Sarkari Alerts
  static const Color successGreen = Color(0xFF059669); // High Profile Match
  static const Color urgencyRed = Color(0xFFE11D48);   // Approaching Deadline
  static const Color warningOrange = Color(0xFFF59E0B);// Missing Skill / Warning
  static const Color purpleAccent = Color(0xFF8B5CF6); // Academic / Certifications

  // Light Palette Tokens
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightInputBg = Color(0xFFF1F5F9);
  static const Color lightTagBg = Color(0xFFF1F5F9);
  static const Color lightDivider = Color(0xFFE2E8F0);

  // Dark Palette Tokens (Sleek Slate Contrast)
  static const Color darkBg = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF94A3B8);
  static const Color darkInputBg = Color(0xFF0F172A);
  static const Color darkTagBg = Color(0xFF0F172A);
  static const Color darkDivider = Color(0xFF1E293B);
}
