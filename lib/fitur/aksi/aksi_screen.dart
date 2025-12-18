import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:bersatubantu/providers/volunteer_event_provider.dart';
import 'package:bersatubantu/fitur/pilihdaftar/register_volunteer_screen.dart'
    show EventDetailBottomSheet;
import 'package:bersatubantu/fitur/postingkegiatandonasi/postingkegiatandonasi.dart';
import 'package:bersatubantu/fitur/widgets/bottom_navbar.dart';
import 'package:bersatubantu/fitur/dashboard/dashboard_screen.dart';
import 'package:bersatubantu/fitur/donasi/donasi_screen.dart';
import 'package:bersatubantu/fitur/aturprofile/aturprofile.dart';

class AksiScreen extends StatefulWidget {
  /// If true, always show the FAB for posting events (used by organization dashboard)
  final bool forceOrganizationMode;
  
  const AksiScreen({super.key, this.forceOrganizationMode = false});

  @override
  State<AksiScreen> createState() => _AksiScreenState();
}

class _AksiScreenState extends State<AksiScreen> {
  final int _selectedIndex = 2; // Aksi menu index
  final supabase = Supabase.instance.client;
  bool _isOrganization = false;
  String _selectedFilter = 'Semua';
  String _selectedCategory = 'Semua';

  final List<String> _filters = ['Semua', 'Aktif', 'Selesai'];
  final List<String> _categories = [
    'Semua',
    'Bencana Alam',
    'Pendidikan',
    'Kesehatan',
    'Kemiskinan',
  ];

  @override
  void initState() {
    super.initState();
    // If forceOrganizationMode is true, set _isOrganization directly
    if (widget.forceOrganizationMode) {
      _isOrganization = true;
    } else {
      _loadUserRole();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VolunteerEventProvider>(
        context,
        listen: false,
      ).loadOpenEvents();
    });
  }

  Future<void> _loadUserRole() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final resp = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      final role = resp == null ? null : (resp['role'] as String?);
      if (mounted) {
        setState(() {
          _isOrganization = (role == 'organization');
        });
      }
    } catch (e) {
      // ignore errors; default to non-organization
      if (mounted) {
        setState(() {
          _isOrganization = false;
        });
      }
    }
  }

  void _openEventDetail(String eventId) {
    final userId = supabase.auth.currentUser?.id ?? '';
    final provider = Provider.of<VolunteerEventProvider>(
      context,
      listen: false,
    );
    provider.loadEventDetails(eventId: eventId, userId: userId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => EventDetailBottomSheet(eventId: eventId, userId: userId),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Filter Status',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'CircularStd',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filters.map((filter) {
            return RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: _selectedFilter,
              activeColor: const Color(0xFF768BBD),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Pilih Kategori',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'CircularStd',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _categories.map((category) {
            return RadioListTile<String>(
              title: Text(category),
              value: category,
              groupValue: _selectedCategory,
              activeColor: const Color(0xFF768BBD),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    if (index == _selectedIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const DashboardScreen();
        break;
      case 1:
        screen = const DonasiScreen();
        break;
      case 2:
        return; // Already on Aksi
      case 3:
        screen = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF8FA3CC)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF364057),
                fontFamily: 'CircularStd',
              ),
            ),
          ],
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
                children: [
                  const Text(
                    'Aksi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CircularStd',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Main content area
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
                    // Filter and Category buttons
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildFilterButton(
                              icon: Icons.filter_list_rounded,
                              label: 'Filter',
                              onTap: () => _showFilterDialog(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFilterButton(
                              icon: Icons.category_rounded,
                              label: 'Category',
                              onTap: () => _showCategoryDialog(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Events list
                    Expanded(
                      child: Consumer<VolunteerEventProvider>(
                        builder: (context, provider, _) {
                          if (provider.isLoadingOpenEvents) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF768BBD),
                                ),
                              ),
                            );
                          }

                          // Filter events based on selected filters
                          final allEvents = provider.openEvents;
                          final filteredEvents = allEvents.where((e) {
                            // Filter by status
                            if (_selectedFilter != 'Semua') {
                              final now = DateTime.now();
                              final isCompleted = e.endTime.isBefore(now);

                              if (_selectedFilter == 'Aktif' && isCompleted)
                                return false;
                              if (_selectedFilter == 'Selesai' && !isCompleted)
                                return false;
                            }

                            // Filter by category (search in title, description)
                            if (_selectedCategory != 'Semua') {
                              final title = e.title.toLowerCase();
                              final description = (e.description ?? '')
                                  .toLowerCase();
                              final city = (e.city ?? '').toLowerCase();
                              final searchTerm = _selectedCategory
                                  .toLowerCase();

                              if (!title.contains(searchTerm) &&
                                  !description.contains(searchTerm) &&
                                  !city.contains(searchTerm)) {
                                return false;
                              }
                            }

                            return true;
                          }).toList();

                          if (filteredEvents.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.volunteer_activism_outlined,
                                    size: 80,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Belum ada Kegiatan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                      fontFamily: 'CircularStd',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Kegiatan volunteer akan muncul di sini',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                      fontFamily: 'CircularStd',
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () => provider.loadOpenEvents(),
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Muat Ulang',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF768BBD),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () => provider.loadOpenEvents(),
                            color: const Color(0xFF768BBD),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: filteredEvents.length,
                              itemBuilder: (context, idx) {
                                final e = filteredEvents[idx];
                                return GestureDetector(
                                  onTap: () => _openEventDetail(e.id),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey[300]!,
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                          child: e.coverImageUrl != null
                                              ? Image.network(
                                                  e.coverImageUrl!,
                                                  height: 180,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          height: 180,
                                                          color:
                                                              Colors.grey[200],
                                                          child: Icon(
                                                            Icons.image,
                                                            size: 50,
                                                            color: Colors
                                                                .grey[400],
                                                          ),
                                                        );
                                                      },
                                                )
                                              : Container(
                                                  height: 180,
                                                  color: Colors.grey[200],
                                                  child: Icon(
                                                    Icons.volunteer_activism,
                                                    size: 50,
                                                    color: Colors.grey[400],
                                                  ),
                                                ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                e.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'CircularStd',
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_today,
                                                    size: 14,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(e.startTime)} WIB',
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on,
                                                    size: 14,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      e.location ??
                                                          e.city ??
                                                          'Lokasi tidak tersedia',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            BottomNavBar(
              currentIndex: _selectedIndex,
              onTap: (index) => _navigateToScreen(context, index),
            ),
          ],
        ),
      ),

      // FAB only for organization users
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _isOrganization
          ? Padding(
              padding: const EdgeInsets.only(
                bottom: kBottomNavigationBarHeight + 12,
              ),
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PostingKegiatanDonasiScreen(),
                    ),
                  );

                  if (result == true) {
                    Provider.of<VolunteerEventProvider>(
                      context,
                      listen: false,
                    ).loadOpenEvents();
                  }
                },
                backgroundColor: const Color(0xFF5A6F8F),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            )
          : null,
    );
  }
}
