import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

// Import widget yang sudah ada
import 'package:bersatubantu/fitur/widgets/bottom_navbar.dart';
import 'package:bersatubantu/fitur/donasi/donasi_screen.dart'; 
import 'package:bersatubantu/fitur/berikandonasi/berikandonasi.dart';
import 'package:bersatubantu/fitur/aturprofile/aturprofile.dart';
import 'package:bersatubantu/fitur/aksi/aksi_screen.dart';
import 'package:bersatubantu/fitur/chat/screens/chat_list_screen.dart';

// --- IMPORT UNTUK NAVIGASI BERITA ---
import 'package:bersatubantu/fitur/berita_sosial/models/berita_model.dart';
import 'package:bersatubantu/fitur/berita_sosial/screens/detail_berita.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
  
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  final supabase = Supabase.instance.client;
  late final StreamSubscription<AuthState> _authSubscription;

  int _selectedIndex = 0;
  String _selectedCategory = 'Semua';
  String _userName = '';
  bool _isLoadingUser = true;
  
  // Campaigns
  bool _isLoadingCampaigns = true;
  List<Map<String, dynamic>> _campaigns = [];

  final List<String> _categories = [
    'Semua',
    'Bencana Alam',
    'Kemiskinan',
    'Hak Asasi',
  ];

  // DATA DUMMY BERITA (Sudah lengkap dengan ID, Content, Category)
  final List<Map<String, dynamic>> _featuredNews = [
    {
      'id': '1',
      'title': 'KPK Tangkap Bupati Lampung Selatan',
      'date': '29 Juni 2024',
      'time': '10:18 WIB',
      'source': 'Kompas.com',
      'image': 'assets/news1.jpg',
      'category': 'Hukum',
      'content': 'Komisi Pemberantasan Korupsi (KPK) melakukan operasi tangkap tangan (OTT) di Lampung Selatan. Dalam operasi ini, KPK mengamankan sejumlah pihak termasuk Kepala Daerah setempat. Kasus ini berkaitan dengan dugaan suap pengadaan barang dan jasa di lingkungan Pemerintah Kabupaten Lampung Selatan.',
    },
    {
      'id': '2',
      'title': 'Pena Kemi',
      'date': '30 Juni 2024',
      'time': '09:00 WIB',
      'source': 'Media',
      'image': 'assets/news2.jpg',
      'category': 'Pendidikan',
      'content': 'Program Pena Kemi diluncurkan untuk membantu anak-anak putus sekolah di wilayah terpencil. Program ini menyediakan alat tulis dan buku gratis bagi mereka yang membutuhkan.',
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
      'content': 'Hujan deras yang mengguyur wilayah Bogor menyebabkan banjir bandang dan tanah longsor di beberapa titik. Tim SAR gabungan telah dikerahkan ke lokasi untuk mengevakuasi warga yang terdampak.',
    },
    {
      'id': '4',
      'title': 'Bencana Tanah Terjang Diungkapkan',
      'source': 'Detik.com',
      'image': 'assets/popular2.jpg',
      'date': 'Kemarin',
      'category': 'Lingkungan',
      'content': 'Ahli geologi mengungkapkan potensi pergerakan tanah di wilayah pegunungan. Warga dihimbau untuk waspada terutama saat hujan deras berlangsung lama.',
    },
    {
      'id': '5',
      'title': '27 Barang disita',
      'source': 'Detik.com',
      'image': 'assets/popular3.jpg',
      'date': '2 Jam lalu',
      'category': 'Kriminal',
      'content': 'Polisi menyita 27 barang bukti dari lokasi kejadian perkara. Barang bukti tersebut kini diamankan di Mapolres untuk penyelidikan lebih lanjut.',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _loadUserData();
      } else {
        setState(() {
          _userName = 'Pengguna';
          _isLoadingUser = false;
        });
      }
    });

    _loadUserData();
    _loadCampaigns();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingUser = true;
    });

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          _userName = 'Pengguna';
          _isLoadingUser = false;
        });
        return;
      }

      final response = await supabase
          .from('profiles')
          .select('full_name, email, id')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        final fullName = response['full_name'];
        if (fullName != null) {
          final nameString = fullName.toString().trim();
          if (nameString.isNotEmpty) {
            setState(() {
              _userName = nameString;
              _isLoadingUser = false;
            });
            return;
          }
        }
        
        final email = response['email'] ?? user.email;
        final nameFromEmail = email?.split('@')[0] ?? 'Pengguna';
        setState(() {
          _userName = nameFromEmail;
          _isLoadingUser = false;
        });
      } else {
        final email = user.email;
        final nameFromEmail = email?.split('@')[0] ?? 'Pengguna';
        setState(() {
          _userName = nameFromEmail;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      print('[Dashboard] Error loading user data: $e');
      final user = supabase.auth.currentUser;
      final email = user?.email;
      final nameFromEmail = email?.split('@')[0] ?? 'Pengguna';

      setState(() {
        _userName = nameFromEmail;
        _isLoadingUser = false;
      });
    }
  }

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
      print('[Dashboard] Error loading campaigns: $e');
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'Selamat pagi,';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat siang,';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat sore,';
    } else {
      return 'Selamat malam,';
    }
  }

  void _onRoutePopped(dynamic result) {
    _loadUserData();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadUserData();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserData();
    }
  }

  void _onNavTap(int index) async {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        setState(() {
          _selectedIndex = index;
        });
        break;
      case 1:
        setState(() {
          _selectedIndex = index;
        });
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DonasiScreen()),
        );
        _onRoutePopped(result);
        break;
      case 2:
        // Navigate to Aksi screen (TODO)
        print('[Dashboard] Navigate to Aksi');
        setState(() {
          _selectedIndex = index;
        });
        // Navigate to AksiScreen and refresh when returning
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AksiScreen()),
        );
        _onRoutePopped(result);
        break;
      case 3:
        setState(() {
          _selectedIndex = index;
        });
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        await _loadUserData();
        setState(() {
          _selectedIndex = 0;
        });
        break;
    }
  }

  // --- NAVIGASI KE DETAIL BERITA (READ ONLY) ---
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
          isAdmin: false, // USER TIDAK BISA EDIT/DELETE
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _isLoadingUser
                        ? const Center(
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'CircularStd',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontFamily: 'CircularStd',
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Message Icon Button
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatListScreen()),
                      );
                      if (result == true) {
                        _loadUserData();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF364057),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF364057),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Beritaku',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'CircularStd',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Container
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey[400]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Telusuri',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontFamily: 'CircularStd',
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Berita Title
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

                    // Category Chips
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedCategory == _categories[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(_categories[index]),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF364057),
                                fontFamily: 'CircularStd',
                                fontSize: 13,
                              ),
                              backgroundColor: Colors.white,
                              selectedColor: const Color(0xFF364057),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? const Color(0xFF364057) : Colors.grey[300]!,
                                ),
                              ),
                              onSelected: (value) {
                                setState(() {
                                  _selectedCategory = _categories[index];
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),

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

                            // Featured News Cards
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
                                            Text(
                                              news['title'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'CircularStd',
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Text(
                                                  news['date'],
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.8),
                                                    fontSize: 11,
                                                    fontFamily: 'CircularStd',
                                                  ),
                                                ),
                                                if (news['time'] != null) ...[
                                                  Text(
                                                    ' – ${news['time']}',
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.8),
                                                      fontSize: 11,
                                                      fontFamily: 'CircularStd',
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              news['source'],
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.8),
                                                fontSize: 11,
                                                fontFamily: 'CircularStd',
                                              ),
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

                            // Donasi Section
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
                                                    const SnackBar(
                                                      content: Text('Donasi ini sudah selesai'),
                                                      backgroundColor: Colors.orange,
                                                    ),
                                                  );
                                                  return;
                                                }
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
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.05),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                  border: highlight
                                                      ? Border.all(color: Colors.redAccent, width: 2)
                                                      : null,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height: 84,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius: const BorderRadius.only(
                                                          topLeft: Radius.circular(12),
                                                          topRight: Radius.circular(12),
                                                        ),
                                                        image: c['cover_image_url'] != null
                                                            ? DecorationImage(
                                                                image: NetworkImage(c['cover_image_url']),
                                                                fit: BoxFit.cover,
                                                              )
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
                                                                  style: const TextStyle(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.w700,
                                                                    color: Color(0xFF364057),
                                                                    fontFamily: 'CircularStd',
                                                                  ),
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
                                                            child: const Text(
                                                              'Donasi',
                                                              style: TextStyle(color: Colors.white, fontSize: 12),
                                                            ),
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

                            // Terpopuler Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Terpopuler',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF364057),
                                    fontFamily: 'CircularStd',
                                  ),
                                ),
                                Text(
                                  'Lihat Semua',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontFamily: 'CircularStd',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Popular News Grid
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
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[400],
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                topRight: Radius.circular(12),
                                              ),
                                              image: news['image'] != null
                                                  ? DecorationImage(
                                                      image: AssetImage(news['image']),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            ),
                                            child: news['image'] == null
                                                ? Center(
                                                    child: Icon(
                                                      Icons.image,
                                                      color: Colors.grey[600],
                                                      size: 40,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    news['title'],
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF364057),
                                                      fontFamily: 'CircularStd',
                                                    ),
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  news['source'],
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.grey[600],
                                                    fontFamily: 'CircularStd',
                                                  ),
                                                ),
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
            BottomNavBar(currentIndex: _selectedIndex, onTap: _onNavTap),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () async {
        if (index == 3) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
            ),
          );
          _loadUserData();
          return;
        }
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8FA3CC) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'CircularStd',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
