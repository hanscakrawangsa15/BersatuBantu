import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/verification_provider.dart';
import '../../../services/document_upload_service.dart';

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
                          onPressed: () {
                            provider.nextStep();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF768BBD),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Selanjutnya',
                            style: TextStyle(
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
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Pilih File PDF'),
              onTap: () {
                Navigator.pop(context);
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
      // Show loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memilih file...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      // Show uploading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mengupload dokumen...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Upload ke Supabase
      final uploadService = DocumentUploadService();
      final organizationId = provider.data.organizationId?.toString() ?? 'unknown';
      
      String? uploadUrl;
      if (file.bytes != null) {
        uploadUrl = await uploadService.uploadDocumentFromBytes(
          bytes: file.bytes!,
          fileName: file.name,
          organizationId: organizationId,
          documentType: documentType,
        );
      }

      if (uploadUrl != null) {
        // Set document path di provider
        provider.setDocumentPath(documentType, uploadUrl);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$documentType berhasil diunggah'),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengupload dokumen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
