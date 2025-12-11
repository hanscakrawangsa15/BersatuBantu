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
      case 'phone':
        data.phone = value;
        break;
      case 'city':
        data.city = value;
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

      print('[Verification] ========== START SUBMIT VERIFICATION ==========');

      final userId = _supabase.auth.currentUser?.id;
      print('[Verification] User ID: $userId');
      
      if (userId == null) {
        lastMessage = 'User tidak ditemukan';
        isLoading = false;
        notifyListeners();
        print('[Verification] ❌ User ID is null');
        return false;
      }

      // Verify that at least akta and npwp are uploaded
      if ((data.docAktaPath?.isEmpty ?? true) || (data.docNpwpPath?.isEmpty ?? true)) {
        lastMessage = 'Akta dan NPWP harus di-upload';
        isLoading = false;
        notifyListeners();
        print('[Verification] ❌ Missing required documents');
        return false;
      }

      // Upload dokumen ke storage
      String? aktaUrl;
      String? npwpUrl;
      String? otherUrl;

      if (data.docAktaPath != null && data.docAktaPath!.isNotEmpty) {
        // docAktaPath sekarang sudah berisi URL dari Supabase Storage
        aktaUrl = data.docAktaPath;
        print('[Verification] Akta URL: $aktaUrl');
      }

      if (data.docNpwpPath != null && data.docNpwpPath!.isNotEmpty) {
        // docNpwpPath sekarang sudah berisi URL dari Supabase Storage
        npwpUrl = data.docNpwpPath;
        print('[Verification] NPWP URL: $npwpUrl');
      }

      if (data.docOtherPath != null && data.docOtherPath!.isNotEmpty) {
        // docOtherPath sekarang sudah berisi URL dari Supabase Storage
        otherUrl = data.docOtherPath;
        print('[Verification] Other URL: $otherUrl');
      }

      // Buat record di tabel organization_verifications
      print('[Verification] Inserting verification record...');
      print('[Verification] Data to insert:');
      print('[Verification]   owner_name: ${data.ownerName}');
      print('[Verification]   org_legal_name: ${data.orgLegalName}');
      print('[Verification]   status: pending');

      final response = await _supabase.from('organization_verifications').insert({
        'owner_id': userId,
        'owner_name': data.ownerName,
        'owner_nik': data.ownerNik,
        'owner_address': data.ownerAddress,
        'org_legal_name': data.orgLegalName,
        'org_npwp': data.orgNpwp,
        'org_registration_no': data.orgRegistrationNo,
        'email': data.email,
        'phone': data.phone ?? '',
        'address': data.ownerAddress ?? '',
        'city': data.city ?? '',
        'doc_akta_url': aktaUrl,
        'doc_npwp_url': npwpUrl,
        'doc_other_url': otherUrl,
        'status': 'pending',
      }).select();

      print('[Verification] Insert response: $response');

      if (response.isNotEmpty) {
        // Store the organization ID from the response
        data.organizationId = response[0]['id'].toString();
        lastMessage = 'Verifikasi berhasil dikirim! Mohon tunggu persetujuan admin.';
        currentStep = 3; // Stay di step verifying, jangan auto transition
        notifyListeners();

        print('[Verification] ✅ Verification submitted successfully!');
        print('[Verification] Organization ID: ${data.organizationId}');
        print('[Verification] ========== SUBMIT VERIFICATION SUCCESS ==========');

        return true;
      } else {
        lastMessage = 'Gagal menyimpan data verifikasi';
        isLoading = false;
        notifyListeners();
        print('[Verification] ❌ Empty response from insert');
        return false;
      }
    } catch (e) {
      lastMessage = 'Error: $e';
      isLoading = false;
      notifyListeners();
      print('[Verification] ❌ Exception: $e');
      print('[Verification] Exception type: ${e.runtimeType}');
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
