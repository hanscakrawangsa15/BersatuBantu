import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/verification_provider.dart';
import '../../../services/document_upload_service.dart';
import '../widgets/file_picker_widget.dart';

class DocumentsUploadScreen extends StatefulWidget {
  const DocumentsUploadScreen({super.key});

  @override
  State<DocumentsUploadScreen> createState() => _DocumentsUploadScreenState();
}

class _DocumentsUploadScreenState extends State<DocumentsUploadScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrganizationVerificationProvider>(
      builder: (context, provider, _) => Scaffold(
        body: Container(
          color: Colors.white,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => provider.previousStep(),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF768BBD),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'Upload Dokumen',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF768BBD),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Document 1: Akta Pendirian
                  _buildDocumentCard(
                    title: 'Akta Pendirian Organisasi',
                    subtitle: 'Akta (.pdf)',
                    onTap: () => _showUploadOption(context, 'akta'),
                    isUploaded: provider.data.docAktaPath != null,
                  ),
                  const SizedBox(height: 16),
                  // Document 2: NPWP
                  _buildDocumentCard(
                    title: 'NPWP Organisasi',
                    subtitle: 'NPWP (.pdf)',
                    onTap: () => _showUploadOption(context, 'npwp'),
                    isUploaded: provider.data.docNpwpPath != null,
                  ),
                  const SizedBox(height: 16),
                  // Document 3: Surat Keterangan
                  _buildDocumentCard(
                    title: 'Surat Keterangan Domisili Sekretariat',
                    subtitle: 'Surat Keterangan (.pdf)',
                    onTap: () => _showUploadOption(context, 'other'),
                    isUploaded: provider.data.docOtherPath != null,
                  ),
                  const SizedBox(height: 40),
                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE0E0E0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE0E0E0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF768BBD),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.previousStep(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(
                              color: Color(0xFF999999),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Kembali',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (provider.data.docAktaPath != null &&
                                  provider.data.docNpwpPath != null &&
                                  !provider.isLoading)
                              ? () async {
                                  // Submit verification data to database
                                  try {
                                    final success = await provider.submitVerification();
                                    if (mounted) {
                                      if (success) {
                                        provider.nextStep();
                                      } else {
                                        // Show error message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(provider.lastMessage ?? 'Gagal mengirim verifikasi'),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(seconds: 5),
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 5),
                                        ),
                                      );
                                    }
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF768BBD),
                            disabledBackgroundColor: const Color(0xFF768BBD).withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            provider.isLoading ? 'Mengirim...' : 'Daftar',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isUploaded,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            isUploaded
                ? Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  )
                : Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Color(0xFF768BBD),
                      size: 18,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showUploadOption(BuildContext context, String documentType) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Pilih File PDF'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _pickAndUploadFile(context, documentType);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadFile(BuildContext context, String documentType) async {
    final provider =
        Provider.of<OrganizationVerificationProvider>(context, listen: false);

    try {
      print('[DocumentUpload] Starting file picker for $documentType');
      
      // Pick file menggunakan utility
      final result = await FilePickerUtil.pickPdfFile();

      if (result == null || result.files.isEmpty) {
        print('[DocumentUpload] No file selected');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada file yang dipilih'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final file = result.files.first;
      print('[DocumentUpload] File selected: ${file.name} (${file.bytes?.length ?? 0} bytes)');

      // Validate file menggunakan utility
      if (!FilePickerUtil.validatePdfFile(file)) {
        String errorMsg = 'File tidak valid';
        if (file.bytes == null || file.bytes!.isEmpty) {
          errorMsg = 'File kosong atau tidak bisa dibaca';
        } else if (!file.name.toLowerCase().endsWith('.pdf')) {
          errorMsg = 'Hanya file PDF yang diperbolehkan';
        } else if (file.bytes!.length > 5 * 1024 * 1024) {
          errorMsg = 'Ukuran file terlalu besar (max 5MB)';
        }
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('[DocumentUpload] File validation passed');

      // Show loading dialog
      if (!mounted) return;
      _showLoadingDialog(context, 'Mengupload dokumen...');

      // Upload ke Supabase
      final uploadService = DocumentUploadService();
      final organizationId = provider.data.organizationId?.toString() ?? 
          DateTime.now().millisecondsSinceEpoch.toString();
      
      print('[DocumentUpload] Starting Supabase upload...');
      print('[DocumentUpload] Organization ID: $organizationId');
      print('[DocumentUpload] Document type: $documentType');
      print('[DocumentUpload] File size: ${file.bytes?.length} bytes');

      String? uploadUrl;
      try {
        uploadUrl = await uploadService.uploadDocumentFromBytes(
          bytes: file.bytes!,
          fileName: file.name,
          organizationId: organizationId,
          documentType: documentType,
        );
        print('[DocumentUpload] Upload completed successfully');
        print('[DocumentUpload] Public URL: $uploadUrl');
      } catch (uploadError) {
        print('[DocumentUpload] Upload error: $uploadError');
        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog
        
        _showErrorDialog(
          context,
          'Gagal Upload Dokumen',
          'Error saat upload:\n${uploadError.toString()}\n\nPastikan bucket "document_organisasi" sudah dibuat di Supabase Storage.',
        );
        return;
      }

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (uploadUrl != null && uploadUrl.isNotEmpty) {
        // Set document path di provider
        provider.setDocumentPath(documentType, uploadUrl);
        print('[DocumentUpload] Document path saved in provider');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getDocumentName(documentType)} berhasil diunggah'),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        if (!mounted) return;
        _showErrorDialog(
          context,
          'Upload Gagal',
          'Tidak dapat mendapatkan URL dokumen. Silakan coba lagi.',
        );
      }
    } catch (e) {
      print('[DocumentUpload] Exception: $e');
      print('[DocumentUpload] Exception type: ${e.runtimeType}');
      
      if (!mounted) return;
      // Close loading dialog if still open
      try {
        Navigator.pop(context);
      } catch (e) {
        // Dialog might not be open
      }
      
      final errorMsg = e is Exception 
        ? FilePickerUtil.getErrorMessage(e)
        : e.toString();
        
      _showErrorDialog(
        context,
        'Terjadi Kesalahan',
        'Error: $errorMsg\n\nTroubleshooting:\n1. Pastikan izin file sudah diberikan\n2. Koneksi internet stabil\n3. Bucket "document_organisasi" sudah ada',
      );
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF768BBD)),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'CircularStd',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getDocumentName(String documentType) {
    switch (documentType) {
      case 'akta':
        return 'Akta Pendirian';
      case 'npwp':
        return 'NPWP';
      case 'other':
        return 'Surat Keterangan';
      default:
        return 'Dokumen';
    }
  }
}
