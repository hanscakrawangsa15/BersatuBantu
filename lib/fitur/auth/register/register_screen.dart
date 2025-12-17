import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

// Configure at build time via --dart-define, e.g.:
// flutter run --dart-define=ADMIN_PROFILE_URL=https://example.com/admin/create-profile \ 
//              --dart-define=ADMIN_PROFILE_KEY=topsecret
const String kAdminCreateProfileUrl = String.fromEnvironment('ADMIN_PROFILE_URL', defaultValue: '');
const String kAdminProfileKey = String.fromEnvironment('ADMIN_PROFILE_KEY', defaultValue: '');

class RegisterScreen extends StatefulWidget {
  final String? selectedRole; // optional pre-selected role from RoleSelection
  const RegisterScreen({super.key, this.selectedRole});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  
  // Password validation states
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;

  late final SupabaseClient supabase;

  // Pre-selected role (from RoleSelection or LoginScreen)
  String? _preselectedRole;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    
    supabase = Supabase.instance.client;

    // Read preselected role from constructor or persisted preferences
    if (widget.selectedRole != null) {
      _preselectedRole = widget.selectedRole;
    } else {
      _loadPreselectedRole();
    }

    _passwordController.addListener(_checkPasswordRequirements);
    _confirmPasswordController.addListener(_checkPasswordsMatch);
  }

  Future<void> _loadPreselectedRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('selected_role');
      if (saved != null && saved.trim().isNotEmpty) {
        setState(() {
          _preselectedRole = saved;
        });
        print('[Register] Loaded preselected role: $_preselectedRole');
      }
    } catch (e) {
      print('[Register] Failed to load preselected role: $e');
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordRequirements);
    _confirmPasswordController.removeListener(_checkPasswordsMatch);
    
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    
    super.dispose();
  }

  void _checkPasswordRequirements() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
    _checkPasswordsMatch();
  }

  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch = _passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    if (!value.endsWith('@gmail.com') && !value.endsWith('@yahoo.com')) {
      return 'Email harus menggunakan @gmail.com atau @yahoo.com';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@(gmail|yahoo)\.com$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Username minimal 3 karakter';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (!_hasMinLength) {
      return 'Password minimal 8 karakter';
    }
    if (!_hasUppercase) {
      return 'Password harus memiliki huruf kapital';
    }
    if (!_hasNumber) {
      return 'Password harus memiliki angka';
    }
    if (!_hasSpecialChar) {
      return 'Password harus memiliki karakter spesial';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua field dengan benar'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('[Register] Starting registration for: ${_emailController.text.trim()}');
      
      // Sign up with Supabase Auth
      final AuthResponse response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'full_name': _nameController.text.trim(),
        },
      );

      print('[Register] Auth response user ID: ${response.user?.id}');
      print('[Register] Auth response session: ${response.session != null}');

      if (response.user == null) {
        throw Exception('Gagal membuat akun');
      }

      // Wait a bit for auth to propagate
      await Future.delayed(const Duration(milliseconds: 500));

      // Insert into profiles table with authenticated context
      // No need to store password_hash, Supabase Auth handles it
      try {
        print('[Register] Inserting profile for user: ${response.user!.id}');

        // Try insertion with retries because sometimes the user record in the
        // referenced `users` table may not have propagated yet, causing a
        // foreign-key violation. We'll retry several times with exponential backoff.
        final int maxAttempts = 10;
        int attempt = 0;
        bool inserted = false;
        while (attempt < maxAttempts && !inserted) {
          try {
            attempt += 1;
            await supabase.from('profiles').insert({
              'id': response.user!.id,
              'full_name': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              // Apply preselected role if available
              'role': _preselectedRole,
            });
            inserted = true;
            print('[Register] Profile inserted successfully on attempt $attempt');
            break;
          } catch (e) {
            final msg = e.toString();
            // If foreign key error (user row not present yet) then instead of
            // repeatedly attempting inserts (which will fail until auth.users exists),
            // poll for the profile row created by the trigger on auth.users.
            if (msg.contains('violates foreign key constraint') || msg.contains('is not present in table "users"') || msg.contains('profiles_id_fkey')) {
              print('[Register] FK error detected while inserting profile (attempt $attempt). Polling for profile row instead of re-inserting...');

              // Poll for the profile row created by the DB trigger
              final int pollAttempts = 10;
              final int pollDelayMs = 300; // start small
              bool found = false;
              for (int p = 0; p < pollAttempts; p++) {
                try {
                  final profile = await supabase.from('profiles').select('id').eq('id', response.user!.id).maybeSingle();
                  if (profile != null) {
                    print('[Register] Profile row detected by poll at attempt ${p + 1}');
                    found = true;
                    inserted = true;
                    break;
                  }
                } catch (e) {
                  print('[Register] Polling error: $e');
                }
                await Future.delayed(Duration(milliseconds: pollDelayMs));
              }

              if (found) break; // exit outer while

              // If polling did not find a profile, continue with exponential backoff insert attempts
              final waitMs = 300 * (1 << (attempt - 1)); // exponential backoff
              final cappedWait = waitMs > 3000 ? 3000 : waitMs; // cap at 3s per attempt
              print('[Register] Profile not found after polling. Waiting ${cappedWait}ms and retrying insert...');
              await Future.delayed(Duration(milliseconds: cappedWait));
              continue;
            }

            // For other errors, break and fallback to upsert below
            print('[Register] Non-FK error inserting profile: $e');
            break;
          }
        }


        if (!inserted) {
          print('[Register] Insert attempts exhausted or skipped; trying upsert as fallback');
          try {
            await supabase.from('profiles').upsert({
              'id': response.user!.id,
              'full_name': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              // Apply preselected role if available
              'role': _preselectedRole,
            });
            print('[Register] Profile upserted successfully');
            inserted = true;
          } catch (e) {
            print('[Register] Profile upsert failed: $e');
              // Fallback: if server-side admin endpoint is configured, try to ask
              // the server to create the profile using the SUPABASE_SERVICE_KEY.
              if (kAdminCreateProfileUrl.isNotEmpty && kAdminProfileKey.isNotEmpty) {
                try {
                  final body = convert.jsonEncode({
                    'id': response.user!.id,
                    'full_name': _nameController.text.trim(),
                    'email': _emailController.text.trim(),
                  });

                  final resp = await http.post(Uri.parse(kAdminCreateProfileUrl),
                      headers: {
                        'Content-Type': 'application/json',
                        'x-admin-key': kAdminProfileKey,
                      },
                      body: body).timeout(const Duration(seconds: 10));

                  if (resp.statusCode >= 200 && resp.statusCode < 300) {
                    print('[Register] Server-side profile creation OK: ${resp.body}');
                    inserted = true;
                  } else {
                    print('[Register] Server-side profile creation failed: ${resp.statusCode} ${resp.body}');
                  }
                } catch (err) {
                  print('[Register] Error calling admin create-profile endpoint: $err');
                }
              } else {
                print('[Register] Admin create-profile URL/key not configured; skipping server fallback');
              }
          }
        }

        if (!inserted) {
          // We couldn't create the profile automatically. Inform the user but
          // don't roll back the created Auth user — the account exists.
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Akun dibuat tetapi profil belum berhasil dibuat. Silakan login dan hubungi administrator jika perlu.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 6),
              ),
            );
          }
        }
      } catch (profileError) {
        // This outer catch is defensive — most work is handled above.
        print('[Register] Unexpected profile insertion error: $profileError');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Sign out the user so they need to login
      await supabase.auth.signOut();
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Registrasi gagal';
      
      if (e.message.contains('User already registered')) {
        errorMessage = 'Email sudah terdaftar';
      } else if (e.message.contains('already registered')) {
        errorMessage = 'Email sudah terdaftar';
      } else if (e.message.contains('Invalid email')) {
        errorMessage = 'Format email tidak valid';
      } else if (e.message.contains('Password')) {
        errorMessage = 'Password tidak memenuhi syarat';
      } else {
        errorMessage = 'Registrasi gagal: ${e.message}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Registrasi gagal';
      
      if (e.toString().contains('duplicate key')) {
        errorMessage = 'Email sudah terdaftar';
      } else if (e.toString().contains('violates unique constraint')) {
        errorMessage = 'Email sudah terdaftar';
      } else if (e.toString().contains('new row violates row-level security')) {
        errorMessage = 'Terjadi kesalahan server. Silakan hubungi administrator untuk mengatur RLS policy.';
      } else if (e.toString().contains('relation "profiles" does not exist')) {
        errorMessage = 'Tabel profiles belum dibuat. Hubungi administrator.';
      } else if (e.toString().contains('profiles_role_check') || e.toString().contains('violates check constraint')) {
        errorMessage = 'Role tidak valid untuk tabel profiles. Pastikan kolom `role` berisi nilai yang diperbolehkan atau kosong.';
      } else {
        errorMessage = 'Registrasi gagal: ${e.toString()}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF768BBD),
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _RegisterHeader(),
                      const SizedBox(height: 30),
                      _buildNameField(),
                      const SizedBox(height: 16),
                      _buildEmailField(),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 12),
                      _buildPasswordRequirements(),
                      const SizedBox(height: 16),
                      _buildConfirmPasswordField(),
                      if (_confirmPasswordController.text.isNotEmpty)
                        _buildPasswordMatchIndicator(),
                      const SizedBox(height: 25),
                      _buildRegisterButton(),
                      const SizedBox(height: 20),
                      _buildSignInLink(),
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

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      validator: _validateName,
      style: const TextStyle(
        fontSize: 15,
        fontFamily: 'CircularStd',
        color: Color(0xFF364057),
      ),
      decoration: _buildInputDecoration(
        labelText: 'Username',
        hintText: 'Masukkan nama lengkap Anda',
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      validator: _validateEmail,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(
        fontSize: 15,
        fontFamily: 'CircularStd',
        color: Color(0xFF364057),
      ),
      decoration: _buildInputDecoration(
        labelText: 'Email',
        hintText: 'contoh@gmail.com atau contoh@yahoo.com',
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      validator: _validatePassword,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(
        fontSize: 15,
        fontFamily: 'CircularStd',
        color: Color(0xFF364057),
      ),
      decoration: _buildInputDecoration(
        labelText: 'Password Baru',
        hintText: 'Masukkan password',
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
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password harus memiliki:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontFamily: 'CircularStd',
            ),
          ),
          const SizedBox(height: 8),
          _buildPasswordRequirement('Minimal 8 karakter', _hasMinLength),
          _buildPasswordRequirement('Minimal 1 huruf kapital', _hasUppercase),
          _buildPasswordRequirement('Minimal 1 angka', _hasNumber),
          _buildPasswordRequirement('Minimal 1 karakter spesial (!@#\$%^&*)', _hasSpecialChar),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isMet ? Colors.green : Colors.grey[600],
                fontFamily: 'CircularStd',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      validator: _validateConfirmPassword,
      obscureText: !_isConfirmPasswordVisible,
      style: const TextStyle(
        fontSize: 15,
        fontFamily: 'CircularStd',
        color: Color(0xFF364057),
      ),
      decoration: _buildInputDecoration(
        labelText: 'Konfirmasi Password',
        hintText: 'Masukkan ulang password',
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_confirmPasswordController.text.isNotEmpty)
              Icon(
                _passwordsMatch ? Icons.check_circle : Icons.cancel,
                color: _passwordsMatch ? Colors.green : Colors.red,
                size: 20,
              ),
            const SizedBox(width: 8),
            IconButton(
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
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordMatchIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            _passwordsMatch ? Icons.check_circle : Icons.error,
            color: _passwordsMatch ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _passwordsMatch 
                ? 'Password sudah sama' 
                : 'Password belum sama',
            style: TextStyle(
              fontSize: 12,
              color: _passwordsMatch ? Colors.green : Colors.red,
              fontFamily: 'CircularStd',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
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
                'Daftar',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'CircularStd',
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            fontFamily: 'CircularStd',
          ),
        ),
        GestureDetector(
          onTap: _isLoading ? null : () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: const Text(
            'Masuk',
            style: TextStyle(
              color: Color(0xFF768BBD),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'CircularStd',
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
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
      suffixIcon: suffixIcon,
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Daftar Akun',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF768BBD),
            fontFamily: 'CircularStd',
          ),
        ),
        SizedBox(height: 4),
        Text(
          'di Bersatu Bantu!',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF768BBD),
            fontFamily: 'CircularStd',
          ),
        ),
      ],
    );
  }
}