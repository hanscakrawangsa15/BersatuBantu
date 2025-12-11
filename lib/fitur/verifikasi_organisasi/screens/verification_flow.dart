import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/verification_provider.dart';
import 'owner_data_screen.dart';
import 'organization_data_screen.dart';
import 'documents_upload_screen.dart';
import 'verifying_screen.dart';
import 'success_screen.dart';

class OrganizationVerificationFlow extends StatelessWidget {
  const OrganizationVerificationFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrganizationVerificationProvider(),
      child: Consumer<OrganizationVerificationProvider>(
        builder: (context, provider, _) {
          return PopScope(
            canPop: provider.currentStep == 0,
            onPopInvoked: (didPop) {
              if (!didPop && provider.currentStep > 0) {
                provider.previousStep();
              }
            },
            child: _buildCurrentScreen(provider.currentStep),
          );
        },
      ),
    );
  }

  Widget _buildCurrentScreen(int step) {
    switch (step) {
      case 0:
        return const OwnerDataScreen();
      case 1:
        return const OrganizationDataScreen();
      case 2:
        return const DocumentsUploadScreen();
      case 3:
        return const VerifyingScreen();
      case 4:
        return const SuccessScreen();
      default:
        return const OwnerDataScreen();
    }
  }
}
