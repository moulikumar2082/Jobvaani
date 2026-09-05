import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Custom Material 3 ThemeExtension for JobVaani (Step 25).
/// Provides strongly-typed semantic color tokens accessible via `context.colors`.
class JobVaaniThemeColors extends ThemeExtension<JobVaaniThemeColors> {
  final Color bg;
  final Color surface;
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color sarkariAccent;
  final Color successAccent;
  final Color deadlineAccent;
  final Color inputBg;
  final Color tagBg;
  final Color divider;

  const JobVaaniThemeColors({
    required this.bg,
    required this.surface,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.sarkariAccent,
    required this.successAccent,
    required this.deadlineAccent,
    required this.inputBg,
    required this.tagBg,
    required this.divider,
  });

  /// Light theme token mapping
  static const JobVaaniThemeColors light = JobVaaniThemeColors(
    bg: AppColors.lightBg,
    surface: AppColors.lightSurface,
    card: AppColors.lightCard,
    border: AppColors.lightBorder,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    primary: AppColors.navyPrimary,
    sarkariAccent: AppColors.sarkariAmber,
    successAccent: AppColors.successGreen,
    deadlineAccent: AppColors.urgencyRed,
    inputBg: AppColors.lightInputBg,
    tagBg: AppColors.lightTagBg,
    divider: AppColors.lightDivider,
  );

  /// Dark theme token mapping
  static const JobVaaniThemeColors dark = JobVaaniThemeColors(
    bg: AppColors.darkBg,
    surface: AppColors.darkSurface,
    card: AppColors.darkCard,
    border: AppColors.darkBorder,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    primary: AppColors.blueAccent,
    sarkariAccent: AppColors.sarkariAmber,
    successAccent: AppColors.successGreen,
    deadlineAccent: AppColors.urgencyRed,
    inputBg: AppColors.darkInputBg,
    tagBg: AppColors.darkTagBg,
    divider: AppColors.darkDivider,
  );

  @override
  ThemeExtension<JobVaaniThemeColors> copyWith({
    Color? bg,
    Color? surface,
    Color? card,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? primary,
    Color? sarkariAccent,
    Color? successAccent,
    Color? deadlineAccent,
    Color? inputBg,
    Color? tagBg,
    Color? divider,
  }) {
    return JobVaaniThemeColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primary: primary ?? this.primary,
      sarkariAccent: sarkariAccent ?? this.sarkariAccent,
      successAccent: successAccent ?? this.successAccent,
      deadlineAccent: deadlineAccent ?? this.deadlineAccent,
      inputBg: inputBg ?? this.inputBg,
      tagBg: tagBg ?? this.tagBg,
      divider: divider ?? this.divider,
    );
  }

  @override
  ThemeExtension<JobVaaniThemeColors> lerp(
    covariant ThemeExtension<JobVaaniThemeColors>? other,
    double t,
  ) {
    if (other is! JobVaaniThemeColors) return this;
    return JobVaaniThemeColors(
      bg: Color.lerp(bg, other.bg, t) ?? bg,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      card: Color.lerp(card, other.card, t) ?? card,
      border: Color.lerp(border, other.border, t) ?? border,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      sarkariAccent: Color.lerp(sarkariAccent, other.sarkariAccent, t) ?? sarkariAccent,
      successAccent: Color.lerp(successAccent, other.successAccent, t) ?? successAccent,
      deadlineAccent: Color.lerp(deadlineAccent, other.deadlineAccent, t) ?? deadlineAccent,
      inputBg: Color.lerp(inputBg, other.inputBg, t) ?? inputBg,
      tagBg: Color.lerp(tagBg, other.tagBg, t) ?? tagBg,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
    );
  }

  /// Direct accessor from BuildContext
  static JobVaaniThemeColors of(BuildContext context) {
    return Theme.of(context).extension<JobVaaniThemeColors>() ??
        (Theme.of(context).brightness == Brightness.dark
            ? JobVaaniThemeColors.dark
            : JobVaaniThemeColors.light);
  }
}

/// Convenience BuildContext extension: `context.colors`
extension JobVaaniThemeContext on BuildContext {
  JobVaaniThemeColors get colors => JobVaaniThemeColors.of(this);
}
