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
      print('[AdminDashboard] ========== FETCH PENDING VERIFICATIONS ==========');
      
      print('[AdminDashboard] Querying organization_verifications table...');
      final response = await supabase
          .from('organization_verifications')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      print('[AdminDashboard] Query response: $response');
      print('[AdminDashboard] Found ${response.length} pending verifications');

      if (response.isEmpty) {
        print('[AdminDashboard] ⚠️ No pending verifications found');
      } else {
        for (int i = 0; i < response.length; i++) {
          print('[AdminDashboard] Verification #${i + 1}:');
          print('[AdminDashboard]   ID: ${response[i]['id']}');
          print('[AdminDashboard]   Owner: ${response[i]['owner_name']}');
          print('[AdminDashboard]   Organization: ${response[i]['org_legal_name']}');
          print('[AdminDashboard]   Status: ${response[i]['status']}');
          print('[AdminDashboard]   Created: ${response[i]['created_at']}');
        }
      }

      print('[AdminDashboard] ========== FETCH COMPLETE ==========');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('[AdminDashboard] ❌ Error fetching verifications: $e');
      print('[AdminDashboard] Exception type: ${e.runtimeType}');
      return [];
    }
  }

  Future<void> _approveOrganization(String verificationId) async {
    try {
      await supabase
          .from('organization_verifications')
          .update({'status': 'approved'})
          .eq('id', verificationId);

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

  Future<void> _rejectOrganization(String verificationId) async {
    try {
      await supabase
          .from('organization_verifications')
          .update({'status': 'rejected'})
          .eq('id', verificationId);

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
      String organizationId, String documentType) async {
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
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                      position: offsetAnimation, child: child);
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
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[600],
                    ),
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
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada pengajuan menunggu',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
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
                      return _buildVerificationCard(
                        context,
                        verification,
                      );
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
                      verification['org_legal_name'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      verification['owner_name'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      verification['email'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      verification['phone'] ?? 'N/A',
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
                  onPressed: () => _rejectOrganization(verification['id']),
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
                  onPressed: () => _approveOrganization(verification['id']),
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
        title: Text(verification['org_legal_name'] ?? 'Detail Organisasi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Nama Hukum', verification['org_legal_name']),
              const SizedBox(height: 12),
              _buildDetailRow('Nama Pemilik', verification['owner_name']),
              const SizedBox(height: 12),
              _buildDetailRow('NIK', verification['owner_nik']),
              const SizedBox(height: 12),
              _buildDetailRow('Alamat', verification['owner_address']),
              const SizedBox(height: 12),
              _buildDetailRow('Email', verification['email']),
              const SizedBox(height: 12),
              _buildDetailRow('Nomor Telepon', verification['phone']),
              const SizedBox(height: 12),
              _buildDetailRow('Kota', verification['city']),
              const SizedBox(height: 12),
              _buildDetailRow('NPWP', verification['org_npwp']),
              const SizedBox(height: 12),
              _buildDetailRow('No. Registrasi', verification['org_registration_no']),
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
              if (verification['doc_akta_url'] != null)
                _buildDocumentLink('Akta Pendirian', verification['doc_akta_url']),
              if (verification['doc_npwp_url'] != null)
                _buildDocumentLink('NPWP', verification['doc_npwp_url']),
              if (verification['doc_other_url'] != null)
                _buildDocumentLink('Surat Keterangan', verification['doc_other_url']),
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
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          if (url != null && url.isNotEmpty)
            GestureDetector(
              onTap: () {
                // Open URL in browser
                // You can use url_launcher package
              },
              child: const Icon(Icons.download, size: 16, color: Color(0xFF768BBD)),
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
