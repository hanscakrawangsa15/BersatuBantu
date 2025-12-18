import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';
import 'dart:async';
import '../models/verification_model.dart';

class OrganizationVerificationProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  OrganizationVerificationData data = OrganizationVerificationData();
  bool isLoading = false;
  String? lastMessage;
  int currentStep =
      0; // 0: owner, 1: org, 2: documents, 3: verifying, 4: success

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
      case 'ownerEmail':
        data.ownerEmail = value;
        break;
      case 'ownerPhone':
        data.ownerPhone = value;
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
      case 'orgPassword':
        data.orgPassword = value;
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

      // Get URLs from provider - allow anonymous registration
      String aktaUrl = '';
      String npwpUrl = '';
      String otherUrl = '';

      if (data.docAktaPath != null && data.docAktaPath!.isNotEmpty) {
        aktaUrl = data.docAktaPath ?? '';
        print('[Verification] Akta URL: $aktaUrl');
      }

      if (data.docNpwpPath != null && data.docNpwpPath!.isNotEmpty) {
        npwpUrl = data.docNpwpPath ?? '';
        print('[Verification] NPWP URL: $npwpUrl');
      }

      if (data.docOtherPath != null && data.docOtherPath!.isNotEmpty) {
        otherUrl = data.docOtherPath ?? '';
        print('[Verification] Other URL: $otherUrl');
      }

      // Hash password before storing
      print('[Verification] Hashing password...');
      String hashedPassword = '';
      try {
        hashedPassword = BCrypt.hashpw(
          data.orgPassword ?? '',
          BCrypt.gensalt()
        );
        print('[Verification] ✅ Password hashed successfully');
      } catch (e) {
        print('[Verification] ❌ Error hashing password: $e');
        lastMessage = 'Error mengenkripsi password: $e';
        isLoading = false;
        notifyListeners();
        return false;
      }

      // Insert to organization_request table
      print('[Verification] ========== INSERTING TO ORGANIZATION_REQUEST ==========');
      print('[Verification] Data to insert:');
      print('[Verification]   nama_organisasi: ${data.orgLegalName}');
      print('[Verification]   nama_pemilik: ${data.ownerName}');
      print('[Verification]   email_organisasi: ${data.email}');
      print('[Verification]   email_pemilik: ${data.ownerEmail}');
      print('[Verification]   status: pending');

      final insertData = {
        'nama_organisasi': data.orgLegalName ?? '',
        'nama_pemilik': data.ownerName ?? '',
        'email_organisasi': data.email ?? '',
        'email_pemilik': data.ownerEmail ?? '',
        'password_organisasi': hashedPassword,
        'no_telpon_pemilik': data.ownerPhone ?? '',
        'no_telpon_organisasi': data.phone ?? '',
        'akta_berkas': aktaUrl ?? '',
        'npwp_berkas': npwpUrl ?? '',
        'other_berkas': otherUrl ?? '',
        'status': 'pending',
      };

      print('[Verification] Insert payload: $insertData');

      // Add timeout to prevent indefinite hanging
      print('[Verification] Starting insert with 30s timeout...');
      final response = await _supabase
          .from('organization_request')
          .insert(insertData)
          .select('request_id')
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('[Verification] ❌ INSERT TIMEOUT after 30 seconds');
              throw TimeoutException('Database insert timeout');
            },
          );

      print('[Verification] Insert response: $response');

      if (response.isNotEmpty) {
        data.verificationId = response[0]['request_id']?.toString();
        print('[Verification] Request ID stored: ${data.verificationId}');
        
        lastMessage = 'Verifikasi berhasil dikirim! Mohon tunggu persetujuan admin.';
        currentStep = 3;
        isLoading = false;
        notifyListeners();

        print('[Verification] ========== SUBMIT VERIFICATION SUCCESS ==========');
        return true;
      } else {
        lastMessage = 'Gagal menyimpan data verifikasi';
        isLoading = false;
        notifyListeners();
        print('[Verification] ❌ Empty response from insert');
        return false;
      }
    } on TimeoutException catch (e) {
      print('[Verification] ❌ TimeoutException: $e');
      lastMessage = 'Koneksi timeout. Pastikan internet stabil dan coba lagi.';
      isLoading = false;
      notifyListeners();
      return false;
    } on PostgrestException catch (e) {
      print('[Verification] ❌ PostgrestException: ${e.message}');
      print('[Verification] Error code: ${e.code}');
      print('[Verification] Error details: ${e.toString()}');
      
      // Check for common errors
      if (e.code == '42501') {
        lastMessage = 'Akses ditolak. Hubungi admin untuk permission.';
        print('[Verification] 🔒 RLS POLICY BLOCKING INSERT');
      } else if (e.code == '23505') {
        lastMessage = 'Email organisasi sudah terdaftar.';
        print('[Verification] Email UNIQUE constraint violation');
      } else if (e.code == '23502') {
        lastMessage = 'Data tidak lengkap. Pastikan semua field diisi.';
        print('[Verification] NOT NULL constraint violation');
      } else {
        lastMessage = 'Error: ${e.message}';
      }
      
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('[Verification] ❌ Unexpected exception: $e');
      print('[Verification] Exception type: ${e.runtimeType}');
      print('[Verification] Stack trace: ${StackTrace.current}');
      lastMessage = 'Error tak terduga: ${e.toString()}';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> uploadFile(
    String bucket,
    String path,
    String filePath,
  ) async {
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
