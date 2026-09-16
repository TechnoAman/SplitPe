import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Official CRED NeoPOP Dark Obsidian Architecture
  static const Color background = Color(0xFF0C0D10);
  static const Color surface = Color(0xFF16171B);
  static const Color surfaceElevated = Color(0xFF1E2026);
  static const Color cardBorder = Color(0xFF2E303A);
  static const Color subtleBorder = Color(0xFF22242B);
  static const Color neoBorder = Color(0xFF383B46);
  static const Color hardShadow = Color(0xFF000000);

  // Light Mode Color Architecture
  static const Color lightBackground = Color(0xFFF4F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFEBF0F8);
  static const Color lightCardBorder = Color(0xFFD6E0EE);
  static const Color lightNeoBorder = Color(0xFFCBD5E1);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextMuted = Color(0xFF9CA3AF);
  static const Color lightBlueSurface = Color(0xFFE8F0FE);

  // Google Play & GPay Electric Blue Palette
  static const Color primaryBlue = Color(0xFF0084FF); // Electric Google Blue
  static const Color primaryBlueDark = Color(0xFF1A73E8); // Classic Google Material Blue
  static const Color primaryGreen = primaryBlue; // Seamless alias for whole-app blue theme
  static const Color greenDark = primaryBlueDark;
  static const Color blueSurface = Color(0xFF0E1E38); // Midnight blue container tint
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color electricPurple = Color(0xFF7C4DFF);
  static const Color goldenYellow = Color(0xFFFFD600);
  static const Color alertRed = Color(0xFFFF1744);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // CRED & Google Typographic Hierarchy
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F9E);
  static const Color textMuted = Color(0xFF555A68);

  // Context-aware dynamic color getters
  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? background
          : lightBackground;

  static Color cardBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surface
          : lightSurface;

  static Color cardElevated(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surfaceElevated
          : lightSurfaceElevated;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? neoBorder
          : lightNeoBorder;

  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textPrimary
          : lightTextPrimary;

  static Color textSub(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textSecondary
          : lightTextSecondary;

  static Color chipBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? blueSurface
          : lightBlueSurface;
}

class ThemeController {
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static bool isDark(BuildContext context) {
    if (themeMode.value == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return themeMode.value == ThemeMode.dark;
  }

  static void toggleTheme() {
    themeMode.value =
        themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryBlue,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.neonCyan,
        surface: AppColors.surface,
        error: AppColors.alertRed,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.primaryBlueDark,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlueDark,
        secondary: AppColors.primaryBlue,
        surface: AppColors.lightSurface,
        error: AppColors.alertRed,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: AppColors.lightTextPrimary,
        displayColor: AppColors.lightTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
