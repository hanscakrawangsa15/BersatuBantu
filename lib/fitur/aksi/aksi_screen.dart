import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:bersatubantu/providers/volunteer_event_provider.dart';
import 'package:bersatubantu/fitur/pilihdaftar/register_volunteer_screen.dart' show EventDetailBottomSheet;
import 'package:bersatubantu/fitur/postingkegiatan/postingkegiatan.dart';
import 'package:bersatubantu/fitur/widgets/bottom_navbar.dart';

class AksiScreen extends StatefulWidget {
  final int requestId;

  const AksiScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<AksiScreen> createState() => _AksiScreenState();
}

class _AksiScreenState extends State<AksiScreen> {
  final supabase = Supabase.instance.client;
  int _selectedIndex = 2; // misal: 0=Home, 1=Donasi, 2=Aksi

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/donasi');
        break;
      case 2:
        // Aksi (current)
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VolunteerEventProvider>(context, listen: false).loadOpenEvents();
    });
  }

  void _openEventDetail(String eventId) {
    final userId = '';
    final provider = Provider.of<VolunteerEventProvider>(context, listen: false);
    provider.loadEventDetails(eventId: eventId, userId: userId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => EventDetailBottomSheet(eventId: eventId, userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8FA3CC),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF768BBD),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => PostingKegiatanScreen(
                requestId: widget.requestId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
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

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Consumer<VolunteerEventProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoadingOpenEvents) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF768BBD)),
                        ),
                      );
                    }

                    final events = provider.openEvents;
                    if (events.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text('Tidak Dapat Memuat Halaman', style: TextStyle(color: Colors.grey[700])),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => provider.loadOpenEvents(),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF768BBD)),
                              child: const Text('Muat Ulang'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length,
                      itemBuilder: (context, idx) {
                        final e = events[idx];
                        return GestureDetector(
                          onTap: () => _openEventDetail(e.id),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 8, offset: const Offset(0,2))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                  child: e.coverImageUrl != null
                                      ? Image.network(e.coverImageUrl!, height: 160, width: double.infinity, fit: BoxFit.cover)
                                      : Container(height: 160, color: Colors.grey[200]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'CircularStd')),
                                      const SizedBox(height: 8),
                                      Row(children: [const Icon(Icons.calendar_today, size:14,color:Colors.grey), const SizedBox(width:6), Text(DateFormat('dd MMM yyyy HH:mm','id_ID').format(e.startTime) + ' WIB', style: TextStyle(color: Colors.grey[700], fontSize: 12))]),
                                      const SizedBox(height:6),
                                      Row(children: [const Icon(Icons.location_on,size:14,color:Colors.grey), const SizedBox(width:6), Expanded(child: Text(e.location ?? e.city ?? 'Lokasi tidak tersedia', maxLines:1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700], fontSize:12)))])
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}