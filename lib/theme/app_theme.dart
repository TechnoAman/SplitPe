import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Refined Obsidian & Charcoal Palette (Linear / Apple style)
  static const Color background = Color(0xFF09090B);
  static const Color surface = Color(0xFF121215);
  static const Color surfaceElevated = Color(0xFF18181B);
  static const Color surfaceCard = Color(0xFF1E1E24);
  static const Color cardBorder = Color(0xFF27272A);
  static const Color subtleBorder = Color(0xFF323238);
  static const Color neoBorder = Color(0xFF27272A);

  // Refined Accents
  static const Color primaryGreen = Color(0xFF10B981); // Refined Emerald Green
  static const Color emeraldDark = Color(0xFF059669);
  static const Color neonCyan = Color(0xFF38BDF8);
  static const Color electricPurple = Color(0xFF8B5CF6);
  static const Color goldenYellow = Color(0xFFFBBF24);
  static const Color alertRed = Color(0xFFF43F5E);
  static const Color neoWhite = Color(0xFFFFFFFF);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFF4F4F5);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  // Smooth Gradients
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF18181B), Color(0xFF121215)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryGreen,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        secondary: AppColors.neonCyan,
        surface: AppColors.surface,
        error: AppColors.alertRed,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
