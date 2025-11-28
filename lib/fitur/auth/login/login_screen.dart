import 'package:flutter/material.dart';

import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_constants.dart';
import 'package:bersatubantu/core/theme/app_spacing.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/theme/phone_frame_layout.dart';

import 'package:bersatubantu/core/utils/navigation_helper.dart';
import 'package:bersatubantu/core/utils/responsive_helper.dart';

import 'package:bersatubantu/core/widgets/custom_text_field.dart';
import 'package:bersatubantu/core/widgets/custom_button.dart';
import 'package:bersatubantu/core/theme/app_text_styles.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          // Navigate to home or show success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login berhasil!')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhoneFrameLayout(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        isScrollable: true,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: ResponsiveHelper.screenHeight(context) * 0.05),

        // Login Card with Animation
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildLoginCard(),
          ),
        ),

        SizedBox(height: ResponsiveHelper.screenHeight(context) * 0.05),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: AppConstants.maxCardWidth,
      ),
      padding: AppSpacing.cardPaddingLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            AppSpacing.verticalSpaceXL,
            _buildEmailField(),
            AppSpacing.verticalSpaceMD,
            _buildPasswordField(),
            _buildForgotPasswordButton(),
            AppSpacing.verticalSpaceLG,
            _buildLoginButton(),
            AppSpacing.verticalSpaceLG,
            _buildDividerText(),
            AppSpacing.verticalSpaceLG,
            _buildSocialButtons(),
            AppSpacing.verticalSpaceLG,
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Selamat Datang',
          textAlign: TextAlign.center,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.verticalSpaceXS,
        Text(
          'di ${AppConstants.appName}!',
          textAlign: TextAlign.center,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      label: 'Username or E-mail',
      hint: 'email@example.com',
      controller: _emailController,
      prefixIcon: Icons.mail_outline,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email tidak boleh kosong';
        }
        if (!value.contains('@')) {
          return 'Email tidak valid';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
      label: 'Password',
      hint: '••••••••',
      controller: _passwordController,
      prefixIcon: Icons.lock_outline,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.textSecondary,
          size: 22,
        ),
        onPressed: () {
          setState(() => _obscurePassword = !_obscurePassword);
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password tidak boleh kosong';
        }
        if (value.length < 6) {
          return 'Password minimal 6 karakter';
        }
        return null;
      },
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {
          // Handle forgot password
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
        ),
        child: Text(
          'Lupa Kata Sandi?',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return CustomButton(
      text: 'Lanjut',
      onPressed: _isLoading ? null : _handleLogin,
      isLoading: _isLoading,
      backgroundColor: AppColors.primary,
    );
  }

  Widget _buildDividerText() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: AppSpacing.horizontalMD,
          child: Text(
            'Atau masuk dengan',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: Icons.g_mobiledata,
          color: Colors.white,
          iconColor: Colors.red,
          onTap: () {
            // Handle Google login
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Google login clicked')),
            );
          },
        ),
        AppSpacing.horizontalSpaceMD,
        _buildSocialButton(
          icon: Icons.apple,
          color: Colors.black,
          iconColor: Colors.white,
          onTap: () {
            // Handle Apple login
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Apple login clicked')),
            );
          },
        ),
        AppSpacing.horizontalSpaceMD,
        _buildSocialButton(
          icon: Icons.facebook,
          color: AppColors.primary,
          iconColor: Colors.white,
          onTap: () {
            // Handle Facebook login
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Facebook login clicked')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(27),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum mempunyai akun? ',
          style: AppTextStyles.labelMedium,
        ),
        GestureDetector(
          onTap: () {
            // Navigate to register screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navigate to Register')),
            );
          },
          child: Text(
            'Daftar',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
