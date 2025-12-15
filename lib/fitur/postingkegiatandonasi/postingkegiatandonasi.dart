import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:typed_data';

class PostingKegiatanDonasiScreen extends StatefulWidget {
  const PostingKegiatanDonasiScreen({super.key});

  @override
  State<PostingKegiatanDonasiScreen> createState() => _PostingKegiatanDonasiScreenState();
}

class _PostingKegiatanDonasiScreenState extends State<PostingKegiatanDonasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  File? _selectedImage;
  Uint8List? _imageBytes;
  String? _imageUrl;
  bool _isLoading = false;
  bool _isSavingDraft = false;
  DateTime? _selectedEndDate;
  
  // Location data
  double? _latitude;
  double? _longitude;
  String? _locationName;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
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
    } catch (e) {
      print('[PostingDonasi] Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _ensureOrganizationExists(String userId) async {
    try {
      final response = await supabase
          .from('organizations')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        final user = supabase.auth.currentUser!;
        await supabase.from('organizations').insert({
          'id': userId,
          'name': user.userMetadata?['name'] ?? 'Organization',
          'email': user.email,
          'created_at': DateTime.now().toIso8601String(),
        });
        print('[PostingDonasi] Organization created for user: $userId');
      }
    } catch (e) {
      print('[PostingDonasi] Error ensuring organization: $e');
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageBytes == null && _selectedImage == null) return null;

    try {
      print('[PostingDonasi] Uploading image...');
      
      Uint8List bytes;
      String fileExt;
      
      if (kIsWeb) {
        bytes = _imageBytes!;
        fileExt = 'jpg';
      } else {
        bytes = await _selectedImage!.readAsBytes();
        fileExt = _selectedImage!.path.split('.').last;
      }
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'donations/$fileName';

      try {
        await supabase.storage.from('donations').uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$fileExt',
            upsert: false,
          ),
        );
      } on StorageException catch (e) {
        if (e.statusCode == '404') {
          throw 'Bucket "donations" tidak ditemukan. Silakan buat bucket di Supabase Storage terlebih dahulu.';
        }
        rethrow;
      }

      final imageUrl = supabase.storage.from('donations').getPublicUrl(filePath);
      print('[PostingDonasi] Image uploaded: $imageUrl');
      
      return imageUrl;
    } catch (e) {
      print('[PostingDonasi] Error uploading image: $e');
      if (e is String) {
        throw e;
      }
      throw 'Gagal mengupload gambar: ${e.toString()}';
    }
  }

  Future<void> _saveDraft() async {
    setState(() {
      _isSavingDraft = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw 'Anda harus login terlebih dahulu';
      }

      await _ensureOrganizationExists(user.id);

      String? imageUrl;
      if (_imageBytes != null || _selectedImage != null) {
        imageUrl = await _uploadImage();
      }

      final targetAmount = _targetAmountController.text.trim().isEmpty
          ? 0
          : int.parse(_targetAmountController.text.replaceAll('.', ''));

      final endTime = _selectedEndDate ?? DateTime.now().add(const Duration(days: 30));

      await supabase.from('donation_campaigns').insert({
        'organization_id': user.id,
        'title': _titleController.text.trim().isEmpty 
            ? 'Draft' 
            : _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'target_amount': targetAmount,
        'collected_amount': 0,
        'cover_image_url': imageUrl,
        'status': 'draft',
        'start_time': DateTime.now().toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'latitude': _latitude,
        'longitude': _longitude,
        'location_name': _locationName,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('[PostingDonasi] Error saving draft: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan draft: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingDraft = false;
        });
      }
    }
  }

  Future<void> _postDonation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal berakhir donasi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw 'Anda harus login terlebih dahulu';
      }

      await _ensureOrganizationExists(user.id);

      String? imageUrl;
      if (_imageBytes != null || _selectedImage != null) {
        imageUrl = await _uploadImage();
      }

      final targetAmount = int.parse(_targetAmountController.text.replaceAll('.', ''));

      await supabase.from('donation_campaigns').insert({
        'organization_id': user.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'target_amount': targetAmount,
        'collected_amount': 0,
        'cover_image_url': imageUrl,
        'status': 'active',
        'start_time': DateTime.now().toIso8601String(),
        'end_time': _selectedEndDate!.toIso8601String(),
        'latitude': _latitude,
        'longitude': _longitude,
        'location_name': _locationName,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('[PostingDonasi] Donation posted successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kegiatan donasi berhasil diposting!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('[PostingDonasi] Error posting donation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memposting: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: _isSavingDraft ? null : _saveDraft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAF6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _isSavingDraft
                      ? const SizedBox(
                          width: 40,
                          height: 16,
                          child: Center(
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF5E72E4),
                                ),
                              ),
                            ),
                          ),
                        )
                      : const Text(
                          'Draft',
                          style: TextStyle(
                            color: Color(0xFF5E72E4),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CircularStd',
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
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

                // Target Donasi
                const Text(
                  'Target Donasi (Rp)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF364057),
                    fontFamily: 'CircularStd',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _targetAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandsSeparatorInputFormatter(),
                  ],
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'CircularStd',
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixText: 'Rp ',
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
                      return 'Target donasi tidak boleh kosong';
                    }
                    final amount = int.tryParse(value.replaceAll('.', ''));
                    if (amount == null || amount <= 0) {
                      return 'Target donasi harus lebih dari 0';
                    }
                    return null;
                  },
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

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF8FA3CC),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Keluar & Simpan',
                            style: TextStyle(
                              color: Color(0xFF8FA3CC),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'CircularStd',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _postDonation,
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
                                  'Post',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'CircularStd',
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
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
            child: GoogleMap(
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
            ),
          ),
        ],
      ),
    );
  }
}

// Input Formatter untuk ribuan separator
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll('.', ''));
    if (number == null) {
      return oldValue;
    }

    final formattedText = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}