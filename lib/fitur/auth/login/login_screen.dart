import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/form_layout.dart';
import '../../../core/widgets/app-button.dart';
import '../../../core/widgets/app-text-field.dart';
import '../../../core/widgets/app_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorEmail;
  String? _errorPassword;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _errorEmail = _emailController.text.isEmpty
          ? 'Email tidak boleh kosong'
          : !_isValidEmail(_emailController.text)
              ? 'Format email tidak valid'
              : null;

      _errorPassword = _passwordController.text.isEmpty
          ? 'Password tidak boleh kosong'
          : _passwordController.text.length < 6
              ? 'Password minimal 6 karakter'
              : null;
    });

    return _errorEmail == null && _errorPassword == null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _handleLogin() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      // Simulasi login (replace dengan actual Supabase call)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Berhasil masuk!',
          type: SnackBarType.success,
        );

        // Navigate to home
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Gagal masuk: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      showBackButton: false,
      body: SingleChildScrollView(
        child: FormLayout(
          title: 'Selamat Datang',
          subtitle: 'di Bersatu Bantu!',
          fields: [
            AppTextField(
              label: 'Email',
              hint: 'Masukkan email Anda',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              isRequired: true,
              errorText: _errorEmail,
              prefixIcon: const Icon(Icons.email_outlined),
              onChanged: (_) => setState(() => _errorEmail = null),
            ),
            AppTextField(
              label: 'Password',
              hint: 'Masukkan password Anda',
              controller: _passwordController,
              isPassword: true,
              isRequired: true,
              errorText: _errorPassword,
              onChanged: (_) => setState(() => _errorPassword = null),
            ),
          ],
          submitButton: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Masuk',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                  size: ButtonSize.large,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to forgot password
                  },
                  child: Text(
                    'Lupa Password?',
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomWidget: Column(
            children: [
              const SizedBox(height: 8),
              Divider(
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
                    icon: Icons.g_mobiledata,
                    label: 'Google',
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  _SocialButton(
                    icon: Icons.apple,
                    label: 'Apple',
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  _SocialButton(
                    icon: Icons.facebook,
                    label: 'Facebook',
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
                    onTap: () {
                      Navigator.of(context).pushNamed('/register');
                    },
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
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
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
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 24,
          ),
        ),
      ),
    );
  }
}
