import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/maps_availability.dart';
import 'dart:convert';

class BerikanDonasiScreen extends StatefulWidget {
  final Map<String, dynamic> donation;

  const BerikanDonasiScreen({
    super.key,
    required this.donation,
  });

  @override
  State<BerikanDonasiScreen> createState() => _BerikanDonasiScreenState();
}

class _BerikanDonasiScreenState extends State<BerikanDonasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isAnonymous = false;
  bool _isLoading = false;
  String _selectedPaymentMethod = 'OVO';
  String _donationType = 'uang'; // 'uang' atau 'barang'

  final List<String> _paymentMethods = ['OVO', 'ShopeePay', 'GoPay'];

  // Map related
  LatLng? _campaignPosition;
  final Set<Marker> _mapMarkers = {};
  GoogleMapController? _mapController;
  String? _campaignLocationName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _extractCampaignLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.userMetadata?['name'] ?? '';
        _emailController.text = user.email ?? '';
      });
    }
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final value = number is int ? number : (number as num).toInt();
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  int _getDaysRemaining() {
    final endTime = DateTime.parse(widget.donation['end_time']);
    final now = DateTime.now();
    final difference = endTime.difference(now);
    return difference.inDays;
  }

  void _extractCampaignLocation() {
    try {
      final loc = widget.donation['location'];
      double? lat;
      double? lng;

      if (loc == null) {
        // possible we still have a human-readable location name
        final ln = widget.donation['location_name'];
        if (ln != null) {
          _campaignLocationName = ln.toString();
        }
        final maybeLat = widget.donation['latitude'] ?? widget.donation['lat'];
        final maybeLng = widget.donation['longitude'] ?? widget.donation['lng'];
        if (maybeLat != null && maybeLng != null) {
          lat = double.tryParse(maybeLat.toString());
          lng = double.tryParse(maybeLng.toString());
        }
      } else if (loc is Map) {
        final dynamic maybeLat = loc['lat'] ?? loc['latitude'] ?? (loc['location'] != null ? loc['location']['lat'] : null);
        final dynamic maybeLng = loc['lng'] ?? loc['longitude'] ?? (loc['location'] != null ? loc['location']['lng'] : null);
        lat = maybeLat is num ? maybeLat.toDouble() : double.tryParse(maybeLat?.toString() ?? '');
        lng = maybeLng is num ? maybeLng.toDouble() : double.tryParse(maybeLng?.toString() ?? '');
      } else if (loc is String) {
        try {
          final parsed = jsonDecode(loc) as Map<String, dynamic>;
          final maybeLat = parsed['lat'] ?? parsed['latitude'];
          final maybeLng = parsed['lng'] ?? parsed['longitude'];
          lat = maybeLat is num ? maybeLat.toDouble() : double.tryParse(maybeLat?.toString() ?? '');
          lng = maybeLng is num ? maybeLng.toDouble() : double.tryParse(maybeLng?.toString() ?? '');
        } catch (_) {
          // ignore
        }
      }

      if (lat != null && lng != null) {
        final pos = LatLng(lat, lng);
        setState(() {
          _campaignPosition = pos;
          _mapMarkers.clear();
          _mapMarkers.add(Marker(
            markerId: const MarkerId('campaign_location'),
            position: pos,
            infoWindow: InfoWindow(title: _campaignLocationName ?? widget.donation['title']?.toString() ?? 'Lokasi'),
          ));
          // read location_name if present
          final ln = widget.donation['location_name'] ?? loc is Map ? (loc['name'] ?? loc['location_name']) : null;
          _campaignLocationName = ln?.toString();
        });
        // If map controller already exists, animate to the campaign location
        if (_mapController != null) {
          try {
            _mapController!.animateCamera(CameraUpdate.newLatLng(pos));
          } catch (_) {}
        }
      }
    } catch (e) {
      print('[BerikanDonasi] Error extracting location: $e');
    }
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi khusus untuk donasi uang
    if (_donationType == 'uang' && _amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal donasi tidak boleh kosong'),
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

      final amount = _donationType == 'uang'
          ? int.parse(_amountController.text.replaceAll('.', ''))
          : 0;

      // Insert donation transaction
      await supabase.from('donation_transactions').insert({
        'campaign_id': widget.donation['id'],
        'donor_id': user.id,
        'donor_name': _isAnonymous ? 'Anonim' : _nameController.text.trim(),
        'donor_email': _emailController.text.trim(),
        'amount': amount,
        'donation_type': _donationType,
        'payment_method': _donationType == 'uang' ? _selectedPaymentMethod : null,
        'message': _messageController.text.trim(),
        'address': _donationType == 'barang' ? _addressController.text.trim() : null,
        'is_anonymous': _isAnonymous,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update collected amount hanya jika donasi uang
      if (_donationType == 'uang') {
        final currentCollected = widget.donation['collected_amount'] ?? 0;
        await supabase
            .from('donation_campaigns')
            .update({
              'collected_amount': currentCollected + amount,
            })
            .eq('id', widget.donation['id']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terima kasih atas donasi Anda!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('[BerikanDonasi] Error submitting donation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim donasi: ${e.toString()}'),
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
    final title = widget.donation['title'] ?? 'Untitled';
    final description = widget.donation['description'] ?? '';
    final imageUrl = widget.donation['cover_image_url'];
    final targetAmount = widget.donation['target_amount'] ?? 1;
    final collectedAmount = widget.donation['collected_amount'] ?? 0;
    final progress = collectedAmount / targetAmount;
    final daysRemaining = _getDaysRemaining();

    return Scaffold(
      backgroundColor: const Color(0xFF8FA3CC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Berikan Donasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'CircularStd',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Donation Info Card
                      Container(
                        margin: const EdgeInsets.all(20),
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
                              // Image
                              if (imageUrl != null)
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: Image.network(
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
                                  ),
                                ),

                              // Info
                              Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF364057),
                                        fontFamily: 'CircularStd',
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Progress
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${_formatNumber(collectedAmount)} / ${_formatNumber(targetAmount)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF8FA3CC),
                                            fontFamily: 'CircularStd',
                                          ),
                                        ),
                                        Text(
                                          '$daysRemaining hari lagi',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontFamily: 'CircularStd',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

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
                                    const SizedBox(height: 16),

                                    // Description
                                    Text(
                                      description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontFamily: 'CircularStd',
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Location Map (if available)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(height: 8),
                            _buildLocationMap(),
                          ],
                        ),
                      ),

                      // Donation Type Toggle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTypeButton(
                                'Berikan Donasi Jenis Uang',
                                'uang',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTypeButton(
                                'Berikan Donasi Jenis Barang',
                                'barang',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Form
                      Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Anonymous checkbox (only for money)
                              if (_donationType == 'uang')
                                CheckboxListTile(
                                  value: _isAnonymous,
                                  onChanged: (value) {
                                    setState(() {
                                      _isAnonymous = value ?? false;
                                    });
                                  },
                                  title: const Text(
                                    'Berdonasi Secara Anonim',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'CircularStd',
                                    ),
                                  ),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  activeColor: const Color(0xFF8FA3CC),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              const SizedBox(height: 12),

                              // Fill with Profile button (only for money)
                              if (_donationType == 'uang')
                                ElevatedButton(
                                  onPressed: _loadUserData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8FA3CC),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text(
                                    'Isi Sesuai Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'CircularStd',
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 30),

                              // Name
                              _buildLabel('Nama Pendonasi'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'CircularStd',
                                ),
                                decoration: _buildInputDecoration('Nama'),
                                validator: (value) {
                                  if (!_isAnonymous && (value == null || value.trim().isEmpty)) {
                                    return 'Nama tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Email
                              _buildLabel('Email'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'CircularStd',
                                ),
                                decoration: _buildInputDecoration('Email'),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email tidak boleh kosong';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Email tidak valid';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Amount (only for money)
                              if (_donationType == 'uang') ...[
                                _buildLabel('Nominal Donasi'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _amountController,
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
                                      return 'Nominal donasi tidak boleh kosong';
                                    }
                                    final amount = int.tryParse(value.replaceAll('.', ''));
                                    if (amount == null || amount <= 0) {
                                      return 'Nominal harus lebih dari 0';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Payment Method
                                _buildLabel('Metode Pembayaran'),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: _paymentMethods.map((method) {
                                    return _buildPaymentMethodButton(method);
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Address (only for goods)
                              if (_donationType == 'barang') ...[
                                _buildLabel('Alamat'),
                                const Text(
                                  '*Untuk lokasi penjemputan donasi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontFamily: 'CircularStd',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _addressController,
                                  maxLines: 3,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'CircularStd',
                                  ),
                                  decoration: _buildInputDecoration('Alamat lengkap'),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Alamat tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Message
                              _buildLabel('Pesan'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _messageController,
                                maxLines: 3,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'CircularStd',
                                ),
                                decoration: _buildInputDecoration('Pesan (opsional)'),
                              ),
                              const SizedBox(height: 32),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submitDonation,
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
                                          'Kirim Donasi',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'CircularStd',
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String type) {
    final isSelected = _donationType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _donationType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8FA3CC) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF8FA3CC) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF364057),
            fontFamily: 'CircularStd',
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(String method) {
    final isSelected = _selectedPaymentMethod == method;
    
    Widget logo;
    if (method == 'OVO') {
      logo = Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Color(0xFF4C2882),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'OVO',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    } else if (method == 'ShopeePay') {
      logo = Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Color(0xFFEE4D2D),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.shopping_bag,
          color: Colors.white,
          size: 30,
        ),
      );
    } else {
      logo = Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Color(0xFF00AED6),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'G',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF8FA3CC) : Colors.grey[300]!,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: logo,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF364057),
        fontFamily: 'CircularStd',
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
    );
  }

  Widget _buildLocationMap() {
    if (_campaignPosition == null) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Text('Lokasi tidak tersedia'),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: isGoogleMapsAvailable()
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(target: _campaignPosition!, zoom: 13),
                    markers: _mapMarkers,
                    onMapCreated: (c) => _mapController = c,
                    onTap: (pos) {
                      // center map on tap
                      try {
                        _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
                      } catch (_) {}
                    },
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    scrollGesturesEnabled: true,
                  ),
                )
              : _buildMapsNotLoadedPlaceholderReadOnly(),
        ),
        const SizedBox(height: 8),
        if (_campaignLocationName != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Row(
              children: [
                const Icon(Icons.place, size: 18, color: Color(0xFF8FA3CC)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _campaignLocationName!,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _campaignPosition == null ? null : _openInExternalMaps,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8FA3CC),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Buka di Maps'),
                ),
              ],
            ),
          ),
        ] else ...[
          const SizedBox.shrink(),
        ],
      ],
    );
  }

  Widget _buildMapsNotLoadedPlaceholderReadOnly() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.red[900],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map, color: Colors.yellow, size: 36),
          const SizedBox(height: 12),
          const Text(
            'Peta tidak dimuat pada web. Tambahkan Google Maps JS API pada web/index.html dan isi GOOGLE_MAPS_API_KEY di .env',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
              final loaded = await injectGoogleMapsScript(apiKey);
              if (loaded) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google Maps berhasil dimuat — silakan reload halaman jika perlu')),
                  );
                }
                setState(() {});
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal memuat Google Maps — periksa API key dan index.html')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8FA3CC)),
            child: const Text('Petunjuk setup'),
          ),
        ],
      ),
    );
  }

  Future<void> _openInExternalMaps() async {
    if (_campaignPosition == null) return;
    final lat = _campaignPosition!.latitude;
    final lng = _campaignPosition!.longitude;
    final googleUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      if (!await launchUrl(googleUrl, mode: LaunchMode.externalApplication)) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuka Maps')));
      }
    } catch (e) {
      print('[BerikanDonasi] Error opening external maps: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuka Maps')));
    }
  }
}

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