import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_verification_provider.dart';
import '../../services/supabase.dart';

class AdminVerificationReview extends StatelessWidget {
  const AdminVerificationReview({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminVerificationProvider()..loadPending(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Pending Organization Verifications')),
        body: const Padding(
          padding: EdgeInsets.all(12.0),
          child: _Body(),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminVerificationProvider>(context);
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.pendingRequests.isEmpty) return const Center(child: Text('No pending requests'));

    return ListView.builder(
      itemCount: provider.pendingRequests.length,
      itemBuilder: (context, i) {
        final item = provider.pendingRequests[i];
        return Card(
          child: ListTile(
            title: Text(item['org_legal_name'] ?? 'Unnamed Organization'),
            subtitle: Text('Owner: ${item['owner_name'] ?? 'unknown'}'),
            trailing: Text(item['status'] ?? ''),
            onTap: () => _showDetail(context, item),
          ),
        );
      },
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['org_legal_name'] ?? 'Organization', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Owner: ${item['owner_name'] ?? 'N/A'}'),
                  Text('NIK: ${item['owner_nik'] ?? 'N/A'}'),
                  Text('Address: ${item['owner_address'] ?? 'N/A'}'),
                  const SizedBox(height: 12),
                  Text('NPWP: ${item['org_npwp'] ?? 'N/A'}'),
                  Text('Registration: ${item['org_registration_no'] ?? 'N/A'}'),
                  const SizedBox(height: 12),
                  const Text('Attached Documents:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildDocumentLink('Legal Document (Akta)', item['doc_akta_url']),
                  _buildDocumentLink('NPWP Proof', item['doc_npwp_url']),
                  _buildDocumentLink('Other Document', item['doc_other_url']),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final confirmed = await _confirmAction(context, 'approve');
                            if (confirmed) {
                              final provider = Provider.of<AdminVerificationProvider>(context, listen: false);
                              final adminId = SupabaseService().auth.currentUser?.id ?? 'admin-unknown';
                              final ok = await provider.approve(
                                item['id'] is int ? item['id'] as int : int.parse(item['id'].toString()),
                                adminId: adminId,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(provider.lastMessage ?? (ok ? 'Approved' : 'Failed'))),
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Approve'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final reason = await _askReason(context);
                            if (reason != null && reason.isNotEmpty) {
                              final provider = Provider.of<AdminVerificationProvider>(context, listen: false);
                              final adminId = SupabaseService().auth.currentUser?.id ?? 'admin-unknown';
                              final ok = await provider.reject(
                                item['id'] is int ? item['id'] as int : int.parse(item['id'].toString()),
                                adminId: adminId,
                                reason: reason,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(provider.lastMessage ?? (ok ? 'Rejected' : 'Failed'))),
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentLink(String label, String? url) {
    if (url == null || url.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text('$label: Not provided'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () {
          // Could open in browser or show image preview
        },
        child: Text(
          '$label: View',
          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
        ),
      ),
    );
  }

  Future<bool> _confirmAction(BuildContext context, String action) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Confirm $action'),
            content: Text('Are you sure you want to $action this request?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes')),
            ],
          ),
        ) ??
        false;
  }

  Future<String?> _askReason(BuildContext context) async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rejection reason'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Reason')),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Send')),
        ],
      ),
    );
  }
}
