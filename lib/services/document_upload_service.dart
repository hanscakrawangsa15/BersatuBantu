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

  /// Upload document from bytes (untuk web dan mobile)
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

      print('[DocumentUpload] ========== START UPLOAD ==========');
      print('[DocumentUpload] Bucket: $bucket');
      print('[DocumentUpload] Remote path: $remotePath');
      print('[DocumentUpload] File size: ${bytes.length} bytes');
      print('[DocumentUpload] Organization ID: $organizationId');
      print('[DocumentUpload] Document type: $documentType');
      print('[DocumentUpload] File name: $fileName');

      // Check if bucket exists
      print('[DocumentUpload] Checking bucket...');
      try {
        await _client.storage.from(bucket).list(path: '/');
        print('[DocumentUpload] ✅ Bucket exists and is accessible');
      } catch (e) {
        print('[DocumentUpload] ❌ Bucket error: $e');
        throw Exception(
          'Bucket "$bucket" tidak ditemukan atau tidak bisa diakses.\n'
          'Silakan create bucket "$bucket" di Supabase Storage.\n'
          'Error: $e'
        );
      }

      // Upload file
      print('[DocumentUpload] Starting uploadBinary...');
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

      print('[DocumentUpload] ✅ uploadBinary completed successfully');

      // Get public URL
      print('[DocumentUpload] Getting public URL...');
      final publicUrl = _client.storage
          .from(bucket)
          .getPublicUrl(remotePath);

      print('[DocumentUpload] ✅ Public URL obtained: $publicUrl');
      print('[DocumentUpload] ========== UPLOAD SUCCESS ==========');

      return publicUrl;
    } on StorageException catch (e) {
      print('[DocumentUpload] ❌ StorageException: ${e.message}');
      print('[DocumentUpload] Status code: ${e.statusCode}');
      
      String errorMsg = 'Gagal upload dokumen';
      if (e.statusCode == '404') {
        errorMsg = 'Bucket "document_organisasi" tidak ditemukan.\n'
            'Silakan create bucket di Supabase Storage terlebih dahulu.';
      } else if (e.statusCode == '401' || e.statusCode == '403') {
        errorMsg = 'Tidak ada izin untuk upload dokumen.\n'
            'Pastikan policies sudah di-set dengan benar.';
      }
      
      throw Exception(errorMsg);
    } catch (e) {
      print('[DocumentUpload] ❌ Error uploading document from bytes: $e');
      print('[DocumentUpload] Exception type: ${e.runtimeType}');
      throw Exception('Error upload: ${e.toString()}');
    }
  }
}
