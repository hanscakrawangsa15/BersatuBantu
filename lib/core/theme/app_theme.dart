import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryBlue,
        onPrimary: AppColors.bgPrimary,
        secondary: AppColors.accentGreen,
        onSecondary: AppColors.bgPrimary,
        tertiary: AppColors.accentOrange,
        error: AppColors.errorRed,
        surface: AppColors.bgPrimary,
        onSurface: AppColors.textPrimary,
        brightness: Brightness.light,
      ),

      // Scaffolding
      scaffoldBackgroundColor: AppColors.bgPrimary,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.headingLarge,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
      ),

      // Input Decoration (TextField default)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
            width: 2,
          ),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        errorStyle: AppTextStyles.captionSmall.copyWith(
          color: AppColors.errorRed,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.bgPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(
            color: AppColors.borderMedium,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgPrimary,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        color: AppColors.bgPrimary,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: AppColors.bgPrimary,
        titleTextStyle: AppTextStyles.headingMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgSecondary,
        selectedColor: AppColors.primaryBlue,
        disabledColor: AppColors.bgTertiary,
        side: const BorderSide(
          color: AppColors.borderLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: AppTextStyles.labelSmall,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryBlue,
        linearMinHeight: 4,
      ),

      // Text Themes
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        headlineSmall: AppTextStyles.headingSmall,
        titleLarge: AppTextStyles.headingLarge,
        titleMedium: AppTextStyles.headingMedium,
        titleSmall: AppTextStyles.headingSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // Other Properties
      dividerColor: AppColors.borderLight,
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 16,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryBlueLight,
        onPrimary: AppColors.bgDark,
        secondary: AppColors.accentGreen,
        onSecondary: AppColors.bgDark,
        error: AppColors.errorRed,
        surface: AppColors.bgDark,
        onSurface: AppColors.bgPrimary,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
    );
  }
}
