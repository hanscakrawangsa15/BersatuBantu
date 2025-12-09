import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password harus mengandung huruf besar';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password harus mengandung huruf kecil';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung angka';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('[ResetPassword] Attempting to update password');
      
      // Update password
      final response = await supabase.auth.updateUser(
        UserAttributes(
          password: _passwordController.text,
        ),
      );

      print('[ResetPassword] Password updated successfully');

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diubah! Silakan login dengan password baru Anda.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate back to login
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } on AuthException catch (e) {
      print('[ResetPassword] Auth error: ${e.message}');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        String errorMessage = 'Gagal mengubah password';
        
        if (e.message.contains('session')) {
          errorMessage = 'Link reset password sudah kadaluarsa. Silakan minta link baru.';
        } else {
          errorMessage = e.message;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('[ResetPassword] Error: $e');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF768BBD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 35),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF768BBD).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_open_rounded,
                          size: 50,
                          color: Color(0xFF768BBD),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Header
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF768BBD),
                          fontFamily: 'CircularStd',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Masukkan password baru Anda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'CircularStd',
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        validator: _validatePassword,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'CircularStd',
                          color: Color(0xFF364057),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Password Baru',
                          hintText: 'Masukkan password baru',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontFamily: 'CircularStd',
                          ),
                          labelStyle: const TextStyle(
                            color: Color(0xFF768BBD),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CircularStd',
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F6FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF768BBD),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: const Color(0xFF768BBD),
                              size: 22,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        validator: _validateConfirmPassword,
                        obscureText: !_isConfirmPasswordVisible,
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'CircularStd',
                          color: Color(0xFF364057),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password',
                          hintText: 'Masukkan ulang password',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontFamily: 'CircularStd',
                          ),
                          labelStyle: const TextStyle(
                            color: Color(0xFF768BBD),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CircularStd',
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F6FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF768BBD),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: const Color(0xFF768BBD),
                              size: 22,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Password Requirements
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password harus mengandung:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                                fontFamily: 'CircularStd',
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildRequirement('Minimal 8 karakter'),
                            _buildRequirement('Huruf besar (A-Z)'),
                            _buildRequirement('Huruf kecil (a-z)'),
                            _buildRequirement('Angka (0-9)'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      
                      // Reset Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF768BBD),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[400],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Reset Password',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'CircularStd',
                                    letterSpacing: 0.5,
                                  ),
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
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'CircularStd',
            ),
          ),
        ],
      ),
    );
  }
}