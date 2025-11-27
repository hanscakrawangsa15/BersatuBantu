import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/form_layout.dart';
import '../../../core/widgets/app-button.dart';
import '../../../core/widgets/app-text-field.dart';
import '../../../core/widgets/app_dialog.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;

  String? _errorName;
  String? _errorEmail;
  String? _errorPassword;
  String? _errorConfirmPassword;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _errorName = _nameController.text.isEmpty
          ? 'Nama tidak boleh kosong'
          : _nameController.text.length < 3
              ? 'Nama minimal 3 karakter'
              : null;

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

      _errorConfirmPassword =
          _confirmPasswordController.text.isEmpty
              ? 'Konfirmasi password tidak boleh kosong'
              : _confirmPasswordController.text !=
                      _passwordController.text
                  ? 'Password tidak cocok'
                  : null;
    });

    if (!_agreedToTerms) {
      AppSnackBar.show(
        context,
        message: 'Silakan setujui syarat dan ketentuan',
        type: SnackBarType.warning,
      );
      return false;
    }

    return _errorName == null &&
        _errorEmail == null &&
        _errorPassword == null &&
        _errorConfirmPassword == null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _handleRegister() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      // Simulasi register (replace dengan actual Supabase call)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Pendaftaran berhasil! Silakan login.',
          type: SnackBarType.success,
        );

        // Navigate to login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Gagal mendaftar: ${e.toString()}',
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
      title: 'Daftar',
      bodyPadding: const EdgeInsets.all(16),
      body: SingleChildScrollView(
        child: FormLayout(
          title: 'Buat Akun Baru',
          subtitle: 'Bergabunglah dengan BersatuBantu',
          fields: [
            AppTextField(
              label: 'Nama Lengkap',
              hint: 'Masukkan nama Anda',
              controller: _nameController,
              isRequired: true,
              errorText: _errorName,
              prefixIcon: const Icon(Icons.person_outline),
              onChanged: (_) => setState(() => _errorName = null),
            ),
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
              hint: 'Masukkan password',
              controller: _passwordController,
              isPassword: true,
              isRequired: true,
              errorText: _errorPassword,
              onChanged: (_) => setState(() => _errorPassword = null),
            ),
            AppTextField(
              label: 'Konfirmasi Password',
              hint: 'Ketik ulang password Anda',
              controller: _confirmPasswordController,
              isPassword: true,
              isRequired: true,
              errorText: _errorConfirmPassword,
              onChanged: (_) =>
                  setState(() => _errorConfirmPassword = null),
            ),
          ],
          submitButton: Column(
            children: [
              // Terms Agreement
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() => _agreedToTerms = value ?? false);
                      },
                      activeColor: AppColors.primaryBlue,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Saya setuju dengan ',
                              style: AppTextStyle.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextSpan(
                              text: 'Syarat & Ketentuan',
                              style: AppTextStyle.bodySmall.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Register Button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Daftar',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                  size: ButtonSize.large,
                ),
              ),
            ],
          ),
          bottomWidget: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Masuk',
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
