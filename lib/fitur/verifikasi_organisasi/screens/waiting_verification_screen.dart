import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/fitur/auth/login/organization_login_screen.dart';

class WaitingVerificationScreen extends StatefulWidget {
  final String organizationId;
  final String organizationName;
  final String organizationEmail;

  const WaitingVerificationScreen({
    super.key,
    required this.organizationId,
    required this.organizationName,
    required this.organizationEmail,
  });

  @override
  State<WaitingVerificationScreen> createState() =>
      _WaitingVerificationScreenState();
}

class _WaitingVerificationScreenState extends State<WaitingVerificationScreen> {
  late Future<String> _verificationStatus;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _verificationStatus = _checkVerificationStatus();
    // Check status every 3 seconds
    _startStatusCheck();
  }

  Future<String> _checkVerificationStatus() async {
    try {
      final response = await supabase
          .from('organization_request')
          .select('status')
          .eq('email_organisasi', widget.organizationEmail)
          .maybeSingle();

      if (response == null) {
        return 'not_found';
      }

      final status = response['status'] as String?;
      print('[Waiting] Status: $status');

      if (status == 'approve') {
        return 'approved';
      } else if (status == 'reject') {
        return 'rejected';
      }

      return 'pending';
    } catch (e) {
      print('[Waiting] Error: $e');
      return 'error';
    }
  }

  void _startStatusCheck() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _verificationStatus = _checkVerificationStatus();
        });
        _startStatusCheck();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<String>(
        future: _verificationStatus,
        builder: (context, snapshot) {
          // If approved, navigate to login screen
          if (snapshot.hasData && snapshot.data == 'approved') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const OrganizationLoginScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            });
          }

          // If rejected, show error
          if (snapshot.hasData && snapshot.data == 'rejected') {
            return _buildRejectedScreen();
          }

          // Default: waiting verification
          return _buildWaitingScreen();
        },
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF768BBD).withOpacity(0.1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.hourglass_empty,
                    size: 50,
                    color: Color(0xFF768BBD),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Menunggu Verifikasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF768BBD),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Organisasi ${widget.organizationName} Anda sedang menunggu verifikasi dari admin.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Status Verifikasi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Admin kami sedang melakukan review terhadap dokumen yang Anda upload. Proses verifikasi biasanya membutuhkan waktu 1-3 hari kerja.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF768BBD)),
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Halaman ini akan otomatis refresh',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRejectedScreen() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.1),
                ),
                child: const Center(
                  child: Icon(Icons.close, size: 50, color: Colors.red),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Verifikasi Ditolak',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Organisasi ${widget.organizationName} Anda tidak lolos verifikasi.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[600], size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Silakan Coba Lagi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Mohon periksa kembali dokumen Anda dan pastikan semua persyaratan telah terpenuhi. Anda dapat mencoba mendaftar ulang dengan dokumen yang lebih lengkap.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const OrganizationLoginScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(-1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
