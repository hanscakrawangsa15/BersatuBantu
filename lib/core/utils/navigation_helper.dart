import 'package:flutter/material.dart';

/// Helper untuk navigasi dengan animasi
class NavigationHelper {
  /// Navigate dengan slide transition (dari kanan ke kiri)
  static Future<T?> slideNavigate<T>(
    BuildContext context,
    Widget page, {
    int durationMs = 250,
  }) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration(milliseconds: durationMs),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  /// Navigate dengan fade transition
  static Future<T?> fadeNavigate<T>(
    BuildContext context,
    Widget page, {
    int durationMs = 250,
  }) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration(milliseconds: durationMs),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  /// Navigate dengan fade transition dan replace (ini yang dibutuhkan splash_screen)
  static Future<T?> fadeReplace<T>(
    BuildContext context,
    Widget page, {
    int durationMs = 250,
  }) {
    return Navigator.pushReplacement<T, void>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration(milliseconds: durationMs),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  /// Navigate dan replace (remove previous screen)
  static Future<T?> slideNavigateAndReplace<T>(
    BuildContext context,
    Widget page, {
    int durationMs = 250,
  }) {
    return Navigator.pushReplacement<T, void>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration(milliseconds: durationMs),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  /// Navigate ke named route
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate dan remove semua screen sebelumnya
  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  /// Go back
  static void goBack(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }
}