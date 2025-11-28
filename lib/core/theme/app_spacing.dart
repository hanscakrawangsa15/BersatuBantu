import 'package:flutter/material.dart';

/// Spacing constants untuk konsistensi jarak antar element
class AppSpacing {
  // Spacing Values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  // Padding Presets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);
  
  // Horizontal Padding
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets horizontalXXL = EdgeInsets.symmetric(horizontal: xxl);
  
  // Vertical Padding
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets verticalXXL = EdgeInsets.symmetric(vertical: xxl);
  
  // Screen Padding (untuk main content)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: xl,
  );
  
  static const EdgeInsets screenPaddingLarge = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: xxxl,
  );
  
  // Card Padding
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(xl);
  
  // SizedBox Helpers
  static const Widget verticalSpaceXS = SizedBox(height: xs);
  static const Widget verticalSpaceSM = SizedBox(height: sm);
  static const Widget verticalSpaceMD = SizedBox(height: md);
  static const Widget verticalSpaceLG = SizedBox(height: lg);
  static const Widget verticalSpaceXL = SizedBox(height: xl);
  static const Widget verticalSpaceXXL = SizedBox(height: xxl);
  static const Widget verticalSpaceXXXL = SizedBox(height: xxxl);
  
  static const Widget horizontalSpaceXS = SizedBox(width: xs);
  static const Widget horizontalSpaceSM = SizedBox(width: sm);
  static const Widget horizontalSpaceMD = SizedBox(width: md);
  static const Widget horizontalSpaceLG = SizedBox(width: lg);
  static const Widget horizontalSpaceXL = SizedBox(width: xl);
  static const Widget horizontalSpaceXXL = SizedBox(width: xxl);
  
  // Responsive Padding Helper
  static EdgeInsets responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    
    return EdgeInsets.symmetric(
      horizontal: width * 0.06,  // 6% dari lebar
      vertical: height * 0.05,   // 5% dari tinggi
    );
  }
  
  static EdgeInsets responsiveScreenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    
    return EdgeInsets.symmetric(
      horizontal: width * 0.05,
      vertical: height * 0.04,
    );
  }
}