import 'package:flutter/material.dart';
import 'app_colors.dart';


class AppTextStyles {
  // Display Styles (Large Text)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Heading Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Heading Aliases (h1-h5)
  static const TextStyle h1 = headingLarge;
  static const TextStyle h2 = headingMedium;
  static const TextStyle h3 = headingSmall;
  
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  // Button Styles
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  // Caption Styles
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textHint,
  );

  static const TextStyle captionSmall = TextStyle(
    fontSize: 10,
    color: AppColors.textHint,
  );

  // Overline Style
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
    letterSpacing: 1.5,
  );
}