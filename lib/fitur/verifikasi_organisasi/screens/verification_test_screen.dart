import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/verification_provider.dart';
import 'verification_flow.dart';

/// Quick Test Screen untuk testing verifikasi organisasi
/// Gunakan ini untuk quick testing tanpa harus login dulu
class VerificationTestScreen extends StatelessWidget {
  const VerificationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test: Verifikasi Organisasi'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pilih cara testing:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _buildTestButton(
              context,
              title: 'Mulai Verifikasi Baru',
              description: 'Mulai dari step 1 (Owner Data)',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const OrganizationVerificationFlow(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildTestButton(
              context,
              title: 'Test Step 2 (Org Data)',
              description: 'Loncat langsung ke step 2',
              onTap: () {
                final provider = OrganizationVerificationProvider();
                provider.data.ownerName = 'John Doe';
                provider.data.ownerNik = '1234567890123456';
                provider.data.ownerAddress = 'Jl. Test No. 123';
                provider.currentStep = 1;
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: provider,
                      child: const OrganizationVerificationFlow(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildTestButton(
              context,
              title: 'Test Step 3 (Upload Doc)',
              description: 'Loncat langsung ke step 3',
              onTap: () {
                final provider = OrganizationVerificationProvider();
                provider.data.ownerName = 'John Doe';
                provider.data.ownerNik = '1234567890123456';
                provider.data.ownerAddress = 'Jl. Test No. 123';
                provider.data.organizationId = 'ORG-001';
                provider.data.orgLegalName = 'PT Test Organisasi';
                provider.data.orgNpwp = '12.345.678.9-012.345';
                provider.data.orgRegistrationNo = 'REG-001';
                provider.currentStep = 2;
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: provider,
                      child: const OrganizationVerificationFlow(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context, {
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width - 48,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF768BBD).withOpacity(0.1),
          border: Border.all(
            color: const Color(0xFF768BBD),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF768BBD),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
