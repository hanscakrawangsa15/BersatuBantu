import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF5B6EFF);
  static const Color primaryBlueDark = Color(0xFF4A54D9);
  static const Color primaryBlueLight = Color(0xFF7B8EFF);

  // Secondary Colors
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentYellow = Color(0xFFFCD34D);

  // Neutral Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  // Background Colors
  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF3F4F6);
  static const Color bgTertiary = Color(0xFFE5E7EB);
  static const Color bgDark = Color(0xFF111827);

  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);

  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningYellow = Color(0xFFFCD34D);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);

  // Gradient Colors
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueDark],
  );

  static const LinearGradient gradientSuccess = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGreen, Color(0xFF059669)],
  );

  // Opacity variants
  static Color primaryBlueWithOpacity(double opacity) =>
      primaryBlue.withOpacity(opacity);
  static Color textPrimaryWithOpacity(double opacity) =>
      textPrimary.withOpacity(opacity);
  static Color bgSecondaryWithOpacity(double opacity) =>
      bgSecondary.withOpacity(opacity);
}
