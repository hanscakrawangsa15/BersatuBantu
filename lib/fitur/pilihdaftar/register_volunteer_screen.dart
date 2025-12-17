import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/providers/volunteer_event_provider.dart';
import 'package:bersatubantu/fitur/widgets/bottom_navbar.dart';
import 'package:bersatubantu/fitur/auth/login/login_screen.dart';
import 'package:intl/intl.dart';

class RegisterVolunteerScreen extends StatefulWidget {
  const RegisterVolunteerScreen({super.key});

  @override
  State<RegisterVolunteerScreen> createState() => _RegisterVolunteerScreenState();
}

class _RegisterVolunteerScreenState extends State<RegisterVolunteerScreen> {
  final supabase = Supabase.instance.client;
  final int _selectedIndex = 2; // For bottom navbar
  
  String _selectedCity = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _cities = [
    'Semua',
    'Jakarta',
    'Bandung',
    'Surabaya',
    'Medan',
    'Semarang',
    'Makassar',
    'Palembang',
    'Yogyakarta',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VolunteerEventProvider>(context, listen: false).loadOpenEvents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final provider = Provider.of<VolunteerEventProvider>(context, listen: false);
    provider.filterEvents(
      city: _selectedCity == 'Semua' ? null : _selectedCity,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
    );
  }

  void _showEventDetail(String eventId) {
    final userId = supabase.auth.currentUser?.id ?? '';
    final provider = Provider.of<VolunteerEventProvider>(context, listen: false);
    provider.loadEventDetails(eventId: eventId, userId: userId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EventDetailBottomSheet(
        eventId: eventId,
        userId: userId,
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
                    'Mendaftarkan Diri',
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
                      // Search icon functionality
                    },
                  ),
                ],
              ),
            ),

            // Main content
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
                    // Filter and Category
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Filter button
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: PopupMenuButton<String>(
                                    itemBuilder: (BuildContext context) {
                                      return _cities.map((String city) {
                                        return PopupMenuItem<String>(
                                          value: city,
                                          child: Text(city),
                                        );
                                      }).toList();
                                    },
                                    onSelected: (String city) {
                                      setState(() {
                                        _selectedCity = city;
                                      });
                                      _applyFilters();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.tune,
                                            color: Color(0xFF768BBD),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Filter',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'CircularStd',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Category display
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.category,
                                          color: Colors.grey[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _selectedCity,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'CircularStd',
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Search field
                          TextField(
                            controller: _searchController,
                            onChanged: (_) => _onSearchChanged(),
                            decoration: InputDecoration(
                              hintText: 'Cari kegiatan...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Events list
                    Expanded(
                      child: Consumer<VolunteerEventProvider>(
                        builder: (context, provider, _) {
                          final events = _searchQuery.isEmpty
                              ? provider.openEvents
                              : provider.filteredEvents;

                          if (provider.isLoadingOpenEvents ||
                              provider.isLoadingFilteredEvents) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Color(0xFF768BBD)),
                              ),
                            );
                          }

                          if (events.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 80,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak ada event ditemukan',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                      fontFamily: 'CircularStd',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return _buildEventCard(event);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          // Navigation logic
        },
      ),
    );
  }

  Widget _buildEventCard(dynamic event) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');
    final startDate = dateFormat.format(event.startTime);
    final startTime = timeFormat.format(event.startTime);

    return GestureDetector(
      onTap: () => _showEventDetail(event.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: event.coverImageUrl != null
                  ? Image.network(
                      event.coverImageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),

            // Event info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CircularStd',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Organization
                  Row(
                    children: [
                      const Icon(Icons.business, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        event.organizationName ?? 'Organisasi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontFamily: 'CircularStd',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Date and time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$startDate $startTime WIB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontFamily: 'CircularStd',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location ?? event.city ?? 'Lokasi tidak tersedia',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontFamily: 'CircularStd',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showEventDetail(event.id),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            side: const BorderSide(
                              color: Color(0xFF768BBD),
                            ),
                          ),
                          child: const Text(
                            'Bagikan',
                            style: TextStyle(
                              color: Color(0xFF768BBD),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'CircularStd',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showEventDetail(event.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF768BBD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Jadi Volunteer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'CircularStd',
                            ),
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
  }
}

// Event Detail Bottom Sheet
class EventDetailBottomSheet extends StatefulWidget {
  final String eventId;
  final String userId;

  const EventDetailBottomSheet({
    super.key,
    required this.eventId,
    required this.userId,
  });

  @override
  State<EventDetailBottomSheet> createState() => _EventDetailBottomSheetState();
}

class _EventDetailBottomSheetState extends State<EventDetailBottomSheet> {
  bool _isRegistering = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<VolunteerEventProvider>(
      builder: (context, provider, _) {
        final event = provider.selectedEvent;

        if (event == null) {
          return const SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF768BBD)),
              ),
            ),
          );
        }

        final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
        final timeFormat = DateFormat('HH:mm', 'id_ID');
        final startDate = dateFormat.format(event.startTime);
        final endDate = dateFormat.format(event.endTime);
        final startTime = timeFormat.format(event.startTime);
        final endTime = timeFormat.format(event.endTime);

        return SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detail Kegiatan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'CircularStd',
                        ),
                      ),
                      Row(children: [
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () async {
                            // Copy basic event info to clipboard as a simple share fallback
                            final event = provider.selectedEvent;
                            if (event != null) {
                              final text = '${event.title}\n${event.description ?? ''}';
                              await Clipboard.setData(ClipboardData(text: text));
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Detail kegiatan disalin ke clipboard')),
                                );
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ])
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cover image
                  if (event.coverImageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        event.coverImageUrl!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 250,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CircularStd',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Organization
                  Row(
                    children: [
                      const Icon(Icons.business, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        event.organizationName ?? 'Organisasi',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'CircularStd',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Date and time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$startDate - $endDate\n$startTime - $endTime WIB',
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'CircularStd',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location ?? event.city ?? 'Lokasi tidak tersedia',
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'CircularStd',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (event.description != null && event.description!.isNotEmpty) ...[
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'CircularStd',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'CircularStd',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Quota info
                  if (event.quota != null)
                    Text(
                      'Kuota: ${event.registeredCount ?? 0}/${event.quota}',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'CircularStd',
                        color: Colors.grey[700],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Register button
                  if (widget.userId.isEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (c) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF768BBD),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Masuk untuk mendaftar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'CircularStd',
                          ),
                        ),
                      ),
                    )
                  else if (!provider.isUserRegistered)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isRegistering
                            ? null
                            : () async {
                                setState(() => _isRegistering = true);
                                final success = await provider.registerForEvent(
                                  eventId: event.id,
                                  userId: widget.userId,
                                );
                                setState(() => _isRegistering = false);

                                if (success) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Berhasil mendaftar!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(provider.lastMessage ??
                                            'Gagal mendaftar event'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF768BBD),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _isRegistering
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Daftar Sekarang',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'CircularStd',
                                ),
                              ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Text(
                          'Anda Sudah Terdaftar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontFamily: 'CircularStd',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}