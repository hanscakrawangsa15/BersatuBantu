import 'package:flutter/material.dart';

/// Helper untuk responsive design
class ResponsiveHelper {
  // Screen breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Check device type
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
  
  // Screen dimensions
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  // Responsive values
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }
  
  // Responsive padding
  static double responsiveValue(
    BuildContext context,
    double mobile, [
    double? tablet,
    double? desktop,
  ]) {
    return value<double>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}