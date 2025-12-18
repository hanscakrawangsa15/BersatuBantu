import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/fitur/widgets/bottom_navbar.dart';
import 'package:bersatubantu/fitur/postingkegiatandonasi/postingkegiatandonasi.dart';
import 'package:bersatubantu/fitur/berikandonasi/berikandonasi.dart';

class DonasiScreen extends StatefulWidget {
  const DonasiScreen({super.key});

  @override
  State<DonasiScreen> createState() => _DonasiScreenState();
}

class _DonasiScreenState extends State<DonasiScreen> {
  final int _selectedIndex = 1;
  final supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _donations = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  String _selectedCategory = 'Semua';

  final List<String> _filters = ['Semua', 'Aktif', 'Selesai'];
  final List<String> _categories = [
    'Semua',
    'Bencana Alam',
    'Kemiskinan',
    'Hak Asasi',
  ];

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var query = supabase
          .from('donation_campaigns')
          .select('*')
          .order('created_at', ascending: false);

      final response = await query;
      
      // Update status berdasarkan end_time
      final now = DateTime.now();
      final updatedDonations = List<Map<String, dynamic>>.from(response).map((donation) {
        final endTime = DateTime.parse(donation['end_time']);
        if (now.isAfter(endTime) && donation['status'] == 'active') {
          donation['status'] = 'Selesai';
        } else if (donation['status'] == 'active') {
          donation['status'] = 'Aktif';
        }
        return donation;
      }).toList();
      
      setState(() {
        _donations = updatedDonations;
        _isLoading = false;
      });
      
      print('[Donasi] Loaded ${_donations.length} donations');
    } catch (e) {
      print('[Donasi] Error loading donations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredDonations {
    return _donations.where((donation) {
      if (_selectedFilter != 'Semua') {
        final status = donation['status'] ?? 'Aktif';
        if (status != _selectedFilter) return false;
      }
      
      if (_selectedCategory != 'Semua') {
        final category = (donation['category'] ?? '').toString();
        if (category.toLowerCase() != _selectedCategory.toLowerCase()) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  bool _canDonate(Map<String, dynamic> donation) {
    final status = donation['status'] ?? 'Aktif';
    if (status == 'Selesai' || status == 'draft') return false;
    
    final endTime = DateTime.parse(donation['end_time']);
    return DateTime.now().isBefore(endTime);
  }

  // Returns a map with 'text' and 'days' keys describing remaining time
  Map<String, dynamic> _remainingUntil(String? endTimeStr) {
    if (endTimeStr == null) return {'text': 'Tidak tersedia', 'days': null};

    try {
      final end = DateTime.parse(endTimeStr).toLocal();
      final now = DateTime.now();
      final diff = end.difference(now);
      final days = diff.inDays;
      if (diff.isNegative) return {'text': 'Selesai', 'days': days};
      if (days >= 1) return {'text': '$days hari lagi', 'days': days};
      final hours = diff.inHours;
      if (hours >= 1) return {'text': '$hours jam lagi', 'days': 0};
      final minutes = diff.inMinutes;
      return {'text': '$minutes menit lagi', 'days': 0};
    } catch (e) {
      return {'text': 'Tidak tersedia', 'days': null};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8FA3CC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Donasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CircularStd',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement search
                    },
                  ),
                ],
              ),
            ),

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

                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF8FA3CC),
                              ),
                            )
                          : _filteredDonations.isEmpty
                              ? _buildEmptyState()
                              : RefreshIndicator(
                                  onRefresh: _loadDonations,
                                  color: const Color(0xFF8FA3CC),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: _filteredDonations.length,
                                    itemBuilder: (context, index) {
                                      final donation = _filteredDonations[index];
                                      return _buildDonationCard(donation);
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ),

            BottomNavBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                if (index != _selectedIndex) {
                  _navigateToScreen(context, index);
                }
              },
            ),
          ],
        ),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight + 12),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PostingKegiatanDonasiScreen(),
              ),
            );
            
            if (result == true) {
              _loadDonations();
            }
          },
          backgroundColor: const Color(0xFF5A6F8F),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada Donasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: 'CircularStd',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat kegiatan donasi pertama Anda\ndengan menekan tombol +',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'CircularStd',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    final title = donation['title'] ?? 'Untitled';
    final imageUrl = donation['cover_image_url'];
    final targetAmount = donation['target_amount'] ?? 1;
    final collectedAmount = donation['collected_amount'] ?? 0;
    final progress = collectedAmount / targetAmount;
    final canDonate = _canDonate(donation);
    
    return GestureDetector(
      onTap: () async {
        if (canDonate) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BerikanDonasiScreen(donation: donation),
            ),
          );
          
          if (result == true) {
            _loadDonations();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Donasi ini sudah selesai'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                  if (!canDonate)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Selesai',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CircularStd',
                          ),
                        ),
                      ),
                    ),
                  // Remaining time highlight badge when 1..5 days left
                  Builder(builder: (context) {
                    final rem = _remainingUntil(donation['end_time']);
                    final days = rem['days'];
                    final highlight = days != null && days >= 1 && days <= 5 && canDonate;
                    if (!highlight) return const SizedBox.shrink();
                    final label = days > 1 ? '$days hari' : '$days hari';
                    return Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6),
                          ],
                        ),
                        child: Text(
                          '$label tersisa',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'CircularStd',
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF364057),
                        fontFamily: 'CircularStd',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF8FA3CC),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terkumpul: Rp ${_formatNumber(collectedAmount)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'CircularStd',
                          ),
                        ),
                        Text(
                          '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8FA3CC),
                            fontFamily: 'CircularStd',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Remaining time text with optional red highlight
                    Builder(builder: (context) {
                      final rem = _remainingUntil(donation['end_time']);
                      final days = rem['days'];
                      final remText = rem['text'] as String;
                      final highlight = days != null && days >= 1 && days <= 5 && canDonate;
                      return Text(
                        remText,
                        style: TextStyle(
                          fontSize: 12,
                          color: highlight ? Colors.redAccent : Colors.grey[600],
                          fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                          fontFamily: 'CircularStd',
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final value = number is int ? number : (number as num).toInt();
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Filter Status',
          style: TextStyle(fontFamily: 'CircularStd'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filters.map((filter) {
            return RadioListTile<String>(
              title: Text(
                filter,
                style: const TextStyle(fontFamily: 'CircularStd'),
              ),
              value: filter,
              groupValue: _selectedFilter,
              activeColor: const Color(0xFF8FA3CC),
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
          style: TextStyle(fontFamily: 'CircularStd'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _categories.map((category) {
            return RadioListTile<String>(
              title: Text(
                category,
                style: const TextStyle(fontFamily: 'CircularStd'),
              ),
              value: category,
              groupValue: _selectedCategory,
              activeColor: const Color(0xFF8FA3CC),
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
    Navigator.of(context).pop();
  }
}