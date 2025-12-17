import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/fitur/verifikasi_organisasi/screens/verification_flow.dart';
import 'package:bersatubantu/fitur/verifikasi_organisasi/screens/waiting_verification_screen.dart';

class OrganizationLoginScreen extends StatefulWidget {
  const OrganizationLoginScreen({super.key});

  @override
  State<OrganizationLoginScreen> createState() => _OrganizationLoginScreenState();
}

class _OrganizationLoginScreenState extends State<OrganizationLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Email dan password harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // First, get the organization from organizations table using email
      final orgResponse = await supabase
          .from('organizations')
          .select('id, name, email')
          .eq('email', _emailController.text)
          .maybeSingle();

      if (orgResponse == null) {
        if (mounted) {
          _showErrorDialog('Organisasi tidak ditemukan. Silakan daftar terlebih dahulu.');
        }
        return;
      }

      final orgId = orgResponse['id'].toString();
      final orgName = orgResponse['name'] as String?;

      // Then, check verification status in organization_verifications table
      final verificationResponse = await supabase
          .from('organization_verifications')
          .select('status')
          .eq('organization_id', orgId)
          .maybeSingle();

      if (verificationResponse == null) {
        if (mounted) {
          _showErrorDialog('Verifikasi organisasi tidak ditemukan. Silakan selesaikan proses pendaftaran.');
        }
        return;
      }

      final status = verificationResponse['status'] as String?;

      // Check if organization is pending verification
      if (status == 'pending') {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  WaitingVerificationScreen(
                organizationId: orgId,
                organizationName: orgName ?? 'Organisasi',
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(
                    position: offsetAnimation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
        return;
      }

      // Check if organization is rejected
      if (status == 'rejected') {
        if (mounted) {
          _showErrorDialog(
            'Organisasi Anda ditolak oleh admin.\n\n'
            'Silakan hubungi admin untuk informasi lebih lanjut atau coba daftar ulang dengan dokumen yang lebih lengkap.',
          );
        }
        return;
      }

      // Check if organization is approved
      if (status != 'approved') {
        if (mounted) {
          _showErrorDialog(
            'Organisasi Anda belum diverifikasi oleh admin.\n'
            'Status: $status\n\n'
            'Silakan tunggu proses verifikasi selesai.',
          );
        }
        return;
      }

      // Organization is approved, allow login
      // TODO: Create actual user in auth if not exists, or link to existing user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Selamat datang $orgName!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home/dashboard
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        _showErrorDialog('Database error: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gagal Login'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF768BBD),
      body: SafeArea(
        child: Stack(
          children: [
            // Background text
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    'Through Community',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white30,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Many People Help,\nMany People Saved',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white30,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Main form card
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                          );
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF768BBD),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Header
                      const Text(
                        'Hi! Good People',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF768BBD),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Email field
                      const Text(
                        'E-Mail Organisasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email organisasi Anda',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      // Password field
                      const Text(
                        'Passwords Organisasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF768BBD),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Remember me & Forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: false,
                                onChanged: (_) {},
                                activeColor: const Color(0xFF768BBD),
                              ),
                              const Text(
                                'Ingat Saya',
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Lupa Password?',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF768BBD),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF768BBD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () {
                                  _handleLogin();
                                },
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Register link
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Belum daftarkan Organisasimu? ',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            children: [
                              TextSpan(
                                text: 'Daftar',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF768BBD),
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Navigate to verification flow
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const OrganizationVerificationFlow(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
