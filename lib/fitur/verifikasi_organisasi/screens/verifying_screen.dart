import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/verification_provider.dart';

class VerifyingScreen extends StatefulWidget {
  const VerifyingScreen({super.key});

  @override
  State<VerifyingScreen> createState() => _VerifyingScreenState();
}

class _VerifyingScreenState extends State<VerifyingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Start polling untuk cek approval dari admin
    _startPollingForApproval();
  }

  void _startPollingForApproval() {
    Future.microtask(() async {
      final provider = context.read<OrganizationVerificationProvider>();
      final orgEmail = provider.data.email;

      if (orgEmail == null || orgEmail.isEmpty) {
        print('[Verifying] No email found in provider data');
        return;
      }

      // Start polling by email
      _pollForApproval(orgEmail);
    });
  }

  Future<void> _pollForApproval(String orgEmail) async {
    // Poll setiap 2 detik untuk cek status approval
    while (mounted) {
      try {
        final response = await supabase
            .from('organization_request')
            .select('status')
            .eq('email_organisasi', orgEmail)
            .maybeSingle();

        if (response == null) {
          print('[Verifying] No organization_request found for: $orgEmail');
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        final status = response['status'];
        print('[Verifying] Current status: $status');

        if (mounted) {
          if (status == 'approve') {
            // Admin approved! Transisi ke success screen
            print('[Verifying] ✅ Approved! Moving to success screen');
            final provider = context.read<OrganizationVerificationProvider>();
            provider.currentStep = 4;
            // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
            provider.notifyListeners();
            break;
          } else if (status == 'reject') {
            // Admin rejected, show error
            print('[Verifying] ❌ Rejected');
            _showRejectionDialog(orgEmail);
            break;
          }
        }

        // Wait 2 seconds sebelum polling lagi
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        print('[Verifying] Error polling approval status: $e');
        // Continue polling bahkan kalau ada error
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  void _showRejectionDialog(String organizationId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Pengajuan Ditolak'),
        content: const Text(
          'Maaf, pengajuan verifikasi organisasi Anda telah ditolak oleh admin. Silakan hubungi admin untuk informasi lebih lanjut.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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
            colors: [Color(0xFF768BBD), Color(0xFF768BBD)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated hero image
              ScaleTransition(
                scale: Tween(begin: 0.8, end: 1.2).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(120),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Try to load asset image
                      Image.asset(
                        'assets/bersatubantu.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback icon
                          return Icon(
                            Icons.cloud_upload_outlined,
                            size: 80,
                            color: Colors.white.withOpacity(0.8),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Title
              const Text(
                'Berkas-Berkas mu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Sedang di-Verifikasi!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Progress bar
              SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
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
