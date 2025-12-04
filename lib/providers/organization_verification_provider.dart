import 'package:flutter/material.dart';
import '../services/organization_verification_service.dart';
import '../services/supabase.dart';

class OrganizationVerificationProvider extends ChangeNotifier {
  final OrganizationVerificationService _service = OrganizationVerificationService();

  bool isLoading = false;
  String? lastMessage;

  // Form fields (from ERD)
  String ownerId = '';
  String ownerName = '';
  String ownerNik = '';
  String ownerAddress = '';
  String orgLegalName = '';
  String orgNpwp = '';
  String orgRegistrationNo = '';
  int organizationId = 0;

  // Proof files: {fileType: {filePath, fileBytes}}
  final Map<String, Map<String, String?>> proofFiles = {
    'akta': {'path': null, 'bytes': null}, // doc_akta_url
    'npwp': {'path': null, 'bytes': null}, // doc_npwp_url
    'other': {'path': null, 'bytes': null}, // doc_other_url
  };

  void setField(String key, String value) {
    switch (key) {
      case 'ownerId':
        ownerId = value;
        break;
      case 'ownerName':
        ownerName = value;
        break;
      case 'ownerNik':
        ownerNik = value;
        break;
      case 'ownerAddress':
        ownerAddress = value;
        break;
      case 'orgLegalName':
        orgLegalName = value;
        break;
      case 'orgNpwp':
        orgNpwp = value;
        break;
      case 'orgRegistrationNo':
        orgRegistrationNo = value;
        break;
      case 'organizationId':
        organizationId = int.tryParse(value) ?? 0;
        break;
    }
    notifyListeners();
  }

  void setProofFile(String fileType, String? path, String? bytes) {
    proofFiles[fileType] = {'path': path, 'bytes': bytes};
    notifyListeners();
  }

  Future<bool> submitRequest() async {
    isLoading = true;
    notifyListeners();
    try {
      final user = SupabaseService().auth.currentUser;
      final finalOwnerId = ownerId.isNotEmpty ? ownerId : user?.id;

      if (finalOwnerId == null) {
        lastMessage = 'User not authenticated';
        isLoading = false;
        notifyListeners();
        return false;
      }

      // Upload proof files
      final docAktaUrl = await _uploadIfExists('akta', finalOwnerId);
      final docNpwpUrl = await _uploadIfExists('npwp', finalOwnerId);
      final docOtherUrl = await _uploadIfExists('other', finalOwnerId);

      // Build payload matching ERD
      final payload = {
        'organization_id': organizationId,
        'owner_id': finalOwnerId,
        'owner_name': ownerName,
        'owner_nik': ownerNik,
        'owner_address': ownerAddress,
        'org_legal_name': orgLegalName,
        'org_npwp': orgNpwp,
        'org_registration_no': orgRegistrationNo,
        'doc_akta_url': docAktaUrl,
        'doc_npwp_url': docNpwpUrl,
        'doc_other_url': docOtherUrl,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _service.createVerificationRequest(payload);
      lastMessage = 'Request submitted successfully';
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      lastMessage = 'Failed to submit: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> _uploadIfExists(String fileType, String ownerId) async {
    final file = proofFiles[fileType];
    if (file == null || (file['path'] == null && file['bytes'] == null)) {
      return null;
    }
    try {
      return await _service.uploadProofFile(
        filePath: file['path'] ?? '',
        fileBytes: file['bytes'],
        ownerId: ownerId,
        fileType: fileType,
      );
    } catch (e) {
      lastMessage = 'Failed to upload $fileType: $e';
      return null;
    }
  }
}
