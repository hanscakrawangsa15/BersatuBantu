import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:async';

// Existing Imports
import 'package:bersatubantu/fitur/widgets/bottom_navbar.dart';
import 'package:bersatubantu/fitur/donasi/donasi_screen.dart'; 
import 'package:bersatubantu/fitur/berikandonasi/berikandonasi.dart';
import 'package:bersatubantu/fitur/aturprofile/aturprofile.dart';
import 'package:bersatubantu/fitur/aksi/aksi_screen.dart';
import 'package:bersatubantu/fitur/chat/screens/chat_list_screen.dart';
import 'package:bersatubantu/fitur/berita_sosial/models/berita_model.dart';
import 'package:bersatubantu/fitur/berita_sosial/screens/detail_berita.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  void _onRoutePopped(dynamic result) {
    _loadUserData();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadUserData();
      }
    });
  }

  final supabase = Supabase.instance.client;
  late final StreamSubscription<AuthState> _authSubscription;

  int _selectedIndex = 0;
  String _selectedCategory = 'Semua';
  String _userName = '';
  bool _isLoadingUser = true;
  
  bool _isLoadingCampaigns = true;
  List<Map<String, dynamic>> _campaigns = [];

  bool _isLoadingNews = true;
  List<Map<String, dynamic>> _featuredNews = [];
  List<Map<String, dynamic>> _popularNews = [];

  final List<String> _categories = [
    'Semua',
    'Bencana Alam',
    'Kemiskinan',
    'Hak Asasi',
  ];

  String _selectedDonationCategory = 'Semua';
  final List<String> _donationCategories = [
    'Semua',
    'Bencana Alam',
    'Kemiskinan',
    'Hak Asasi',
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
    _loadNews();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
          _popularNews = allNews.where((news) => news['is_popular'] == true).toList();
          _featuredNews = allNews.where((news) => news['is_popular'] != true).toList();
          
          if (_popularNews.isEmpty && allNews.isNotEmpty) {
             _popularNews = allNews.take(3).toList();
             _featuredNews = allNews.skip(3).toList();
          }
        });
      }
    } catch (e) {
      print('[Dashboard] Error loading news: $e');
    } finally {
      if (mounted) setState(() => _isLoadingNews = false);
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoadingUser = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() { _userName = 'Pengguna'; _isLoadingUser = false; });
        return;
      }
      final response = await supabase.from('profiles').select('full_name, email').eq('id', user.id).maybeSingle();
      if (response != null) {
        final fullName = response['full_name']?.toString().trim();
        final email = response['email'] ?? user.email;
        setState(() {
          _userName = (fullName != null && fullName.isNotEmpty) ? fullName : (email?.split('@')[0] ?? 'Pengguna');
          _isLoadingUser = false;
        });
      } else {
        setState(() { _userName = user.email?.split('@')[0] ?? 'Pengguna'; _isLoadingUser = false; });
      }
    } catch (e) {
      setState(() { _userName = 'Pengguna'; _isLoadingUser = false; });
    }
  }

  Future<void> _loadCampaigns() async {
    setState(() => _isLoadingCampaigns = true);
    try {
      final response = await supabase
          .from('donation_campaigns')
          .select('id, title, cover_image_url, end_time, description, target_amount, collected_amount, location, location_name, category')
          .eq('status', 'active')
          .order('end_time', ascending: true)
          .limit(50);
      if (response != null) {
        setState(() => _campaigns = List<Map<String, dynamic>>.from(response));
      }
    } catch (e) {
      print('[Dashboard] Error loading campaigns: $e');
      setState(() => _campaigns = []);
    } finally {
      if (mounted) setState(() => _isLoadingCampaigns = false);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return "${date.day}/${date.month}/${date.year}"; 
    } catch (e) {
      return dateStr;
    }
  }

  Map<String, dynamic> _remainingUntil(String? endTimeStr) {
    if (endTimeStr == null) return {'text': 'Tidak tersedia', 'days': null};
    try {
      final end = DateTime.parse(endTimeStr).toLocal();
      final diff = end.difference(DateTime.now());
      final days = diff.inDays;
      if (diff.isNegative) return {'text': 'Selesai', 'days': days};
      if (days >= 1) return {'text': '$days hari lagi', 'days': days};
      final hours = diff.inHours;
      if (hours >= 1) return {'text': '$hours jam lagi', 'days': 0};
      return {'text': '${diff.inMinutes} menit lagi', 'days': 0};
    } catch (e) {
      return {'text': 'Tidak tersedia', 'days': null};
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Selamat pagi,';
    if (hour >= 11 && hour < 15) return 'Selamat siang,';
    if (hour >= 15 && hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  // Helper function to get category color
  Color _getCategoryColor(String? category) {
    if (category == null) return Colors.grey;
    switch (category.toLowerCase()) {
      case 'bencana alam':
        return const Color(0xFFE57373); // Red
      case 'kemiskinan':
        return const Color(0xFF81C784); // Green
      case 'hak asasi':
        return const Color(0xFF64B5F6); // Blue
      default:
        return Colors.grey;
    }
  }

  // Helper function to get category icon
  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.category;
    switch (category.toLowerCase()) {
      case 'bencana alam':
        return Icons.warning_rounded;
      case 'kemiskinan':
        return Icons.volunteer_activism_rounded;
      case 'hak asasi':
        return Icons.account_balance_rounded;
      default:
        return Icons.category;
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
        setState(() {
          _selectedIndex = index;
        });
        break;
      case 3:
        setState(() {
          _selectedIndex = index;
        });
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        _loadUserData();
        setState(() {
          _selectedIndex = 0;
        });
        break;
    }
  }

  void _navigateToNewsDetail(Map<String, dynamic> news) {
    final beritaData = BeritaModel(
      id: news['id'].toString(),
      judul: news['title'] ?? 'Tanpa Judul',
      tanggal: _formatDate(news['created_at']),
      category: news['category'] ?? 'Umum',
      image: news['image_url'] ?? '',
      source: news['source'] ?? 'Admin',
      isi: news['content'] ?? 'Konten berita belum tersedia.',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailBeritaScreen(
          berita: beritaData,
          isAdmin: false,
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
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getGreeting(), style: const TextStyle(color: Colors.white, fontSize: 18)),
                              const SizedBox(height: 6),
                              Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold), maxLines: 2),
                            ],
                          ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF364057), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Beritaku', style: TextStyle(color: Colors.white, fontSize: 12)),
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
                            Expanded(child: TextField(decoration: InputDecoration(hintText: 'Telusuri', hintStyle: TextStyle(color: Colors.grey[400]), border: InputBorder.none))),
                          ],
                        ),
                      ),
                    ),

                    // Berita Title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(alignment: Alignment.centerLeft, child: Text('Berita', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF364057)))),
                    ),
                    const SizedBox(height: 16),

                    // Category Chips (Horizontal List)
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
                              labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF364057), fontSize: 13),
                              backgroundColor: Colors.white,
                              selectedColor: const Color(0xFF364057),
                              onSelected: (value) => setState(() => _selectedCategory = _categories[index]),
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
                            const Text('Berita Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF364057))),
                            const SizedBox(height: 12),

                            // Featured News (Horizontal List)
                            SizedBox(
                              height: 200,
                              child: _isLoadingNews
                                  ? const Center(child: CircularProgressIndicator())
                                  : _featuredNews.isEmpty
                                      ? const Center(child: Text("Belum ada berita terbaru"))
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
                                                      Text(news['title'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 3, overflow: TextOverflow.ellipsis),
                                                      const SizedBox(height: 12),
                                                      Row(
                                                        children: [
                                                          Text(_formatDate(news['created_at']), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(news['source'] ?? 'Sumber tidak tersedia', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
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
                                Row(children: [
                                  GestureDetector(
                                    onTap: () => _showDonationCategoryDialog(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: _selectedDonationCategory != 'Semua' 
                                            ? _getCategoryColor(_selectedDonationCategory).withOpacity(0.2)
                                            : const Color(0xFFEFEFF4),
                                        borderRadius: BorderRadius.circular(8),
                                        border: _selectedDonationCategory != 'Semua'
                                            ? Border.all(color: _getCategoryColor(_selectedDonationCategory), width: 1.5)
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _selectedDonationCategory != 'Semua'
                                                ? _getCategoryIcon(_selectedDonationCategory)
                                                : Icons.category_rounded,
                                            size: 14,
                                            color: _selectedDonationCategory != 'Semua'
                                                ? _getCategoryColor(_selectedDonationCategory)
                                                : const Color(0xFF364057),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _selectedDonationCategory,
                                            style: TextStyle(
                                              color: _selectedDonationCategory != 'Semua'
                                                  ? _getCategoryColor(_selectedDonationCategory)
                                                  : Colors.grey[700],
                                              fontSize: 12,
                                              fontWeight: _selectedDonationCategory != 'Semua'
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              fontFamily: 'CircularStd',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const DonasiScreen()),
                                      );
                                      _loadCampaigns();
                                    },
                                    child: Text(
                                      'Lihat Semua',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: const Color(0xFF8FA3CC),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'CircularStd',
                                      ),
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Donation Campaigns List with Filter
                            Builder(builder: (context) {
                              // Apply category filter
                              final filteredCampaigns = _selectedDonationCategory == 'Semua'
                                  ? _campaigns
                                  : _campaigns.where((c) {
                                      final category = (c['category'] ?? '').toString();
                                      return category.toLowerCase() == _selectedDonationCategory.toLowerCase();
                                    }).toList();

                              if (_isLoadingCampaigns) {
                                return const SizedBox(
                                  height: 160,
                                  child: Center(child: CircularProgressIndicator(color: Color(0xFF8FA3CC))),
                                );
                              }
                              
                              if (filteredCampaigns.isEmpty) {
                                return SizedBox(
                                  height: 160,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
                                        const SizedBox(height: 8),
                                        Text(
                                          _selectedDonationCategory == 'Semua'
                                              ? 'Tidak ada kampanye aktif'
                                              : 'Tidak ada kampanye untuk\nkategori $_selectedDonationCategory',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                            fontFamily: 'CircularStd',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: filteredCampaigns.length,
                                  itemBuilder: (context, idx) {
                                    final c = filteredCampaigns[idx];
                                    final rem = _remainingUntil(c['end_time'] as String?);
                                    final days = rem['days'];
                                    final remText = rem['text'] as String;
                                    final highlight = days != null && days >= 1 && days <= 5;
                                    final canDonate = c['end_time'] != null
                                        ? (DateTime.tryParse(c['end_time'])?.isAfter(DateTime.now()) ?? true)
                                        : true;
                                    final category = c['category'] as String?;

                                    return GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BerikanDonasiScreen(donation: c),
                                          ),
                                        );
                                        _loadCampaigns();
                                      },
                                      child: Container(
                                        width: 300,
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.08),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Stack(
                                              children: [
                                                Container(
                                                  height: 120,
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
                                                  child: c['cover_image_url'] == null
                                                      ? Icon(Icons.image, size: 40, color: Colors.grey[400])
                                                      : null,
                                                ),
                                                // Category Badge
                                                if (category != null)
                                                  Positioned(
                                                    top: 8,
                                                    left: 8,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: _getCategoryColor(category),
                                                        borderRadius: BorderRadius.circular(12),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.15),
                                                            blurRadius: 4,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            _getCategoryIcon(category),
                                                            size: 12,
                                                            color: Colors.white,
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            category,
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                // Urgent Badge
                                                if (highlight)
                                                  Positioned(
                                                    bottom: 8,
                                                    right: 8,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orangeAccent,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        '$days hari lagi',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    c['title'] ?? 'Kegiatan',
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      fontFamily: 'CircularStd',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    remText,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: highlight ? Colors.orangeAccent : Colors.grey[600],
                                                      fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                                                      fontFamily: 'CircularStd',
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
                              );
                            }),
                            
                            const SizedBox(height: 24),

                            // Terpopuler Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Terpopuler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF364057))),
                                Text('Lihat Semua', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Popular News Grid (Dynamic)
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
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[400],
                                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                  image: news['image_url'] != null ? DecorationImage(image: NetworkImage(news['image_url']), fit: BoxFit.cover) : null,
                                                ),
                                                child: news['image_url'] == null ? const Icon(Icons.image) : null,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(child: Text(news['title'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600), maxLines: 3, overflow: TextOverflow.ellipsis)),
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

            BottomNavBar(currentIndex: _selectedIndex, onTap: _onNavTap),
          ],
        ),
      ),
    );
  }

  void _showDonationCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Pilih Kategori Donasi',
          style: TextStyle(
            fontFamily: 'CircularStd',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _donationCategories.map((category) {
            final isSelected = _selectedDonationCategory == category;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedDonationCategory = category;
                });
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _getCategoryColor(category).withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? _getCategoryColor(category) : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 20,
                      color: isSelected ? _getCategoryColor(category) : Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(
                          fontFamily: 'CircularStd',
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? _getCategoryColor(category) : Colors.grey[800],
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: _getCategoryColor(category),
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}