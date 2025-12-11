import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/verification_model.dart';

class OrganizationVerificationProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  OrganizationVerificationData data = OrganizationVerificationData();
  bool isLoading = false;
  String? lastMessage;
  int currentStep = 0; // 0: owner, 1: org, 2: documents, 3: verifying, 4: success

  void setField(String fieldName, String value) {
    switch (fieldName) {
      case 'ownerName':
        data.ownerName = value;
        break;
      case 'ownerNik':
        data.ownerNik = value;
        break;
      case 'ownerAddress':
        data.ownerAddress = value;
        break;
      case 'organizationId':
        data.organizationId = value;
        break;
      case 'orgLegalName':
        data.orgLegalName = value;
        break;
      case 'orgNpwp':
        data.orgNpwp = value;
        break;
      case 'orgRegistrationNo':
        data.orgRegistrationNo = value;
        break;
      case 'email':
        data.email = value;
        break;
    }
    notifyListeners();
  }

  void setDocumentPath(String docType, String path) {
    switch (docType) {
      case 'akta':
        data.docAktaPath = path;
        break;
      case 'npwp':
        data.docNpwpPath = path;
        break;
      case 'other':
        data.docOtherPath = path;
        break;
    }
    notifyListeners();
  }

  void nextStep() {
    if (currentStep < 4) {
      currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }

  Future<bool> submitVerification() async {
    try {
      isLoading = true;
      notifyListeners();

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        lastMessage = 'User tidak ditemukan';
        isLoading = false;
        notifyListeners();
        return false;
      }

      // Upload dokumen ke storage
      String? aktaUrl;
      String? npwpUrl;
      String? otherUrl;

      if (data.docAktaPath != null && data.docAktaPath!.isNotEmpty) {
        try {
          // Simulasi upload ke storage Supabase
          // aktaUrl = await uploadFile('documents', 'akta_${DateTime.now().millisecondsSinceEpoch}', data.docAktaPath!);
          aktaUrl = 'uploaded_akta_${DateTime.now().millisecondsSinceEpoch}';
        } catch (e) {
          lastMessage = 'Gagal upload dokumen Akta: $e';
          isLoading = false;
          notifyListeners();
          return false;
        }
      }

      if (data.docNpwpPath != null && data.docNpwpPath!.isNotEmpty) {
        try {
          npwpUrl = 'uploaded_npwp_${DateTime.now().millisecondsSinceEpoch}';
        } catch (e) {
          lastMessage = 'Gagal upload dokumen NPWP: $e';
          isLoading = false;
          notifyListeners();
          return false;
        }
      }

      if (data.docOtherPath != null && data.docOtherPath!.isNotEmpty) {
        try {
          otherUrl = 'uploaded_other_${DateTime.now().millisecondsSinceEpoch}';
        } catch (e) {
          lastMessage = 'Gagal upload dokumen lainnya: $e';
          isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Buat record di tabel organization_verifications
      final response = await _supabase.from('organization_verifications').insert({
        'owner_id': userId,
        'owner_name': data.ownerName,
        'owner_nik': data.ownerNik,
        'owner_address': data.ownerAddress,
        'org_legal_name': data.orgLegalName,
        'org_npwp': data.orgNpwp,
        'org_registration_no': data.orgRegistrationNo,
        'email': data.email,
        'doc_akta_url': aktaUrl,
        'doc_npwp_url': npwpUrl,
        'doc_other_url': otherUrl,
        'status': 'pending',
      }).select();

      if (response.isNotEmpty) {
        lastMessage = 'Verifikasi berhasil dikirim!';
        currentStep = 3; // Pindah ke step verifying
        notifyListeners();

        // Simulasi verifikasi setelah 3 detik
        await Future.delayed(const Duration(seconds: 3));
        currentStep = 4; // Pindah ke step success
        notifyListeners();

        return true;
      } else {
        lastMessage = 'Gagal menyimpan data verifikasi';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      lastMessage = 'Error: $e';
      isLoading = false;
      notifyListeners();
      return false;
    } finally {
      if (currentStep != 4) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<String?> uploadFile(String bucket, String path, String filePath) async {
    try {
      // TODO: Implementasi upload file ke Supabase Storage
      // final file = File(filePath);
      // await _supabase.storage.from(bucket).upload(path, file);
      // return _supabase.storage.from(bucket).getPublicUrl(path);
      return path;
    } catch (e) {
      rethrow;
    }
  }
}
