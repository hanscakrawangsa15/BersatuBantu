// lib/fitur/donasi/donasi_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/fitur/postingdonasi/posting_donasi_screen.dart';

class DonasiScreen extends StatefulWidget {
  final String userRole;
  final String userId;

  const DonasiScreen({
    super.key,
    required this.userRole,
    required this.userId,
  });

  @override
  State<DonasiScreen> createState() => _DonasiScreenState();
}

class _DonasiScreenState extends State<DonasiScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _campaigns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns() async {
    setState(() => _isLoading = true);

    try {
      final response = await supabase
          .from('donation_campaigns')
          .select('*')
          .eq('organization_id', widget.userId)
          .order('created_at', ascending: false);

      setState(() {
        _campaigns = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching campaigns: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8FA3CC),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: widget.userRole == "volunteer"
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF364057),
              elevation: 8,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostingDonasiScreen(
                      organizationId: widget.userId,
                    ),
                  ),
                ).then((_) => _fetchCampaigns());
              },
            )
          : null,

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _campaigns.isEmpty
              ? _buildEmptyState()
              : _buildCampaignList(),
    );
  }

  /// == UI: Jika tidak ada kegiatan ==
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Belum ada kegiatan donasi.',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 16),

          if (widget.userRole == 'volunteer')
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF364057),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PostingDonasiScreen(organizationId: widget.userId),
                  ),
                ).then((_) => _fetchCampaigns());
              },
              icon: const Icon(Icons.add),
              label: const Text("Buat Donasi Pertama"),
            ),
        ],
      ),
    );
  }

  /// == UI: List kegiatan donasi ==
  Widget _buildCampaignList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _campaigns.length,
      itemBuilder: (context, index) {
        final item = _campaigns[index];

        return Card(
          child: ListTile(
            title: Text(item['title'] ?? 'Tanpa Judul'),
            subtitle: Text(
              "Target: Rp ${item['target_amount'] ?? 0}",
            ),
          ),
        );
      },
    );
  }
}
