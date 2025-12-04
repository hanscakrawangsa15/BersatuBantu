import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'app_scaffold.dart';
import 'app-button.dart';
import 'app-text-field.dart';
import 'form_layout.dart';

/// Template Screen untuk Authentication (Login/Register)
/// Gunakan sebagai referensi untuk implementasi auth screens
class AuthScreenTemplate extends StatefulWidget {
  const AuthScreenTemplate({Key? key}) : super(key: key);

  @override
  State<AuthScreenTemplate> createState() => _AuthScreenTemplateState();
}

class _AuthScreenTemplateState extends State<AuthScreenTemplate> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      showBackButton: false,
      body: FormLayout(
        title: 'Selamat Datang',
        subtitle: 'di Bersatu Bantu!',
        fields: [
          AppTextField(
            label: 'Email',
            hint: 'Masukkan email Anda',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          AppTextField(
            label: 'Password',
            hint: 'Masukkan password',
            controller: _passwordController,
            isPassword: true,
            isRequired: true,
          ),
        ],
        submitButton: SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Masuk',
            onPressed: () => _handleLogin(),
            isLoading: _isLoading,
            size: ButtonSize.large,
          ),
        ),
        bottomWidget: Column(
          children: [
            const Divider(
              color: AppColors.borderLight,
              height: 32,
            ),
            Text(
              'Atau lanjutkan dengan',
              style: AppTextStyle.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(
                  icon: '🔵',
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  icon: '🍎',
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  icon: '📘',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Belum memiliki akun? ',
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Daftar',
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login berhasil!')),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderLight,
          ),
        ),
        child: Center(
          child: Text(
            icon,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }
}
