import 'package:flutter/material.dart';
import 'package:bersatubantu/fitur/auth/login/login_screen.dart';
import '../../core/theme/app_colors.dart';           // ✅ Goes up 2 levels
import '../../core/theme/app_constants.dart';        // ✅
import '../../core/theme/app_spacing.dart';          // ✅
import '../../core/theme/app_text_style.dart';       // ✅ Fixed filename too
import '../../core/theme/phone_frame_layout.dart';   // ✅
import '../../core/utils/navigation_helper.dart';
import 'package:bersatubantu/core/theme/app_text_styles.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(milliseconds: AppConstants.animationDuration),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPaddingLarge,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo dengan border seperti di Figma
                    Container(
                      width: 180,
                      height: 180,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/bersatubantu.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    AppSpacing.verticalSpaceLG,
                    
                    // Welcome Text
                    Text(
                      'Selamat Datang,',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    AppSpacing.verticalSpaceSM,
                    
                    // App Name dengan gradient
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ).createShader(bounds),
                      child: Text(
                        'Pahlawan!',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    AppSpacing.verticalSpaceMD,
                    
                    // Tagline
                    Padding(
                      padding: AppSpacing.horizontalXL,
                      child: Text(
                        'Mari bersama membangun komunitas yang saling membantu',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    AppSpacing.verticalSpaceXXL,
                    AppSpacing.verticalSpaceLG,
                    
                    // Button Mulai
                    _buildStartButton(),
                    
                    AppSpacing.verticalSpaceLG,
                    
                    // Skip Text
                    TextButton(
                      onPressed: () {
                        // Navigate to home or skip intro
                      },
                      child: Text(
                        'Lewati',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () {
        NavigationHelper.slideNavigate(
          context,
          LoginScreen(),
          durationMs: AppConstants.transitionDuration,
        );
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Mulai',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}