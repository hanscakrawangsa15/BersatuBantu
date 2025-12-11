import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/verification_provider.dart';

class VerifyingScreen extends StatefulWidget {
  const VerifyingScreen({super.key});

  @override
  State<VerifyingScreen> createState() => _VerifyingScreenState();
}

class _VerifyingScreenState extends State<VerifyingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Auto transition ke success setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.read<OrganizationVerificationProvider>().nextStep();
      }
    });
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
            colors: [
              Color(0xFF768BBD),
              Color(0xFF768BBD),
            ],
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
