import 'package:flutter/material.dart';

/// World-class design tokens inspired by CRED, Apple, and Netflix design systems.
/// Replaces cartoonish gradients and blurry aurora blobs with tactile dark luxury,
/// true obsidian canvas, razor-thin micro-borders, and high-contrast typography.
class AppTheme {
  // Brand Accents - Luxury Financial Engine
  static const Color primary = Color(0xFF00D09C); // Luminous Emerald Mint (Wealth & Freedom)
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF059669);

  static const Color secondary = Color(0xFF38BDF8); // Electric Sky / Azure (Clarity & Intelligence)
  static const Color secondaryLight = Color(0xFF7DD3FC);

  static const Color accent = Color(0xFFF59E0B); // Amber Gold (Milestones & Streaks)
  static const Color danger = Color(0xFFF43F5E); // Crimson Rose (Overdue & High Risk)
  static const Color warning = Color(0xFFFB923C); // Warm Tangerine
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color info = Color(0xFF38BDF8);

  // Surfaces - Obsidian Depth (CRED / Apple Wallet tier)
  static const Color bgDark = Color(0xFF08090E); // Deep Obsidian Canvas
  static const Color cardDark = Color(0xFF12141D); // Primary Surface (Elevated)
  static const Color cardDarkSecondary = Color(0xFF1A1D29); // Secondary Surface (Pills/Badges)
  static const Color borderDark = Color(0x1FFFFFFF); // 12% White Micro-border

  // Surfaces - Ceramic Clean Light
  static const Color bgLight = Color(0xFFF6F8FA); // Studio Canvas Light
  static const Color cardLight = Colors.white;
  static const Color cardLightSecondary = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0x0F000000); // 6% Black Micro-border

  // Muted Typography
  static const Color textMutedDark = Color(0xFF8E95A5);
  static const Color textMutedLight = Color(0xFF64748B);

  /// True luxury atmospheric background.
  /// Replaces muddy multi-colored blobs with a precision, high-contrast canvas
  /// having a faint, single ambient zenith glow.
  static Widget glassBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: isDark ? bgDark : bgLight,
          ),
        ),
        // Subtle, restrained atmospheric zenith glow (top 15%)
        Positioned(
          top: -120,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 500,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? primary : primaryDark).withValues(alpha: isDark ? 0.08 : 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Tactile, precision surface card styling.
  /// Uses razor-thin borders and clean elevations instead of heavy blurred glass.
  static BoxDecoration glassDecoration(BuildContext context, {
    double blur = 0,
    double opacity = 1.0,
    BorderRadius? borderRadius,
    bool hasInnerGlow = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(20);
    
    return BoxDecoration(
      color: isDark ? cardDark : cardLight,
      borderRadius: radius,
      border: Border.all(
        color: isDark ? borderDark : borderLight,
        width: 1.0,
      ),
      boxShadow: [
        if (!isDark)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          )
        else
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
      ],
    );
  }

  /// Secondary surface decoration for nested items, chips, and input fields.
  static BoxDecoration surfaceSecondary(BuildContext context, {BorderRadius? borderRadius}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? cardDarkSecondary : cardLightSecondary,
      borderRadius: borderRadius ?? BorderRadius.circular(14),
      border: Border.all(
        color: isDark ? borderDark : borderLight,
        width: 0.5,
      ),
    );
  }

  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient auroraGradient = const LinearGradient(
    colors: [Color(0xFF00D09C), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData lightTheme(ThemeData base) {
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryDark,
        secondary: secondary,
        surface: cardLight,
      ),
      scaffoldBackgroundColor: bgLight,
      cardColor: cardLight,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF0F172A),
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
    );
  }

  static ThemeData darkTheme(ThemeData base) {
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primary,
        secondary: secondary,
        surface: cardDark,
      ),
      scaffoldBackgroundColor: bgDark,
      cardColor: cardDark,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
    );
  }
}
