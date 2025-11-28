import 'package:flutter/material.dart';

/// Color constants untuk konsistensi warna
class AppColors {
  // Primary Colors (Purple from Figma)
  static const Color primary = Color(0xFF7B68C4); // Purple utama dari Figma
  static const Color primaryLight = Color(0xFF9B8BD4);
  static const Color primaryDark = Color(0xFF5B4894);
  
  // Secondary Colors (Blue accent)
  static const Color secondary = Color(0xFF6B9FE8); // Blue dari Figma
  static const Color secondaryLight = Color(0xFF8BB4F0);
  static const Color secondaryDark = Color(0xFF4B7FC8);
  
  // Accent Colors
  static const Color accent = Color(0xFF7B68C4); // Purple
  static const Color accentLight = Color(0xFF9B8BD4);
  
  // Background Colors
  static const Color background = Color(0xFFF5F7FA); // Light blue-gray
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF424242);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748); // Dark gray
  static const Color textSecondary = Color(0xFF718096); // Medium gray
  static const Color textHint = Color(0xFFA0AEC0); // Light gray
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFF56565);
  static const Color info = Color(0xFF4299E1);
  
  // Gradient Colors (dari Figma)
  static const List<Color> blueGradient = [
    Color(0xFFE8F0FE),
    Color(0xFFD6E4FD),
    Color(0xFFC4D8FC),
  ];
  
  static const List<Color> purpleGradient = [
    Color(0xFFF3EFFF),
    Color(0xFFE6DCFF),
    Color(0xFFD9C9FF),
  ];
  
  // Primary Gradient (Purple to Blue - sesuai Figma)
  static const List<Color> primaryGradient = [
    Color(0xFF9B8BD4), // Light purple
    Color(0xFF7B68C4), // Medium purple
    Color(0xFF6B9FE8), // Blue
  ];
  
  // Welcome Gradient (Background splash & welcome)
  static const List<Color> welcomeGradient = [
    Color(0xFFE8F0FE), // Very light blue
    Color(0xFFF3EFFF), // Very light purple
    Color(0xFFFCE4EC), // Very light pink
  ];
  
  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFEDF2F7);
  static const Color borderDark = Color(0xFFCBD5E0);
  
  // Shadow Colors
  static Color shadow = Colors.black.withOpacity(0.08);
  static Color shadowMedium = Colors.black.withOpacity(0.12);
  static Color shadowDark = Colors.black.withOpacity(0.25);

  // Primary alias (untuk backward compatibility)
  static const Color primaryBlue = primary; // Sekarang purple
  static const Color primaryBlueLight = primaryLight;

  // Background alias
  static const Color bgPrimary = surface; // putih / kartu
  static const Color bgSecondary = background; // abu soft
  static const Color bgTertiary = Color(0xFFE8F0FE); // Light blue
  static const Color bgDark = surfaceDark;

  // Accent alias
  static const Color accentGreen = success;
  static const Color accentOrange = warning;

  // Status alias
  static const Color errorRed = error;
  static const Color successGreen = success;
  static const Color warningYellow = warning;
  static const Color infoBlue = info;

  // Text alias
  static const Color textTertiary = textHint;

  // Border alias
  static const Color borderMedium = borderDark;
}