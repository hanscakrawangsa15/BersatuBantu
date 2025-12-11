/// File ini menunjukkan integrasi lengkap fitur verifikasi organisasi
/// 
/// FLOW:
/// 1. Splash Screen
///     ↓
/// 2. Role Selection Screen (Personal / Organisasi / Admin)
///     ↓ (klik "Organisasi")
/// 3. Organization Verification Flow
///    a. Owner Data Screen
///    b. Organization Data Screen
///    c. Documents Upload Screen
///    d. Verifying Screen
///    e. Success Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bersatubantu/fitur/verifikasi_organisasi/providers/verification_provider.dart';
import 'package:bersatubantu/fitur/verifikasi_organisasi/screens/verification_flow.dart';

/// Contoh integrasi di main.dart routes:
class AppRoutesExample {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/role-selection': (context) => const RoleSelectionScreenExample(),
      '/verification-org': (context) => ChangeNotifierProvider(
            create: (_) => OrganizationVerificationProvider(),
            child: const OrganizationVerificationFlow(),
          ),
    };
  }
}

/// Contoh kustom dari RoleSelectionScreen yang simplified
class RoleSelectionScreenExample extends StatefulWidget {
  const RoleSelectionScreenExample({super.key});

  @override
  State<RoleSelectionScreenExample> createState() => _RoleSelectionScreenExampleState();
}

class _RoleSelectionScreenExampleState extends State<RoleSelectionScreenExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Role')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigasi ke personal dashboard
                Navigator.of(context).pushNamed('/home');
              },
              child: const Text('Personal'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke verification flow untuk organisasi
                Navigator.of(context).pushNamed('/verification-org');
              },
              child: const Text('Organisasi'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke admin dashboard
                Navigator.of(context).pushNamed('/admin');
              },
              child: const Text('Admin'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contoh menggunakan Provider di widget
class ExampleVerificationWidget extends StatelessWidget {
  const ExampleVerificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrganizationVerificationProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Text('Current Step: ${provider.currentStep}'),
            Text('Owner: ${provider.data.ownerName}'),
            Text('Organization: ${provider.data.orgLegalName}'),
            if (provider.lastMessage != null)
              Text('Message: ${provider.lastMessage}'),
            if (provider.isLoading)
              const CircularProgressIndicator(),
          ],
        );
      },
    );
  }
}

/// Database schema untuk Supabase
/// 
/// CREATE TABLE public.organization_verifications (
///   id uuid NOT NULL DEFAULT gen_random_uuid(),
///   organization_id uuid,
///   owner_id uuid NOT NULL,
///   owner_name text NOT NULL,
///   owner_nik text,
///   owner_address text,
///   org_legal_name text NOT NULL,
///   org_npwp text,
///   org_registration_no text,
///   doc_akta_url text,
///   doc_npwp_url text,
///   doc_other_url text,
///   status text NOT NULL CHECK (status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])),
///   admin_id uuid,
///   admin_notes text,
///   created_at timestamp with time zone DEFAULT now(),
///   reviewed_at timestamp with time zone,
///   CONSTRAINT organization_verifications_pkey PRIMARY KEY (id),
///   CONSTRAINT organization_verifications_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
///   CONSTRAINT organization_verifications_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.profiles(id),
///   CONSTRAINT organization_verifications_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.profiles(id)
/// );
