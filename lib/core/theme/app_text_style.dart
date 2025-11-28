import 'package:flutter/material.dart';
import 'app_text_styles.dart';

/// Alias supaya kode lama yang memakai AppTextStyle tetap jalan
/// Class ini cuma forwarding ke AppTextStyles yang sebenarnya
class AppTextStyle {
  // Display Styles
  static const TextStyle displayLarge = AppTextStyles.displayLarge;
  static const TextStyle displayMedium = AppTextStyles.displayMedium;
  static const TextStyle displaySmall = AppTextStyles.displaySmall;

  // Heading Styles
  static const TextStyle headingLarge = AppTextStyles.headingLarge;
  static const TextStyle headingMedium = AppTextStyles.headingMedium;
  static const TextStyle headingSmall = AppTextStyles.headingSmall;
  
  // Heading Aliases
  static const TextStyle h1 = AppTextStyles.h1;
  static const TextStyle h2 = AppTextStyles.h2;
  static const TextStyle h3 = AppTextStyles.h3;
  static const TextStyle h4 = AppTextStyles.h4;
  static const TextStyle h5 = AppTextStyles.h5;

  // Body Styles
  static const TextStyle bodyLarge = AppTextStyles.bodyLarge;
  static const TextStyle bodyMedium = AppTextStyles.bodyMedium;
  static const TextStyle bodySmall = AppTextStyles.bodySmall;

  // Label Styles
  static const TextStyle labelLarge = AppTextStyles.labelLarge;
  static const TextStyle labelMedium = AppTextStyles.labelMedium;
  static const TextStyle labelSmall = AppTextStyles.labelSmall;

  // Button Styles
  static const TextStyle button = AppTextStyles.button;
  static const TextStyle buttonMedium = AppTextStyles.buttonMedium;
  static const TextStyle buttonSmall = AppTextStyles.buttonSmall;

  // Special Styles
  static const TextStyle caption = AppTextStyles.caption;
  static const TextStyle captionSmall = AppTextStyles.captionSmall;
  static const TextStyle overline = AppTextStyles.overline;
}