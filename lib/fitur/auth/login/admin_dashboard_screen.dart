import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<Map<String, dynamic>>> _pendingVerifications;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _pendingVerifications = _fetchPendingVerifications();
  }

  Future<List<Map<String, dynamic>>> _fetchPendingVerifications() async {
    try {
      print(
        '[AdminDashboard] ========== FETCH PENDING VERIFICATIONS ==========',
      );

      final response = await supabase
          .from('organization_request')
          .select('*')
          .eq('status', 'pending')
          .order('tanggal_request', ascending: false);

      print('[AdminDashboard] Query response length: ${response.length}');
      
      // Debug: Print each record with all fields
      for (int i = 0; i < response.length; i++) {
        print('[AdminDashboard] ========== RECORD $i ==========');
        final record = response[i] as Map<String, dynamic>;
        print('[AdminDashboard] All fields: $record');
        print('[AdminDashboard] request_id: ${record['request_id']}');
        print('[AdminDashboard] nama_organisasi: ${record['nama_organisasi']}');
        print('[AdminDashboard] nama_pemilik: ${record['nama_pemilik']}');
        print('[AdminDashboard] email_organisasi: ${record['email_organisasi']}');
        print('[AdminDashboard] no_telpon_organisasi: ${record['no_telpon_organisasi']}');
        print('[AdminDashboard] status: ${record['status']}');
      }

      if (response.isEmpty) {
        print('[AdminDashboard] ⚠️ No pending requests found');
      }

      print('[AdminDashboard] ========== FETCH COMPLETE ==========');
      return response.cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      print('[AdminDashboard] ❌ Error fetching: $e');
      print('[AdminDashboard] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _approveOrganization(String requestId) async {
    try {
      int id = int.parse(requestId);
      await supabase
          .from('organization_request')
          .update({'status': 'approve'})
          .eq('request_id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Organisasi berhasil disetujui'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _pendingVerifications = _fetchPendingVerifications();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectOrganization(String requestId) async {
    try {
      int id = int.parse(requestId);
      await supabase
          .from('organization_request')
          .update({'status': 'reject'})
          .eq('request_id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Organisasi berhasil ditolak'),
            backgroundColor: Colors.orange,
          ),
        );

        setState(() {
          _pendingVerifications = _fetchPendingVerifications();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadDocument(
    String organizationId,
    String documentType,
  ) async {
    try {
      final List<dynamic> files = await supabase.storage
          .from('document_organisasi')
          .list(path: 'org_$organizationId');

      // Find matching file type
      dynamic matchedFile;
      for (var file in files) {
        if (file.name.contains(documentType)) {
          matchedFile = file;
          break;
        }
      }

      if (matchedFile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File tidak ditemukan'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Download file
      await supabase.storage
          .from('document_organisasi')
          .download('org_$organizationId/${matchedFile.name}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File berhasil diunduh: ${matchedFile.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error download: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showApproveConfirmation(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Persetujuan'),
        content: const Text('Apakah Anda yakin ingin menerima organisasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveOrganization(requestId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF768BBD),
            ),
            child: const Text('Ya, Terima'),
          ),
        ],
      ),
    );
  }

  void _showRejectConfirmation(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penolakan'),
        content: const Text('Apakah Anda yakin ingin menolak organisasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectOrganization(requestId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
            ),
            child: const Text('Ya, Tolak'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF768BBD),
        elevation: 0,
        title: const Text(
          'Verifikasi Akun',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const AdminLoginScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(-1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _pendingVerifications = _fetchPendingVerifications();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pendingVerifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF768BBD)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(fontSize: 14, color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final verifications = snapshot.data ?? [];

          if (verifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada pengajuan menunggu',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengajuan Organisasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: verifications.length,
                    itemBuilder: (context, index) {
                      final verification = verifications[index];
                      print('[AdminDashboard] ========== CARD $index ==========');
                      print('[AdminDashboard] All keys in record: ${verification.keys.toList()}');
                      print('[AdminDashboard] Full record: $verification');
                      print('[AdminDashboard] nama_organisasi=${verification['nama_organisasi']}');
                      print('[AdminDashboard] nama_pemilik=${verification['nama_pemilik']}');
                      print('[AdminDashboard] email_organisasi=${verification['email_organisasi']}');
                      print('[AdminDashboard] no_telpon_organisasi=${verification['no_telpon_organisasi']}');
                      return _buildVerificationCard(context, verification);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerificationCard(
    BuildContext context,
    Map<String, dynamic> verification,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Organization Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      verification['nama_organisasi'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      verification['nama_pemilik'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      verification['email_organisasi'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      verification['no_telpon_organisasi'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () => _showDetailsDialog(context, verification),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF768BBD),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showRejectConfirmation(context, verification['request_id']?.toString() ?? ''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Tolak',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showApproveConfirmation(context, verification['request_id']?.toString() ?? ''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF768BBD),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Terima',
                    style: TextStyle(
                      fontSize: 12,
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
    );
  }

  void _showDetailsDialog(
    BuildContext context,
    Map<String, dynamic> verification,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(verification['nama_organisasi'] ?? 'Detail Organisasi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Nama Hukum', verification['nama_organisasi']),
              const SizedBox(height: 12),
              _buildDetailRow('Nama Pemilik', verification['nama_pemilik']),
              const SizedBox(height: 12),
              _buildDetailRow('Email Organisasi', verification['email_organisasi']),
              const SizedBox(height: 12),
              _buildDetailRow('Email Pemilik', verification['email_pemilik']),
              const SizedBox(height: 12),
              _buildDetailRow('No. Telepon Pemilik', verification['no_telpon_pemilik']),
              const SizedBox(height: 12),
              _buildDetailRow('No. Telepon Organisasi', verification['no_telpon_organisasi']),
              const SizedBox(height: 12),
              _buildDetailRow('Status', verification['status']),
              const SizedBox(height: 16),
              // Documents Section
              const Text(
                'Dokumen yang Diupload:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              if (verification['akta_berkas'] != null && verification['akta_berkas'].toString().isNotEmpty)
                _buildDocumentLink(
                  'Akta Pendirian',
                  verification['akta_berkas'],
                ),
              if (verification['npwp_berkas'] != null && verification['npwp_berkas'].toString().isNotEmpty)
                _buildDocumentLink('NPWP', verification['npwp_berkas']),
              if (verification['other_berkas'] != null && verification['other_berkas'].toString().isNotEmpty)
                _buildDocumentLink(
                  'Surat Keterangan',
                  verification['other_berkas'],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentLink(String label, String? url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          if (url != null && url.isNotEmpty)
            GestureDetector(
              onTap: () {
                // Open URL in browser
                // You can use url_launcher package
              },
              child: const Icon(
                Icons.download,
                size: 16,
                color: Color(0xFF768BBD),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF999999),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value ?? 'N/A',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
