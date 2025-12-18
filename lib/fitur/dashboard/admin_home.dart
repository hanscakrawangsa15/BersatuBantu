import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

// Import necessary screens
import 'package:bersatubantu/fitur/donasi/donasi_screen.dart'; 
import 'package:bersatubantu/fitur/berikandonasi/berikandonasi.dart';
import 'package:bersatubantu/fitur/auth/login/admin_dashboard_screen.dart'; // Verifikasi Screen
import 'package:bersatubantu/fitur/aturprofile/aturprofile.dart'; // For Profile
import 'package:bersatubantu/fitur/berita_sosial/models/berita_model.dart';
import 'package:bersatubantu/fitur/berita_sosial/screens/detail_berita.dart';

class AdminHomeDashboard extends StatefulWidget {
  const AdminHomeDashboard({super.key});

  @override
  State<AdminHomeDashboard> createState() => _AdminHomeDashboardState();
}

class _AdminHomeDashboardState extends State<AdminHomeDashboard> with AutomaticKeepAliveClientMixin {
  final supabase = Supabase.instance.client;

  int _selectedIndex = 0;
  String _selectedCategory = 'Semua';
  
  // Static admin profile
  static const String ADMIN_USERNAME = 'admin';
  
  // Campaigns State
  bool _isLoadingCampaigns = true;
  List<Map<String, dynamic>> _campaigns = [];

  // News State (Dynamic)
  bool _isLoadingNews = true;
  List<Map<String, dynamic>> _featuredNews = [];
  List<Map<String, dynamic>> _popularNews = [];

  final List<String> _categories = [
    'Semua', 'Bencana Alam', 'Kemiskinan', 'Hak Asasi',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load both Campaigns and News from Database
    _loadCampaigns(); 
    _loadNews();
  }

  // --- 1. FETCH NEWS FROM SUPABASE ---
  Future<void> _loadNews() async {
    setState(() => _isLoadingNews = true);
    try {
      final response = await supabase
          .from('news')
          .select()
          .order('created_at', ascending: false);

      if (response != null) {
        final List<Map<String, dynamic>> allNews = List<Map<String, dynamic>>.from(response);
        
        setState(() {
          // Split into Popular vs Featured based on DB flag
          _popularNews = allNews.where((n) => n['is_popular'] == true).toList();
          _featuredNews = allNews.where((n) => n['is_popular'] != true).toList();
          
          // Fallback logic if flags aren't set
          if (_popularNews.isEmpty && allNews.isNotEmpty) {
             _popularNews = allNews.take(3).toList();
             _featuredNews = allNews.skip(3).toList();
          }
        });
      }
    } catch (e) {
      print('[AdminDashboard] Error loading news: $e');
    } finally {
      if (mounted) setState(() => _isLoadingNews = false);
    }
  }

  // --- 2. FETCH CAMPAIGNS FROM SUPABASE ---
  Future<void> _loadCampaigns() async {
    setState(() => _isLoadingCampaigns = true);
    try {
      final response = await supabase
          .from('donation_campaigns')
          .select('id, title, cover_image_url, end_time, description, target_amount, collected_amount, location, location_name')
          .eq('status', 'active')
          .order('end_time', ascending: true)
          .limit(50);

      if (response != null) {
        setState(() => _campaigns = List<Map<String, dynamic>>.from(response));
      }
    } catch (e) {
      print('[AdminDashboard] Error loading campaigns: $e');
      setState(() => _campaigns = []);
    } finally {
      if (mounted) setState(() => _isLoadingCampaigns = false);
    }
  }

  // --- HELPER: Date Formatting ---
  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return "${date.day}/${date.month}/${date.year}"; 
    } catch (e) {
      return dateStr;
    }
  }

  // --- HELPER: Time Remaining ---
  Map<String, dynamic> _remainingUntil(String? endTimeStr) {
    if (endTimeStr == null) return {'text': 'Tidak tersedia', 'days': null};
    try {
      final end = DateTime.parse(endTimeStr).toLocal();
      final now = DateTime.now();
      final diff = end.difference(now);
      if (diff.isNegative) return {'text': 'Selesai', 'days': diff.inDays};
      if (diff.inDays >= 1) return {'text': '${diff.inDays} hari lagi', 'days': diff.inDays};
      return {'text': '${diff.inHours} jam lagi', 'days': 0};
    } catch (e) {
      return {'text': 'Tidak tersedia', 'days': null};
    }
  }

  // --- 3. NAVIGATE WITH ADMIN PRIVILEGES ---
  void _navigateToNewsDetail(Map<String, dynamic> news) async {
    final beritaData = BeritaModel(
      id: news['id'].toString(),
      judul: news['title'] ?? 'Tanpa Judul',
      tanggal: _formatDate(news['created_at']),
      category: news['category'] ?? 'Umum',
      image: news['image_url'] ?? '',
      source: news['source'] ?? 'Admin',
      isi: news['content'] ?? 'Konten tidak tersedia.',
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailBeritaScreen(
          berita: beritaData,
          isAdmin: true, // <<-- THIS ENABLES DELETE/EDIT
        ),
      ),
    );

    // Refresh list when returning (in case item was deleted)
    _loadNews();
  }

  void _onNavTap(int index) async {
    if (index == _selectedIndex) return;

    if (index == 2) {
       await Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
       return;
    }
    if (index == 3) {
       await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen(isAdmin: true)));
       return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Selamat pagi,';
    if (hour >= 11 && hour < 15) return 'Selamat siang,';
    if (hour >= 15 && hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF8FA3CC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getGreeting(), style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'CircularStd')),
                      const SizedBox(height: 6),
                      const Text(ADMIN_USERNAME, style: TextStyle(color: Colors.white, fontSize: 32, fontFamily: 'CircularStd', fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF364057), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Admin', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'CircularStd')),
                  ),
                ],
              ),
            ),

            // Content Container
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(25)),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey[400]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Telusuri Berita (Admin Mode)',
                                  hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'CircularStd'),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(alignment: Alignment.centerLeft, child: Text('Kelola Berita', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF364057), fontFamily: 'CircularStd'))),
                    ),
                    const SizedBox(height: 16),

                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // FEATURED NEWS (Admin View)
                            SizedBox(
                              height: 200,
                              child: _isLoadingNews 
                                ? const Center(child: CircularProgressIndicator())
                                : _featuredNews.isEmpty
                                  ? const Center(child: Text("Belum ada berita"))
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _featuredNews.length,
                                      itemBuilder: (context, index) {
                                        final news = _featuredNews[index];
                                        return GestureDetector(
                                          onTap: () => _navigateToNewsDetail(news),
                                          child: Container(
                                            width: 280,
                                            margin: const EdgeInsets.only(right: 12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4A5E7C),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(news['title'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(_formatDate(news['created_at']), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                                                      // Edit Icon Indicator
                                                      Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                                        child: const Icon(Icons.edit, color: Colors.white, size: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            
                            const SizedBox(height: 20),

                            // DONASI SECTION
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Donasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF364057), fontFamily: 'CircularStd')),
                                GestureDetector(
                                  onTap: () => _loadCampaigns(),
                                  child: Text(_isLoadingCampaigns ? 'Memuat...' : 'Lihat Semua', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontFamily: 'CircularStd')),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 160,
                              child: _isLoadingCampaigns
                                  ? const Center(child: CircularProgressIndicator())
                                  : _campaigns.isEmpty
                                      ? Center(child: Text('Tidak ada kampanye aktif', style: TextStyle(color: Colors.grey[600])))
                                      : ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _campaigns.length,
                                          itemBuilder: (context, idx) {
                                            final c = _campaigns[idx];
                                            final rem = _remainingUntil(c['end_time']);
                                            return GestureDetector(
                                              onTap: () async {
                                                await Navigator.push(context, MaterialPageRoute(builder: (context) => BerikanDonasiScreen(donation: c)));
                                              },
                                              child: Container(
                                                width: 300,
                                                margin: const EdgeInsets.only(right: 12),
                                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height: 84,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                        image: c['cover_image_url'] != null ? DecorationImage(image: NetworkImage(c['cover_image_url']), fit: BoxFit.cover) : null,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(c['title'] ?? 'Kegiatan', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                            ),
                            
                            const SizedBox(height: 24),
                            const Text('Daftar Berita Lainnya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF364057), fontFamily: 'CircularStd')),
                            const SizedBox(height: 12),

                            // POPULAR NEWS GRID (Admin View)
                            _isLoadingNews 
                              ? const SizedBox() 
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.75,
                                  ),
                                  itemCount: _popularNews.length,
                                  itemBuilder: (context, index) {
                                    final news = _popularNews[index];
                                    return GestureDetector(
                                      onTap: () => _navigateToNewsDetail(news),
                                      child: Container(
                                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[400],
                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                      image: news['image_url'] != null ? DecorationImage(image: NetworkImage(news['image_url']), fit: BoxFit.cover) : null,
                                                    ),
                                                    child: news['image_url'] == null ? const Center(child: Icon(Icons.image)) : null,
                                                  ),
                                                  Positioned(
                                                    top: 4, right: 4,
                                                    child: Container(
                                                      padding: const EdgeInsets.all(2),
                                                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                                                      child: const Icon(Icons.edit, color: Colors.white, size: 10),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(child: Text(news['title'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), maxLines: 3, overflow: TextOverflow.ellipsis)),
                                                    Text(news['source'] ?? '', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_rounded, 'Beranda', 0),
                  _buildNavItem(Icons.newspaper, 'Berita', 1),
                  _buildNavItem(Icons.verified_user_outlined, 'Verifikasi', 2),
                  _buildNavItem(Icons.person_outline_rounded, 'Profil', 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF8FA3CC) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey[600], size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}