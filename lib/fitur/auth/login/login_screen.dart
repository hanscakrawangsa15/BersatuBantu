import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bersatubantu/fitur/auth/register/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/fitur/pilihrole/role_selection_screen.dart';
import 'package:bersatubantu/services/debug_auth_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('[Login] Attempting to login with email: ${_emailController.text.trim()}');
      
      // Use Supabase Auth for login
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('[Login] Auth response: ${response.user?.id}');

      if (response.user == null) {
        throw 'Login gagal: User tidak ditemukan';
      }

      // Get user profile from database
      final profileResponse = await supabase
          .from('profiles')
          .select('id, full_name, role, email')
          .eq('id', response.user!.id)
          .maybeSingle();

      print('[Login] Profile response: $profileResponse');

      if (!mounted) return;

      if (profileResponse == null) {
        // Profile not found, create one
        print('[Login] Profile not found, creating new profile');
        try {
          await supabase.from('profiles').insert({
            'id': response.user!.id,
            'email': _emailController.text.trim(),
            'full_name': response.user!.userMetadata?['full_name'] ?? 
                        _emailController.text.trim().split('@')[0],
            'role': null,
          });
          print('[Login] New profile created successfully');
        } catch (e) {
          print('[Login] Error creating profile: $e');
        }
        
        // After creating profile, navigate to role selection
        if (mounted) {
          print('[Login] Navigating to role selection (new profile)');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RoleSelectionScreen(userId: response.user!.id),
            ),
          );
        }
      } else {
        // Profile exists, check if user has selected role
        final userRole = profileResponse['role'];
        print('[Login] User role: "$userRole"');
        print('[Login] User role type: ${userRole.runtimeType}');
        
        // Check if role is null, empty, or 'null' string
        final roleIsEmpty = userRole == null || 
                           userRole.toString().trim().isEmpty ||
                           userRole.toString().toLowerCase() == 'null';
        
        print('[Login] Role is empty: $roleIsEmpty');
        
        if (roleIsEmpty) {
          // Navigate to role selection if role not set
          print('[Login] No role found, navigating to role selection');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Silakan pilih peran Anda'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => RoleSelectionScreen(userId: response.user!.id),
              ),
            );
          }
        } else {
          // Role already set, navigate directly to loading screen
          print('[Login] Role found: $userRole, showing success and navigating to loading screen');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selamat datang kembali, ${profileResponse['full_name']}!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            
            // Navigate to loading screen (import at top: import 'package:bersatubantu/fitur/loading/loading_screen.dart';)
            // For now, using role selection which will redirect to loading
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => RoleSelectionScreen(userId: response.user!.id),
              ),
            );
          }
        }
      }
    } on AuthException catch (e) {
      print('[Login] Auth error: ${e.message}');
      
      if (mounted) {
        String errorMessage = 'Login gagal';
        
        if (e.message.contains('Invalid login credentials')) {
          errorMessage = 'Email atau password salah';
        } else if (e.message.contains('Email not confirmed')) {
          errorMessage = 'Email belum dikonfirmasi. Silakan cek email Anda.';
        } else if (e.message.contains('User not found')) {
          errorMessage = 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
        } else {
          errorMessage = 'Email atau password salah';
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
      print('[Login] Error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login gagal: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Debug Button (Hidden in top right)
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.bug_report, size: 20),
                          color: Colors.grey[400],
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DebugAuthScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Header
                      const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF768BBD),
                          fontFamily: 'CircularStd',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'ke Bersatu Bantu!',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF768BBD),
                          fontFamily: 'CircularStd',
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'CircularStd',
                          color: Color(0xFF364057),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Masukkan email Anda',
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
                        ),
                      ),
                      const SizedBox(height: 16),
                      
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
                          labelText: 'Password',
                          hintText: 'Masukkan password',
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
                      const SizedBox(height: 12),
                      
                      // Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFF768BBD),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ingat Saya',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  fontFamily: 'CircularStd',
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: Implement forgot password
                            },
                            child: const Text(
                              'Lupa Password?',
                              style: TextStyle(
                                color: Color(0xFF768BBD),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'CircularStd',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
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
                                  'Masuk',
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
                      const SizedBox(height: 20),
                      
                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun? ',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontFamily: 'CircularStd',
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading ? null : () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                color: Color(0xFF768BBD),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'CircularStd',
                              ),
                            ),
                          ),
                        ],
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
}