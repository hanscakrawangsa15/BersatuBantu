import 'dart:async';
import 'package:flutter/material.dart';

import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_constants.dart';
import 'package:bersatubantu/core/theme/app_spacing.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/theme/app_text_styles.dart';
import 'package:bersatubantu/core/theme/phone_frame_layout.dart';

import 'package:bersatubantu/core/utils/navigation_helper.dart';

import 'welcome_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Start animation
    _controller.forward();

    // Navigate after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        NavigationHelper.fadeReplace(context, const WelcomeScreen());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background gradient yang soft seperti di Figma
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F0FE), // Light blue
              Color(0xFFF3EFFF), // Light purple
              Color(0xFFFCE4EC), // Light pink
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container dengan shadow seperti di Figma
                  Container(
                    width: 220,
                    height: 220,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Image
                        Expanded(
                          child: Image.asset(
                            'assets/bersatubantu.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // App Name
                        Text(
                          'BersatuBantu',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Loading Indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Loading Text
                  Text(
                    'Loading...',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}