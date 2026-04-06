import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors - Premium Segment
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color secondary = Color(0xFFEC4899); // Pink/Magenta
  static const Color accent = Color(0xFF10B981); // Emerald
  
  static const Color danger = Color(0xFFEF4444); 
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);

  // Surface Colors
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgDark = Color(0xFF0F172A); // Slate 950
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E293B);

  static Widget glassBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: isDark ? bgDark : bgLight,
          ),
        ),
        // Primary Aurora Glow
        Positioned(
          top: -150,
          right: -100,
          child: _buildAuroraGlow(primary.withValues(alpha: isDark ? 0.25 : 0.12), 450),
        ),
        // Secondary Aurora Glow
        Positioned(
          bottom: -50,
          left: -100,
          child: _buildAuroraGlow(secondary.withValues(alpha: isDark ? 0.2 : 0.08), 400),
        ),
        // Accent Aurora Glow
        Positioned(
          top: 250,
          left: -50,
          child: _buildAuroraGlow(accent.withValues(alpha: isDark ? 0.1 : 0.05), 300),
        ),
      ],
    );
  }

  static Widget _buildAuroraGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
    );
  }

  static BoxDecoration glassDecoration(BuildContext context, {
    double blur = 15,
    double opacity = 0.08,
    BorderRadius? borderRadius,
    bool hasInnerGlow = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;
    
    return BoxDecoration(
      color: baseColor.withValues(alpha: opacity),
      borderRadius: borderRadius ?? BorderRadius.circular(32),
      border: Border.all(
        color: baseColor.withValues(alpha: 0.08),
        width: 1.5,
      ),
      boxShadow: [
        if (hasInnerGlow)
          BoxShadow(
            color: baseColor.withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(1, 1),
          ),
      ],
    );
  }

  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient auroraGradient = const LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static ThemeData lightTheme(ThemeData base) {
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        secondary: secondary,
        surface: bgLight,
      ),
      scaffoldBackgroundColor: bgLight,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1F2937),
        titleTextStyle: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
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
        surface: bgDark,
      ),
      scaffoldBackgroundColor: bgDark,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        color: cardDark,
      ),
    );
  }
}
