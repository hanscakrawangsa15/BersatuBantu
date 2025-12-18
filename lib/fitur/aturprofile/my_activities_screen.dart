import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/providers/volunteer_event_provider.dart';
import 'package:bersatubantu/models/event_registration_model.dart';
import 'package:intl/intl.dart';

/// Screen untuk menampilkan kegiatan yang sedang dan pernah diikuti user
/// Sesuai dengan fitur [6.14] dan [6.15]
class MyActivitiesScreen extends StatefulWidget {
  const MyActivitiesScreen({super.key});

  @override
  State<MyActivitiesScreen> createState() => _MyActivitiesScreenState();
}

class _MyActivitiesScreenState extends State<MyActivitiesScreen> {
  final supabase = Supabase.instance.client;
  String _selectedTab = 'Berlangsung'; // 'Berlangsung' or 'Selesai'
  bool _isLoading = true;
  List<EventRegistration> _ongoingEvents = [];
  List<EventRegistration> _pastEvents = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllUserEvents();
  }

  Future<void> _loadAllUserEvents() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      setState(() {
        _errorMessage = 'Anda belum login';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<VolunteerEventProvider>(
        context,
        listen: false,
      );

      // Load both ongoing and past events
      await Future.wait([
        provider.loadUserOngoingEvents(userId: userId),
        provider.loadUserPastEvents(userId: userId),
      ]);

      if (mounted) {
        setState(() {
          _ongoingEvents = provider.ongoingEvents;
          _pastEvents = provider.pastEvents;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[MyActivitiesScreen] Error loading events: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat kegiatan: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8FA3CC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8FA3CC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kegiatan Saya',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'CircularStd',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
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
                    Expanded(child: _buildEventsList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF768BBD)),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // Get events based on selected tab
    final events = _selectedTab == 'Berlangsung' ? _ongoingEvents : _pastEvents;

    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAllUserEvents,
      color: const Color(0xFF768BBD),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final isOngoing = _selectedTab == 'Berlangsung';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOngoing ? Icons.event_note : Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            isOngoing
                ? 'Tidak ada kegiatan yang sedang diikuti'
                : 'Tidak ada riwayat kegiatan',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontFamily: 'CircularStd',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isOngoing
                ? 'Daftarkan diri ke kegiatan volunteer\nmelalui menu Aksi'
                : 'Riwayat kegiatan yang pernah\nAnda ikuti akan muncul di sini',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontFamily: 'CircularStd',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAllUserEvents,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Muat Ulang',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF768BBD),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.refresh, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tidak Dapat Memuat Halaman',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'CircularStd',
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Terjadi kesalahan',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontFamily: 'CircularStd',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadAllUserEvents,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF768BBD),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Muat Ulang',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventRegistration event) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final isOngoing = _selectedTab == 'Berlangsung';

    String displayDate = '';
    if (event.eventStartTime != null) {
      displayDate = dateFormat.format(event.eventStartTime!);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: event.coverImageUrl != null
                    ? Image.network(
                        event.coverImageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.volunteer_activism,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.volunteer_activism,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.eventTitle ?? 'Kegiatan',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'CircularStd',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Organization or participants info
                    if (event.organizationName != null) ...[
                      Row(
                        children: [
                          Icon(Icons.people, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.organizationName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'CircularStd',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Location and date
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.red[400],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${event.eventLocation ?? "Lokasi"}, $displayDate',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: 'CircularStd',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status indicator
              Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isOngoing ? 'Berlangsung' : 'Selesai',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOngoing
                              ? const Color(0xFF768BBD)
                              : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontFamily: 'CircularStd',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: isOngoing
                            ? const Color(0xFF768BBD)
                            : Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(EventRegistration event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventDetailModal(event: event),
    );
  }
}

/// Modal untuk menampilkan detail kegiatan
class _EventDetailModal extends StatelessWidget {
  final EventRegistration event;

  const _EventDetailModal({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');

    String displayDate = '';
    String displayTime = '';
    if (event.eventStartTime != null) {
      displayDate = dateFormat.format(event.eventStartTime!);
      displayTime = '${timeFormat.format(event.eventStartTime!)} WIB';
    }
    if (event.eventEndTime != null) {
      displayTime += ' - ${timeFormat.format(event.eventEndTime!)} WIB';
    }

    final isPast =
        event.eventEndTime != null &&
        DateTime.now().isAfter(event.eventEndTime!);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
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
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cover image
              if (event.coverImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    event.coverImageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),

              // Title
              Text(
                event.eventTitle ?? 'Kegiatan',
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
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$displayDate\n$displayTime',
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
                      event.eventLocation ?? 'Lokasi tidak tersedia',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'CircularStd',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Registration status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPast ? Colors.grey[100] : Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPast ? Icons.check_circle : Icons.event_available,
                      color: isPast ? Colors.grey[600] : Colors.green[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPast ? 'Kegiatan Selesai' : 'Anda Terdaftar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPast
                                  ? Colors.grey[700]
                                  : Colors.green[700],
                              fontFamily: 'CircularStd',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isPast
                                ? 'Terima kasih atas partisipasi Anda'
                                : 'Status: ${event.displayStatus}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isPast
                                  ? Colors.grey[600]
                                  : Colors.green[600],
                              fontFamily: 'CircularStd',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF768BBD),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'CircularStd',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
