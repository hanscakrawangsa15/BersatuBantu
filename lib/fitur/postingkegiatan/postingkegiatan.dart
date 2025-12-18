import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../../utils/place_service.dart';
import '../../utils/maps_availability.dart';
import 'dart:async';

class PostingKegiatanScreen extends StatefulWidget {
    final int requestId;

  const PostingKegiatanScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<PostingKegiatanScreen> createState() => _PostingKegiatanScreenState();
}

class _PostingKegiatanScreenState extends State<PostingKegiatanScreen> {
    final _formKey = GlobalKey<FormState>();
    final supabase = Supabase.instance.client;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  File? _selectedImage;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  
  // Location data
  double? _latitude;
  double? _longitude;
  String? _locationName;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectStartDate() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now;
    final DateTime lastDate = now.add(const Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8FA3CC),
              onPrimary: Colors.white,
              onSurface: Color(0xFF364057),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = DateTime(picked.year, picked.month, picked.day, 0, 0, 0);
      });
    }
  }

  // ===== PICK IMAGE =====
  Future<void> _selectEndDate() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now.add(const Duration(days: 1));
    final DateTime lastDate = now.add(const Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8FA3CC),
              onPrimary: Colors.white,
              onSurface: Color(0xFF364057),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedEndDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      });
    }
  }

  Future<void> _pickLocation() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan.';
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      // Navigate to map picker
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationPickerScreen(
            initialPosition: LatLng(position.latitude, position.longitude),
          ),
        ),
      );

      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _latitude = result['latitude'];
          _longitude = result['longitude'];
          _locationName = result['locationName'];
          _locationController.text = _locationName ?? 'Lokasi dipilih';
        });
      }
    } catch (e) {
      print('[PostingDonasi] Error picking location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih lokasi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        if (!kIsWeb) {
          _selectedImage = File(image.path);
        }
        _imageBytes = bytes;
      });
    }
  }

  // ===== UPLOAD IMAGE =====
  Future<String?> _uploadImage() async {
    if (_imageBytes == null && _selectedImage == null) return null;

    final bytes = kIsWeb
        ? _imageBytes!
        : await _selectedImage!.readAsBytes();

    final fileName = 'aksi_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'postingaksi/$fileName';

    await supabase.storage.from('postingaksi').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: false),
    );

    return supabase.storage.from('postingaksi').getPublicUrl(path);
  }

  // ===== POST KEGIATAN =====
  Future<void> _postKegiatan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {

        

        final imageUrl = await _uploadImage();
    

      // Validate that the provided requestId exists and is approved in organization_request
        if (widget.requestId <= 0) {
        throw 'Tidak ada request ID. Pastikan Anda sudah login atau kirimkan requestId yang valid.';
        } 
        final orgCheck = await supabase
        .from('organization_request')
        .select('request_id')
        .eq('request_id', widget.requestId)
        .eq('status', 'approve')
        .maybeSingle();


      // debug log
      print('[PostingKegiatan] organization_request check: $orgCheck');

      if (orgCheck == null) {
        throw 'Organisasi tidak ditemukan atau belum disetujui (status != approve).';
      }
      final requestId = orgCheck['request_id'] as int;

      // Insert to events table using request_id as organization_id
      await supabase.from('events').insert({
        // 'organization_id': requestId.toString(),
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'cover_image_url': imageUrl,
        'status': 'open',
        'category': 'volunteer',
        'created_at': DateTime.now().toIso8601String(),
        'start_time': (_selectedStartDate ?? DateTime.now()).toIso8601String(),
        'end_time': _selectedEndDate!.toIso8601String(),
        'location': _locationName ?? ((_latitude != null && _longitude != null) ? 'Lat: $_latitude, Lng: $_longitude' : null),
        'city': _locationName,
      });


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kegiatan berhasil diposting'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal posting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF364057)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Posting Kegiatan',
          style: TextStyle(
            color: Color(0xFF364057),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'CircularStd',
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul
                const Text(
                  'Judul',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF364057),
                    fontFamily: 'CircularStd',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'CircularStd',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Judul',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'CircularStd',
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Deskripsi
                const Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF364057),
                    fontFamily: 'CircularStd',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 6,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'CircularStd',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Deskripsi',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'CircularStd',
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Tanggal Mulai
                const Text(
                  'Tanggal Mulai',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF364057),
                    fontFamily: 'CircularStd',
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectStartDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedStartDate == null
                              ? 'Pilih tanggal mulai'
                              : _formatDate(_selectedStartDate!),
                          style: TextStyle(
                            fontSize: 15,
                            color: _selectedStartDate == null
                                ? Colors.grey[400]
                                : const Color(0xFF364057),
                            fontFamily: 'CircularStd',
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tanggal Berakhir
                const Text(
                  'Tanggal Berakhir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF364057),
                    fontFamily: 'CircularStd',
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectEndDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedEndDate == null
                              ? 'Pilih tanggal berakhir'
                              : _formatDate(_selectedEndDate!),
                          style: TextStyle(
                            fontSize: 15,
                            color: _selectedEndDate == null
                                ? Colors.grey[400]
                                : const Color(0xFF364057),
                            fontFamily: 'CircularStd',
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Lokasi (Optional)
                Row(
                  children: [
                    const Text(
                      'Lokasi Kejadian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF364057),
                        fontFamily: 'CircularStd',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(Opsional)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'CircularStd',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _latitude != null ? const Color(0xFF8FA3CC) : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _locationController.text.isEmpty
                                ? 'Pilih lokasi di peta'
                                : _locationController.text,
                            style: TextStyle(
                              fontSize: 15,
                              color: _locationController.text.isEmpty
                                  ? Colors.grey[400]
                                  : const Color(0xFF364057),
                              fontFamily: 'CircularStd',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: _latitude != null 
                              ? const Color(0xFF8FA3CC) 
                              : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Unggah Gambar
                const Text(
                  'Unggah',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF364057),
                    fontFamily: 'CircularStd',
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: _imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 32,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Pilih Gambar',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontFamily: 'CircularStd',
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 40),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _postKegiatan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E72E4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Post Kegiatan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'CircularStd',
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Location Picker Screen
class LocationPickerScreen extends StatefulWidget {
  final LatLng initialPosition;

  const LocationPickerScreen({
    super.key,
    required this.initialPosition,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController _mapController;
  late LatLng _selectedPosition;
  final Set<Marker> _markers = {};
  String? _resolvedAddress;
  bool _isResolvingAddress = false;
  bool _isInjectingMap = false;

  // Search/autocomplete
  final _searchController = TextEditingController();
  final _placeService = PlaceService();
  List<PlaceSuggestion> _suggestions = [];
  bool _isSearching = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    _markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: _selectedPosition,
      ),
    );
    // Resolve initial position to a human-readable address
    _resolveAddress(_selectedPosition);

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final text = _searchController.text.trim();
    _searchDebounce?.cancel();
    if (text.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() {
        _isSearching = true;
      });
      try {
        final res = await _placeService.autocomplete(text);
        setState(() {
          _suggestions = res;
        });
        if (res.isEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ditemukan hasil. Periksa konfigurasi API key dan aktifkan Places API.')),
          );
        }
      } catch (e) {
        print('[LocationPicker] Autocomplete error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mencari tempat. Periksa koneksi dan konfigurasi API key.')),
          );
        }
      } finally {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
        ),
      );
    });
    _resolveAddress(position);
  }

  Future<void> _resolveAddress(LatLng pos) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      setState(() {
        _resolvedAddress = null;
        _isResolvingAddress = false;
      });
      return;
    }

    setState(() {
      _isResolvingAddress = true;
      _resolvedAddress = null;
    });

    try {
      final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=${pos.latitude},${pos.longitude}&key=$apiKey');
      final resp = await http.get(url).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          setState(() {
            _resolvedAddress = results[0]['formatted_address'] as String?;
          });
          return;
        }
      }
    } catch (e) {
      print('[LocationPicker] Error resolving address: $e');
    } finally {
      setState(() {
        _isResolvingAddress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8FA3CC),
        title: const Text(
          'Pilih Lokasi',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'CircularStd',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'latitude': _selectedPosition.latitude,
                'longitude': _selectedPosition.longitude,
                'locationName': _resolvedAddress ?? 'Lat: ${_selectedPosition.latitude.toStringAsFixed(6)}, Lng: ${_selectedPosition.longitude.toStringAsFixed(6)}',
              });
            },
            child: const Text(
              'Pilih',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'CircularStd',
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search box for places
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari kota atau lokasi...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty || _isSearching)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              final s = _suggestions[index];
                              return ListTile(
                                title: Text(s.description),
                                onTap: () async {
                                  // fetch place details
                                  final details = await _placeService.getPlaceDetails(s.placeId);
                                  if (details != null) {
                                    final loc = details['geometry']?['location'];
                                    if (loc != null) {
                                      final lat = (loc['lat'] as num).toDouble();
                                      final lng = (loc['lng'] as num).toDouble();
                                      setState(() {
                                        _selectedPosition = LatLng(lat, lng);
                                        _markers.clear();
                                        _markers.add(Marker(markerId: const MarkerId('selected_location'), position: _selectedPosition));
                                        _resolvedAddress = details['formatted_address'] as String? ?? details['name'] as String?;
                                        _suggestions = [];
                                        _searchController.text = _resolvedAddress ?? '';
                                      });
                                      // move camera if map loaded
                                      try {
                                        _mapController.animateCamera(CameraUpdate.newLatLng(_selectedPosition));
                                      } catch (_) {}
                                    }
                                  }
                                },
                              );
                            },
                          ),
                  ),
              ],
            ),
          ),

          // Address display
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.place, color: Color(0xFF8FA3CC)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _isResolvingAddress
                        ? Row(
                            children: const [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Mencari alamat...'),
                            ],
                          )
                        : Text(
                            _resolvedAddress ?? 'Lat: ${_selectedPosition.latitude.toStringAsFixed(6)}, Lng: ${_selectedPosition.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: isGoogleMapsAvailable()
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _selectedPosition,
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                        _mapController = controller;
                    },
                    onTap: _onMapTapped,
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  )
                : _buildMapsNotLoadedPlaceholder(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapsNotLoadedPlaceholder() {
    return Container(
      color: Colors.red[900],
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.yellow, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Google Maps tidak dimuat pada web. Tambahkan script Google Maps JavaScript API pada file web/index.html dan reload.',
            style: TextStyle(color: Colors.yellow),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _isInjectingMap
              ? const CircularProgressIndicator(color: Colors.white)
              : ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isInjectingMap = true;
                    });
                    try {
                      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
                      final loaded = await injectGoogleMapsScript(apiKey);
                      if (loaded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Google Maps berhasil dimuat. Jika peta belum muncul, tekan kembali atau reload halaman.')),
                        );
                        setState(() {});
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Gagal memuat Google Maps. Tambahkan script ke web/index.html dan isi API key Anda.')),
                        );
                      }
                    } finally {
                      setState(() {
                        _isInjectingMap = false;
                      });
                    }
                  },
                  child: const Text('Petunjuk setup'),
                ),
        ],
      ),
    );
  }
}
