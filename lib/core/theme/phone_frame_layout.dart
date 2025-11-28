import 'package:flutter/material.dart';
import 'package:bersatubantu/core/theme/app_spacing.dart';


/// Reusable layout untuk semua screen dengan padding seperti HP
class PhoneFrameLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool useSafeArea;
  final bool isScrollable;
  final Color? backgroundColor;
  final Gradient? gradient;
  
  const PhoneFrameLayout({
    Key? key,
    required this.child,
    this.padding,
    this.useSafeArea = true,
    this.isScrollable = false,
    this.backgroundColor,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    
    // Apply padding
    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    } else {
      content = Padding(
        padding: AppSpacing.responsivePadding(context),
        child: content,
      );
    }
    
    // Make scrollable if needed - FIX: Remove ConstrainedBox yang menyebabkan infinite height
    if (isScrollable) {
      content = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: content, // Langsung pakai content tanpa ConstrainedBox
      );
    }
    
    // Apply safe area
    if (useSafeArea) {
      content = SafeArea(child: content);
    }
    
    // Apply background
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
      ),
      child: content,
    );
  }
}