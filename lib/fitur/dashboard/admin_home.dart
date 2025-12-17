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
  
  // Campaigns (Connected to Supabase)
  bool _isLoadingCampaigns = true;
  List<Map<String, dynamic>> _campaigns = [];

  final List<String> _categories = [
    'Semua', 'Bencana Alam', 'Kemiskinan', 'Hak Asasi',
  ];

  // News Data (Static)
  final List<Map<String, dynamic>> _featuredNews = [
    {
      'id': '1',
      'title': 'KPK Tangkap Bupati Lampung Selatan',
      'date': '29 Juni 2024',
      'time': '10:18 WIB',
      'source': 'Kompas.com',
      'image': 'assets/news1.jpg',
      'category': 'Hukum',
      'content': 'Komisi Pemberantasan Korupsi (KPK) melakukan operasi tangkap tangan (OTT) di Lampung Selatan...',
    },
    {
      'id': '2',
      'title': 'Pena Kemi',
      'date': '30 Juni 2024',
      'time': '08:00 WIB',
      'source': 'Media',
      'image': 'assets/news2.jpg',
      'category': 'Pendidikan',
      'content': 'Program Pena Kemi diluncurkan untuk membantu anak-anak putus sekolah...',
    },
  ];

  final List<Map<String, dynamic>> _popularNews = [
    {
      'id': '3',
      'title': 'Banjir Hingga Longsor Landa',
      'source': 'Detik.com',
      'image': 'assets/popular1.jpg',
      'date': 'Hari ini',
      'category': 'Bencana Alam',
      'content': 'Hujan deras yang mengguyur wilayah Bogor menyebabkan banjir bandang...',
    },
    {
      'id': '4',
      'title': 'Bencana Tanah Terjang Diungkapkan',
      'source': 'Detik.com',
      'image': 'assets/popular2.jpg',
      'date': 'Kemarin',
      'category': 'Lingkungan',
      'content': 'Ahli geologi mengungkapkan potensi pergerakan tanah...',
    },
    {
      'id': '5',
      'title': '27 Barang disita',
      'source': 'Detik.com',
      'image': 'assets/popular3.jpg',
      'date': '2 Jam lalu',
      'category': 'Kriminal',
      'content': 'Polisi menyita 27 barang bukti dari lokasi kejadian perkara...',
    },
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCampaigns(); // Fetch campaigns from Database
  }

  // --- DATABASE CONNECTION FOR CAMPAIGNS ---
  Future<void> _loadCampaigns() async {
    setState(() {
      _isLoadingCampaigns = true;
    });

    try {
      final response = await supabase
          .from('donation_campaigns')
          .select(
            'id, title, cover_image_url, end_time, description, target_amount, collected_amount, location, location_name',
          )
          .eq('status', 'active')
          .order('end_time', ascending: true)
          .limit(50);

      if (response != null && response is List) {
        setState(() {
          _campaigns = List<Map<String, dynamic>>.from(response);
        });
      } else {
        setState(() {
          _campaigns = [];
        });
      }
    } catch (e) {
      print('[AdminDashboard] Error loading campaigns: $e');
      setState(() {
        _campaigns = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCampaigns = false;
        });
      }
    }
  }

  // --- HELPER FOR TIME REMAINING ---
  Map<String, dynamic> _remainingUntil(String? endTimeStr) {
    if (endTimeStr == null) return {'text': 'Tidak tersedia', 'days': null};

    try {
      final end = DateTime.parse(endTimeStr).toLocal();
      final now = DateTime.now();
      final diff = end.difference(now);
      final days = diff.inDays;
      if (diff.isNegative) {
        return {'text': 'Selesai', 'days': days};
      }
      if (days >= 1) {
        return {'text': '$days hari lagi', 'days': days};
      }
      final hours = diff.inHours;
      if (hours >= 1) return {'text': '$hours jam lagi', 'days': 0};
      final minutes = diff.inMinutes;
      return {'text': '$minutes menit lagi', 'days': 0};
    } catch (e) {
      return {'text': 'Tidak tersedia', 'days': null};
    }
  }

  // --- ADMIN NAVIGATION (FULL ACCESS) ---
  void _navigateToNewsDetail(Map<String, dynamic> news) {
    final beritaData = BeritaModel(
      id: news['id'] ?? DateTime.now().toString(),
      judul: news['title'] ?? 'Tanpa Judul',
      tanggal: news['date'] ?? '',
      category: news['category'] ?? 'Berita',
      image: news['image'] ?? '',
      source: news['source'] ?? 'Sumber tidak diketahui',
      isi: news['content'] ?? 'Konten berita belum tersedia.',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailBeritaScreen(
          berita: beritaData,
          isAdmin: true, // <<-- KEY: ENABLE EDIT/DELETE FOR ADMIN
        ),
      ),
    );
  }

  void _onNavTap(int index) async {
    if (index == _selectedIndex) return;

    if (index == 1) {
       // Placeholder for Admin News List or Add News
       print("Admin clicked Berita Tab");
    }
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
                      Text(
                        _getGreeting(),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'CircularStd'),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        ADMIN_USERNAME,
                        style: TextStyle(color: Colors.white, fontSize: 32, fontFamily: 'CircularStd', fontWeight: FontWeight.bold),
                      ),
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
                                  hintText: 'Telusuri Berita (Admin)',
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
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Berita',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF364057),
                            fontFamily: 'CircularStd',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Berita Terbaru Section
                            const Text(
                              'Berita Terbaru',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF364057),
                                fontFamily: 'CircularStd',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Featured News Cards (Horizontal)
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
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
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(news['title'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(news['date'], style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                                                // Visual Cue: Edit Icon
                                                Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.2),
                                                    shape: BoxShape.circle,
                                                  ),
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

                            // Donasi Section (Connected to DB)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Donasi',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF364057),
                                    fontFamily: 'CircularStd',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _loadCampaigns(),
                                  child: Text(
                                    _isLoadingCampaigns ? 'Memuat...' : 'Lihat Semua',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontFamily: 'CircularStd',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 160,
                              child: _isLoadingCampaigns
                                  ? const Center(child: CircularProgressIndicator())
                                  : _campaigns.isEmpty
                                      ? Center(
                                          child: Text(
                                            'Tidak ada kampanye aktif',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        )
                                      : ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _campaigns.length,
                                          itemBuilder: (context, idx) {
                                            final c = _campaigns[idx];
                                            final rem = _remainingUntil(c['end_time'] as String?);
                                            final days = rem['days'];
                                            final remText = rem['text'] as String;
                                            final highlight = days != null && days >= 1 && days <= 5;
                                            final canDonate = c['end_time'] != null
                                                ? (DateTime.tryParse(c['end_time'])?.isAfter(DateTime.now()) ?? true)
                                                : true;

                                            return GestureDetector(
                                              onTap: () async {
                                                if (!canDonate) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Donasi ini sudah selesai'), backgroundColor: Colors.orange),
                                                  );
                                                  return;
                                                }
                                                // Admin can also view/donate to campaigns
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => BerikanDonasiScreen(donation: c),
                                                  ),
                                                );
                                                if (result == true) {
                                                  _loadCampaigns();
                                                }
                                              },
                                              child: Container(
                                                width: 300,
                                                height: 140,
                                                margin: const EdgeInsets.only(right: 12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
                                                  ],
                                                  border: highlight ? Border.all(color: Colors.redAccent, width: 2) : null,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height: 84,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                        image: c['cover_image_url'] != null
                                                            ? DecorationImage(image: NetworkImage(c['cover_image_url']), fit: BoxFit.cover)
                                                            : null,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Text(
                                                                  c['title'] ?? 'Kegiatan',
                                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF364057), fontFamily: 'CircularStd'),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                                const SizedBox(height: 6),
                                                                Text(
                                                                  remText,
                                                                  style: TextStyle(
                                                                    color: highlight ? Colors.redAccent : Colors.grey[700],
                                                                    fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                                                                    fontFamily: 'CircularStd',
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFF8FA3CC),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: const Text('Donasi', style: TextStyle(color: Colors.white, fontSize: 12)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                            ),

                            const SizedBox(height: 24),
                            const Text('Terpopuler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF364057))),
                            const SizedBox(height: 12),

                            // Popular News Grid (Admin View)
                            GridView.builder(
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
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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
                                                  image: news['image'] != null 
                                                    ? DecorationImage(image: AssetImage(news['image']), fit: BoxFit.cover) 
                                                    : null,
                                                ),
                                                child: news['image'] == null ? const Center(child: Icon(Icons.image)) : null,
                                              ),
                                              // Visual Cue: Small edit icon
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: Container(
                                                  padding: const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.5),
                                                    shape: BoxShape.circle,
                                                  ),
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
                                                Text(news['source'], style: const TextStyle(fontSize: 9, color: Colors.grey)),
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

            // Bottom Nav
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