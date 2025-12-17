import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/providers/volunteer_event_provider.dart';
import 'package:bersatubantu/fitur/widgets/bottom_navbar.dart';
import 'package:intl/intl.dart';

class MyOngoingEventsScreen extends StatefulWidget {
  const MyOngoingEventsScreen({super.key});

  @override
  State<MyOngoingEventsScreen> createState() => _MyOngoingEventsScreenState();
}

class _MyOngoingEventsScreenState extends State<MyOngoingEventsScreen> {
  final supabase = Supabase.instance.client;
  final int _selectedIndex = 2;
  
  String _selectedTab = 'Berlangsung'; // 'Berlangsung' or 'Selesai'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = supabase.auth.currentUser?.id ?? '';
      if (userId.isNotEmpty) {
        Provider.of<VolunteerEventProvider>(context, listen: false)
            .loadUserOngoingEvents(userId: userId);
      }
    });
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
                    'Lihat daftar kegiatan\nyang sedang diikuti',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
                    // Tab buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _selectedTab = 'Berlangsung');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedTab == 'Berlangsung'
                                    ? const Color(0xFF768BBD)
                                    : Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Berlangsung',
                                style: TextStyle(
                                  color: _selectedTab == 'Berlangsung'
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'CircularStd',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _selectedTab = 'Selesai');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedTab == 'Selesai'
                                    ? const Color(0xFF768BBD)
                                    : Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Selesai',
                                style: TextStyle(
                                  color: _selectedTab == 'Selesai'
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'CircularStd',
                                ),
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
                          if (provider.isLoadingOngoingEvents) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Color(0xFF768BBD)),
                              ),
                            );
                          }

                          List events = [];
                          if (_selectedTab == 'Berlangsung') {
                            events = provider.ongoingEvents
                                .where((e) => e.isActive)
                                .toList();
                          } else {
                            events = provider.ongoingEvents
                                .where((e) => !e.isActive)
                                .toList();
                          }

                          if (events.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_note,
                                    size: 80,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak ada kegiatan',
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
                              return _buildEventCard(event, context);
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
        onTap: (index) {},
      ),
    );
  }

  Widget _buildEventCard(dynamic event, BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');
    final startDate = dateFormat.format(event.eventStartTime);
    final startTime = timeFormat.format(event.eventStartTime);

    return Container(
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
                  event.eventTitle ?? 'Event',
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
                        event.eventLocation ?? 'Lokasi tidak tersedia',
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
                const SizedBox(height: 8),

                // Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: event.status == 'approved'
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.displayStatus,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: event.status == 'approved'
                          ? Colors.green
                          : Colors.orange,
                      fontFamily: 'CircularStd',
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: const BorderSide(
                            color: Color(0xFF768BBD),
                          ),
                        ),
                        child: const Text(
                          'Berlangsung',
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
                        onPressed: () {
                          // Cancel registration logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur pembatalan sedang diatur'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF768BBD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Telah Terdaftar',
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
    );
  }
}