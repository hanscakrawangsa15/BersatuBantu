import 'dart:convert' show base64Decode;
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase.dart';

class OrganizationVerificationService {
  final SupabaseClient _client = SupabaseService().client;
  static const String bucket = 'organization-proofs';

  /// Upload proof file to Supabase Storage
  /// For mobile: use File path
  /// For web: encode bytes as base64
  Future<String> uploadProofFile({
    required String filePath,
    required String? fileBytes, // base64 for web, null for mobile
    required String ownerId,
    required String fileType, // 'akta', 'npwp', 'other'
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${fileType}_${timestamp}.pdf';
      final remotePath = '$ownerId/$filename';

      if (kIsWeb && fileBytes != null) {
        // Web: decode base64 and upload
        final bytes = base64Decode(fileBytes);
        await _client.storage.from(bucket).uploadBinary(remotePath, bytes);
      } else if (!kIsWeb) {
        // Mobile: use file path
        final file = File(filePath);
        await _client.storage.from(bucket).upload(remotePath, file);
      }

      final url = _client.storage.from(bucket).getPublicUrl(remotePath);
      return url;
    } catch (e) {
      rethrow;
    }
  }

  /// Create organization verification request matching ERD schema
  Future<void> createVerificationRequest(Map<String, dynamic> data) async {
    try {
      await _client.from('organization_verifications').insert(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch all pending verification requests
  Future<List<Map<String, dynamic>>> fetchPendingRequests() async {
    try {
      final response = await _client
          .from('organization_verifications')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update verification status (approve/reject)
  Future<void> updateVerificationStatus({
    required int id,
    required String status, // 'approved' or 'rejected'
    String? adminId,
    String? adminNotes,
  }) async {
    try {
      await _client
          .from('organization_verifications')
          .update({
            'status': status,
            'admin_id': adminId,
            'admin_notes': adminNotes,
            'reviewed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}