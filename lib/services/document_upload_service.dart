import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase.dart';

class DocumentUploadService {
  final SupabaseClient _client = SupabaseService().client;
  static const String bucket = 'document_organisasi';

  /// Pick file dari perangkat
  Future<FilePickerResult?> pickDocument() async {
    try {
      return await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  /// Upload document ke Supabase Storage
  /// Returns public URL atau null jika gagal
  Future<String?> uploadDocument({
    required String filePath,
    required String fileName,
    required String organizationId,
    required String documentType, // 'akta', 'npwp', 'surat'
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${documentType}_${timestamp}.pdf';
      final remotePath = 'org_$organizationId/$uniqueFileName';

      if (kIsWeb) {
        // Web platform
        // Untuk web, gunakan FilePicker yang sudah memberikan bytes
        return null; // Handle separately di screen
      } else {
        // Mobile platform
        final file = File(filePath);
        if (!await file.exists()) {
          throw Exception('File tidak ditemukan: $filePath');
        }

        // Upload file
        await _client.storage
            .from(bucket)
            .upload(
              remotePath,
              file,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );

        // Get public URL
        final publicUrl = _client.storage
            .from(bucket)
            .getPublicUrl(remotePath);

        return publicUrl;
      }
    } catch (e) {
      print('Error uploading document: $e');
      rethrow;
    }
  }

  /// Upload document from bytes (untuk web)
  Future<String?> uploadDocumentFromBytes({
    required Uint8List bytes,
    required String fileName,
    required String organizationId,
    required String documentType,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${documentType}_${timestamp}.pdf';
      final remotePath = 'org_$organizationId/$uniqueFileName';

      await _client.storage
          .from(bucket)
          .uploadBinary(
            remotePath,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final publicUrl = _client.storage
          .from(bucket)
          .getPublicUrl(remotePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading document from bytes: $e');
      rethrow;
    }
  }
}
