import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/fitur/widgets/bottom_navbar.dart';
import 'package:bersatubantu/fitur/donasi/donasi_screen.dart'; // Import donasi screen
import 'package:bersatubantu/fitur/berikandonasi/berikandonasi.dart';
import 'dart:async';
import 'package:bersatubantu/fitur/aturprofile/aturprofile.dart';
import 'package:bersatubantu/fitur/aksi/aksi_screen.dart';

class DashboardScreenOrganisasi extends StatefulWidget {
  final int requestId;

  const DashboardScreenOrganisasi({
    super.key,
    required this.requestId,
  });

  @override
  State<DashboardScreenOrganisasi> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreenOrganisasi> with WidgetsBindingObserver {
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

  final List<Map<String, dynamic>> _featuredNews = [
    {
      'title': 'KPK Tangkap Bupati Lampung Selatan',
      'date': '29 Juni 2024',
      'time': '10:18 WIB',
      'source': 'Kompas.com',
      'image': 'assets/news1.jpg',
    },
    {
      'title': 'Pena Kemi',
      'date': '30 Juni 2024',
      'source': 'Media',
      'image': 'assets/news2.jpg',
    },
  ];

  final List<Map<String, dynamic>> _popularNews = [
    {
      'title': 'Banjir Hingga Longsor Landa',
      'source': 'Detik.com',
      'image': 'assets/popular1.jpg',
    },
    {
      'title': 'Bencana Tanah Terejng Diungkapkan',
      'source': 'Detik.com',
      'image': 'assets/popular2.jpg',
    },
    {
      'title': '27 Ba Rang dine',
      'source': 'Detik.com',
      'image': 'assets/popular3.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Register WidgetsBindingObserver untuk track lifecycle
    WidgetsBinding.instance.addObserver(this);

    // Listen to auth state changes
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        print('[Dashboard] Auth state changed - User is logged in');
        _loadUserData();
      } else {
        print('[Dashboard] Auth state changed - User is logged out');
        setState(() {
          _userName = 'Pengguna';
          _isLoadingUser = false;
        });
      }
    });

    // Initial load
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
      // Get current user ID from auth
      final user = supabase.auth.currentUser;

      if (user == null) {
        print('[Dashboard] No authenticated user found');
        setState(() {
          _userName = 'Pengguna';
          _isLoadingUser = false;
        });
        return;
      }

      print('[Dashboard] Current user ID: ${user.id}');
      print('[Dashboard] User email: ${user.email}');

      // Query profiles table with the user ID - ALWAYS CHECK DATABASE FIRST
      print('[Dashboard] Querying profiles table for fresh data from user ID: ${user.id}');

      final response = await supabase
          .from('profiles')
          .select('full_name, email, id')
          .eq('id', user.id)
          .maybeSingle();

      print('[Dashboard] Query response: $response');

      if (response != null) {
        print('[Dashboard] Profile found in database');

        final fullName = response['full_name'];
        print(
          '[Dashboard] Full name value: "$fullName" (type: ${fullName.runtimeType})',
        );

        if (fullName != null) {
          final nameString = fullName.toString().trim();
          print('[Dashboard] After trim: "$nameString"');

          if (nameString.isNotEmpty) {
            setState(() {
              _userName = nameString;
              _isLoadingUser = false;
            });
            print('[Dashboard] Successfully loaded user name from DB: $_userName');
            return;
          }
        }

        // Fallback: Try email prefix
        print('[Dashboard] full_name is null or empty, using email prefix fallback');
        final email = response['email'] ?? user.email;
        final nameFromEmail = email?.split('@')[0] ?? 'Pengguna';
        setState(() {
          _userName = nameFromEmail;
          _isLoadingUser = false;
        });
        print('[Dashboard] Using email prefix: $_userName');
      } else {
        // Profile not found in database
        print(
          '[Dashboard] No profile found in database for user ID: ${user.id}',
        );

        final email = user.email;
        final nameFromEmail = email?.split('@')[0] ?? 'Pengguna';
        setState(() {
          _userName = nameFromEmail;
          _isLoadingUser = false;
        });
        print('[Dashboard] Using email prefix as fallback: $_userName');
      }
    } catch (e, stackTrace) {
      print('[Dashboard] Error loading user data: $e');
      print('[Dashboard] Stack trace: $stackTrace');

      // Fallback to email prefix
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

  // Returns a pair: formatted string and daysLeft (rounded down)
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

  // Refresh user data when returning from other screens
  void _onRoutePopped(dynamic result) {
    print('[Dashboard] Route popped with result: $result - Refreshing user data');
    // Trigger immediate refresh
    _loadUserData();
    // Trigger delayed refresh untuk ensure data loaded properly
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        print('[Dashboard] Delayed refresh - reloading user data');
        _loadUserData();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('[Dashboard] App resumed - Refreshing user data');
      _loadUserData();
    }
  }

  void _onNavTap(int index) async {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        // Already on Beranda, do nothing
        setState(() {
          _selectedIndex = index;
        });
        break;
      case 1:
        // Navigate to Donasi screen
        print('[Dashboard] Navigate to Donasi');
        setState(() {
          _selectedIndex = index;
        });
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DonasiScreen()),
        );
        // Refresh data after returning from Donasi
        _onRoutePopped(result);
        break;
      case 2:
        // Navigate to Aksi screen
        print('[Dashboard] Navigate to Aksi');
        setState(() {
          _selectedIndex = index;
        });
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AksiScreen()),
        );
        break;
      case 3:
        // Navigate to Profil (Atur Profil)
        print('[Dashboard] Navigate to Profil');
        setState(() {
          _selectedIndex = index;
        });
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        // Refresh user data immediately after returning from profile edit
        print('[Dashboard] Returned from ProfileScreen with result: $result');
        // Force reload data regardless of result
        await _loadUserData();
        // Add another delayed refresh to ensure DB sync
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          await _loadUserData();
        }
        setState(() {
          _selectedIndex = 0;
        });
        break;
    }
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
                        ? Row(
                            children: [
                              const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Memuat...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'CircularStd',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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
                          final isSelected =
                              _selectedCategory == _categories[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(_categories[index]),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF364057),
                                fontFamily: 'CircularStd',
                                fontSize: 13,
                              ),
                              backgroundColor: Colors.white,
                              selectedColor: const Color(0xFF364057),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFF364057)
                                      : Colors.grey[300]!,
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
                                  return Container(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontSize: 11,
                                                  fontFamily: 'CircularStd',
                                                ),
                                              ),
                                              if (news['time'] != null) ...[
                                                Text(
                                                  ' – ${news['time']}',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.8),
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
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              fontSize: 11,
                                              fontFamily: 'CircularStd',
                                            ),
                                          ),
                                        ],
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
                                    _isLoadingCampaigns
                                        ? 'Memuat...'
                                        : 'Lihat Semua',
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
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : _campaigns.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Tidak ada kampanye aktif',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _campaigns.length,
                                      itemBuilder: (context, idx) {
                                        final c = _campaigns[idx];
                                        final rem = _remainingUntil(
                                          c['end_time'] as String?,
                                        );
                                        final days = rem['days'];
                                        final remText = rem['text'] as String;
                                        final highlight =
                                            days != null &&
                                            days >= 1 &&
                                            days <= 5;
                                        final canDonate = c['end_time'] != null
                                            ? (DateTime.tryParse(
                                                    c['end_time'],
                                                  )?.isAfter(DateTime.now()) ??
                                                  true)
                                            : true;

                                        return GestureDetector(
                                          onTap: () async {
                                            if (!canDonate) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Donasi ini sudah selesai',
                                                  ),
                                                  backgroundColor:
                                                      Colors.orange,
                                                ),
                                              );
                                              return;
                                            }

                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BerikanDonasiScreen(
                                                      donation: c,
                                                    ),
                                              ),
                                            );

                                            if (result == true) {
                                              _loadCampaigns();
                                            }
                                          },
                                          child: Container(
                                            width: 300,
                                            height: 140,
                                            margin: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                              border: highlight
                                                  ? Border.all(
                                                      color: Colors.redAccent,
                                                      width: 2,
                                                    )
                                                  : null,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 84,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                12,
                                                              ),
                                                          topRight:
                                                              Radius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                    image:
                                                        c['cover_image_url'] !=
                                                            null
                                                        ? DecorationImage(
                                                            image: NetworkImage(
                                                              c['cover_image_url'],
                                                            ),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : null,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 8,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              c['title'] ??
                                                                  'Kegiatan',
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Color(
                                                                  0xFF364057,
                                                                ),
                                                                fontFamily:
                                                                    'CircularStd',
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                              height: 6,
                                                            ),
                                                            Text(
                                                              remText,
                                                              style: TextStyle(
                                                                color: highlight
                                                                    ? Colors
                                                                          .redAccent
                                                                    : Colors
                                                                          .grey[700],
                                                                fontWeight:
                                                                    highlight
                                                                    ? FontWeight
                                                                          .bold
                                                                    : FontWeight
                                                                          .w500,
                                                                fontFamily:
                                                                    'CircularStd',
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      InkWell(
                                                        onTap: () {
                                                          print(
                                                            "[Dashboard] Open campaign ${c['id']}",
                                                          );
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 6,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: const Color(
                                                              0xFF8FA3CC,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            'Donasi',
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12,
                                                                ),
                                                          ),
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
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.75,
                                  ),
                              itemCount: _popularNews.length,
                              itemBuilder: (context, index) {
                                final news = _popularNews[index];
                                return Container(
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
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.image,
                                              color: Colors.grey[600],
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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

            // Bottom Navigation - Using BottomNavBar widget
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
          // Refresh data user setelah kembali dari Atur Profil
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
