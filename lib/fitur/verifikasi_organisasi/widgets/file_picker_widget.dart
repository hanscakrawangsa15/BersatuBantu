import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FilePickerUtil {
  /// Pick PDF file dengan better error handling
  static Future<FilePickerResult?> pickPdfFile() async {
    try {
      print('[FilePickerUtil] Starting PDF file picker...');
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
        allowMultiple: false,
        lockParentWindow: false,
      );

      if (result == null) {
        print('[FilePickerUtil] User cancelled file picker');
        return null;
      }

      if (result.files.isEmpty) {
        print('[FilePickerUtil] No files selected');
        return null;
      }

      final file = result.files.first;
      print('[FilePickerUtil] File picked: ${file.name}');
      print('[FilePickerUtil] File size: ${file.size} bytes');
      // Note: file.path is null on web, only use bytes
      if (!kIsWeb && file.path != null) {
        print('[FilePickerUtil] File path: ${file.path}');
      }
      print('[FilePickerUtil] Has bytes: ${file.bytes != null}');

      // Validate file
      if (file.bytes == null || file.bytes!.isEmpty) {
        throw Exception('File bytes tidak dapat dibaca');
      }

      // Validate extension
      if (!file.name.toLowerCase().endsWith('.pdf')) {
        throw Exception('File harus berformat PDF');
      }

      // Validate size (max 5MB)
      if (file.bytes!.length > 5 * 1024 * 1024) {
        throw Exception('Ukuran file terlalu besar (max 5MB)');
      }

      print('[FilePickerUtil] File validation passed');
      return result;
    } catch (e) {
      print('[FilePickerUtil] Error: $e');
      rethrow;
    }
  }

  /// Validate PDF file
  static bool validatePdfFile(PlatformFile file) {
    if (file.bytes == null || file.bytes!.isEmpty) {
      return false;
    }
    if (!file.name.toLowerCase().endsWith('.pdf')) {
      return false;
    }
    if (file.bytes!.length > 5 * 1024 * 1024) {
      return false;
    }
    return true;
  }

  /// Get error message
  static String getErrorMessage(Exception e) {
    final message = e.toString();
    if (message.contains('Permission')) {
      return 'Izin akses file ditolak. Mohon berikan izin di pengaturan.';
    } else if (message.contains('not found')) {
      return 'File tidak ditemukan.';
    } else if (message.contains('too large')) {
      return 'Ukuran file terlalu besar (max 5MB).';
    }
    return message;
  }
}
