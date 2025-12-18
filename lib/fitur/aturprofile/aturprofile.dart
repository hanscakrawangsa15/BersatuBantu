import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/fitur/welcome/splash_screen.dart';
import 'package:bersatubantu/fitur/aturprofile/account_settings_screen.dart';
import 'package:bersatubantu/fitur/aturprofile/donation_history_screen.dart';
import 'package:bersatubantu/fitur/widgets/bottom_navbar.dart';
import 'package:bersatubantu/fitur/donasi/donasi_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bersatubantu/fitur/aturprofile/my_activities_screen.dart';
import 'package:bersatubantu/fitur/widgets/bottom_navbar.dart';
import 'package:bersatubantu/fitur/dashboard/dashboard_screen.dart';
import 'package:bersatubantu/fitur/donasi/donasi_screen.dart';

// ------------------------------------------------------------------
// 1. MAIN & INISIALISASI
// ------------------------------------------------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pastikan URL & KEY Supabase kamu sudah benar
  await Supabase.initialize(
    url: 'https://PROJECT-ID.supabase.co',
    anonKey: 'PUBLIC-ANON-KEY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BersatuBantu',
      theme: ThemeData(
        primaryColor: const Color(0xFF768BBD),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF768BBD),
          secondary: const Color(0xFF768BBD),
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      // Langsung masuk ke ProfileScreen (Tanpa Login Screen)
      home: const ProfileScreen(),
    );
  }
}

// ------------------------------------------------------------------
// 2. HALAMAN PROFIL (REAL DB CONNECTION)
// ------------------------------------------------------------------
class ProfileScreen extends StatefulWidget {
  final bool isAdmin;

  const ProfileScreen({super.key, this.isAdmin = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variabel inisialisasi kosong/loading (Bukan Dummy)
  String _name = "Memuat...";
  String _email = "Memuat...";
  int _selectedNavIndex = 3; // Profil is index 3
  
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    print('[ProfileScreen] initState - isAdmin=${widget.isAdmin}');
    _getProfileData();
  }

  // MURNI AMBIL DARI DATABASE
  Future<void> _getProfileData() async {
    // Jika admin, gunakan data statis
    if (widget.isAdmin) {
      if (mounted) {
        setState(() {
          _name = "admin";
          _email = "admin@gmail.com";
        });
      }
      return;
    }

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        // Jika sesi login hilang/belum login
        if (mounted) {
          setState(() {
            _name = "Belum Login";
            _email = "-";
          });
        }
        return;
      }

      // Query Real ke Supabase
      final data = await supabase
          .from('profiles')
          .select('full_name, email') // Sesuaikan nama kolom di DB kamu
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _name = data['full_name'] ?? "Tanpa Nama";
          _email = data['email'] ?? user.email ?? "-";
        });
      }
    } catch (e) {
      // Jika terjadi error koneksi atau data tidak ditemukan
      print("Error Fetching Data: $e");
      if (mounted) {
        setState(() {
          _name = "Error Memuat";
          _email = "-";
        });
      }
    }
  }

  // Handle bottom navigation tap
  void _onNavTap(int index) {
    switch (index) {
      case 0: // Beranda
        print('[ProfileScreen] Navigate to Dashboard');
        Navigator.of(context).pop(true); // Pop back to Dashboard
        break;
      case 1: // Donasi
        print('[ProfileScreen] Navigate to Donasi');
        setState(() {
          _selectedNavIndex = 1;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DonasiScreen()),
        );
        break;
      case 2: // Aksi
        print('[ProfileScreen] Navigate to Aksi');
        setState(() {
          _selectedNavIndex = 2;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu Aksi belum tersedia')),
        );
        // Reset back to Profil index
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _selectedNavIndex = 3;
            });
          }
        });
        break;
      case 3: // Profil - sudah di halaman ini
        setState(() {
          _selectedNavIndex = 3;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          print('[ProfileScreen] PopScope triggered - User navigating back');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Atur Profil",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // --- HEADER PROFIL ---
              Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                  backgroundColor: Color(0xFF768BBD),
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(_email, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () async {
                    // Pindah ke halaman Edit (Tanpa kirim data dummy)
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    );
                    // Refresh data DB setelah kembali (jika ada perubahan)
                    if (result == true) {
                      print('[ProfileScreen] Profile was updated - Refreshing data');
                      _getProfileData();
                    } else {
                      print('[ProfileScreen] Profile edit was cancelled');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF768BBD)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Edit Profil", style: TextStyle(color: Color(0xFF768BBD))),
                )
              ],
            ),
            const SizedBox(height: 30),
            
            // --- MENU LAINNYA ---
            _buildMenuCard(
              icon: Icons.settings_outlined,
              title: "Pengaturan Akun",
              subtitle: "Ubah password, notifikasi, privasi",
              onTap: () {
                // Navigasi ke Pengaturan Akun
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                );
              },
            ),
            _buildMenuCard(
              icon: Icons.history_outlined,
              title: "Riwayat Donasi",
              subtitle: "Lihat donasi yang telah dilakukan",
              onTap: () {
                // Navigasi ke Riwayat Donasi
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DonationHistoryScreen()),
                );
              },
            ),
            const SizedBox(height: 30),
            
            // --- TOMBOL LOGOUT ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Tampilkan dialog konfirmasi logout
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      title: const Text("Konfirmasi Logout", style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context); // Tutup dialog
                            try {
                              // Logout dari Supabase
                              await Supabase.instance.client.auth.signOut();
                              if (mounted) {
                                // Navigasi ke Splash Screen dan hapus semua route sebelumnya
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Gagal logout: $e")),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text("Logout", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation - Using Custom BottomNavBar widget (sesuai dengan Dashboard)
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedNavIndex,
        onTap: _onNavTap,
      ),
      ),
    );
  }
}

Widget _buildMenuCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF768BBD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF768BBD), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    ),
  );
}

// ------------------------------------------------------------------
// 3. EDIT PROFIL (REAL DB UPDATE)
// ------------------------------------------------------------------
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controller mulai kosong, nanti diisi dari DB
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  
  // Photo variables
  XFile? _selectedImage;
  String? _currentPhotoUrl;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingPhoto = false;

  // Fungsi untuk check dan request permissions
  Future<bool> _checkPhotoPermissions() async {
    try {
      print('[EditProfile] Checking photo permissions...');
      // Permissions akan di-handle otomatis oleh image_picker
      return true;
    } catch (e) {
      print('[EditProfile] Permission error: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // AMBIL DATA LAMA DARI DB UNTUK DIISI KE FORM
  Future<void> _loadCurrentData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        setState(() {
          _fullNameController.text = data['full_name'] ?? '';
          _emailController.text = data['email'] ?? user.email ?? '';
          _phoneController.text = data['phone'] ?? '';
          _currentPhotoUrl = data['photo'] ?? '';
        });
      } catch (e) {
        // Handle jika data tidak ada
        print('[EditProfile] Error loading profile data: $e');
      }
    }
  }

  // PICK IMAGE FROM GALLERY OR CAMERA
  Future<void> _pickImage(ImageSource source) async {
    try {
      final isGallery = source == ImageSource.gallery;
      print('[EditProfile] Picking image from ${isGallery ? 'gallery' : 'camera'} (Web: $kIsWeb)');
      
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null && image.path.isNotEmpty) {
        print('[EditProfile] Image selected: ${image.name}');
        print('[EditProfile] Image path: ${image.path}');
        print('[EditProfile] Is web: $kIsWeb');
        
        // For web, we can use blob URL directly. For mobile, validate file
        bool isValidImage = true;
        if (!kIsWeb) {
          final file = File(image.path);
          isValidImage = file.existsSync();
          if (isValidImage) {
            print('[EditProfile] File verified: ${file.lengthSync()} bytes');
          } else {
            throw 'File tidak ditemukan: ${image.path}';
          }
        } else {
          print('[EditProfile] Web platform - using blob URL directly');
        }
        
        if (isValidImage && mounted) {
          setState(() {
            _selectedImage = image;
          });
          
          print('[EditProfile] State updated with new image');
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Foto berhasil dipilih'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        print('[EditProfile] No image selected or path empty');
      }
    } on UnsupportedError catch (e) {
      print('[EditProfile] UnsupportedError: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fitur foto tidak tersedia'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('[EditProfile] Error picking image: $e');
      print('[EditProfile] Stack trace: $stackTrace');
      print('[EditProfile] Error type: ${e.runtimeType}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // UPLOAD IMAGE TO SUPABASE STORAGE
  Future<String?> _uploadPhotoToStorage(XFile imageFile) async {
    try {
      setState(() => _isUploadingPhoto = true);
      
      final user = supabase.auth.currentUser;
      if (user == null) throw 'User not authenticated';
      
      // Create unique file path
      final fileName = 'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'profiles/$fileName';
      
      print('[EditProfile] Uploading photo to: $filePath');
      print('[EditProfile] Is web: $kIsWeb');
      
      late List<int> fileBytes;
      
      // Handle web and mobile differently
      if (kIsWeb) {
        print('[EditProfile] Uploading from web...');
        // For web, read bytes directly from XFile
        fileBytes = await imageFile.readAsBytes();
      } else {
        print('[EditProfile] Uploading from mobile...');
        // For mobile, read from file system
        final file = File(imageFile.path);
        fileBytes = await file.readAsBytes();
      }
      
      print('[EditProfile] File size: ${fileBytes.length} bytes');
      
      // Upload to Supabase Storage
      await supabase.storage.from('profile').uploadBinary(
        filePath,
        Uint8List.fromList(fileBytes),
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
      
      // Get public URL
      final publicUrl = supabase.storage.from('profile').getPublicUrl(filePath);
      print('[EditProfile] Photo uploaded successfully: $publicUrl');
      
      return publicUrl;
    } catch (e, stackTrace) {
      print('[EditProfile] Error uploading photo: $e');
      print('[EditProfile] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload foto: $e')),
        );
      }
      return null;
    } finally {
      setState(() => _isUploadingPhoto = false);
    }
  }

  // UPDATE KE DATABASE
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw "User not logged in";

      // Upload photo jika ada yang dipilih
      String? photoUrl = _currentPhotoUrl;
      if (_selectedImage != null) {
        print('[EditProfile] Uploading new photo...');
        photoUrl = await _uploadPhotoToStorage(_selectedImage!);
        if (photoUrl == null) {
          throw 'Gagal upload foto';
        }
      }

      // Kirim Data Asli ke Supabase
      final updateData = {
        'id': user.id,
        'full_name': _fullNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Include photo URL jika ada
      if (photoUrl != null && photoUrl.isNotEmpty) {
        updateData['photo'] = photoUrl;
      }
      
      print('[EditProfile] Updating profile with data: $updateData');
      await supabase.from('profiles').upsert(updateData);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Wait a bit for the snackbar to be visible then pop
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pop(
          context,
          true,
        ); // Return true to indicate data was updated
      }

    } catch (e, stackTrace) {
      // Jika Gagal (Internet mati / Error DB)
      print('[EditProfile] Error updating profile: $e');
      print('[EditProfile] Stack trace: $stackTrace');
      if (mounted) {
        _showErrorDialog('Gagal menyimpan profil: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Dialog Error Exception Flow
  void _showErrorDialog([String? errorMessage]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(
                Icons.priority_high,
                size: 30,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              errorMessage ?? "Gagal Menyimpan Perubahan",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF768BBD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Oke", style: TextStyle(color: Colors.white)),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- FOTO PROFIL ---
                  Center(
                    child: Column(
                      children: [
                        // Photo preview
                        GestureDetector(
                          onTap: () {
                            if (_selectedImage != null) {
                              print('[EditProfile] Tapped on preview image: ${_selectedImage!.path}');
                            }
                          },
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: kIsWeb
                                      ? Image.network(
                                          _selectedImage!.path,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            print('[EditProfile] Error loading image: $error');
                                            return Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[300],
                                                border: Border.all(color: const Color(0xFF768BBD), width: 2),
                                              ),
                                              child: const Icon(Icons.error, size: 40, color: Colors.red),
                                            );
                                          },
                                        )
                                      : Image.file(
                                          File(_selectedImage!.path),
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            print('[EditProfile] Error loading image: $error');
                                            return Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[300],
                                                border: Border.all(color: const Color(0xFF768BBD), width: 2),
                                              ),
                                              child: const Icon(Icons.error, size: 40, color: Colors.red),
                                            );
                                          },
                                        ),
                                )
                              : Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                    border: Border.all(color: const Color(0xFF768BBD), width: 2),
                                    image: (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty)
                                        ? DecorationImage(
                                            image: NetworkImage(_currentPhotoUrl!),
                                            fit: BoxFit.cover,
                                            onError: (exception, stackTrace) {
                                              print('[EditProfile] Error loading network image: $exception');
                                            },
                                          )
                                        : null,
                                  ),
                                  child: (_currentPhotoUrl == null || _currentPhotoUrl!.isEmpty)
                                      ? const Icon(Icons.camera_alt, size: 48, color: Color(0xFF768BBD))
                                      : null,
                                ),
                        ),
                        const SizedBox(height: 16),
                        // Upload buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isUploadingPhoto
                                  ? null
                                  : () async {
                                      print('[EditProfile] Opening gallery');
                                      try {
                                        await _pickImage(ImageSource.gallery);
                                      } catch (e) {
                                        print('[EditProfile] Gallery error: $e');
                                      }
                                    },
                              icon: const Icon(Icons.image),
                              label: const Text("Pilih Foto"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                                elevation: 0,
                                disabledBackgroundColor: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _isUploadingPhoto
                                  ? null
                                  : () async {
                                      print('[EditProfile] Opening camera');
                                      try {
                                        await _pickImage(ImageSource.camera);
                                      } catch (e) {
                                        print('[EditProfile] Camera error: $e');
                                      }
                                    },
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("Ambil Foto"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                                elevation: 0,
                                disabledBackgroundColor: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                        if (_selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '✓ Foto baru: ${_selectedImage!.name}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Foto akan di-upload saat Anda klik Simpan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- FORM INPUT ---
                  _buildLabel("Nama Lengkap"),
                  _buildTextField(
                    "Masukkan nama lengkap",
                    controller: _fullNameController,
                  ),
                  const SizedBox(height: 15),

                  _buildLabel("Email"),
                  _buildTextField(
                    "Email",
                    controller: _emailController,
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),

                  _buildLabel("No. Telepon"),
                  _buildTextField(
                    "+62 ---",
                    controller: _phoneController,
                    inputType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),

          // --- TOMBOL AKSI ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF768BBD),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Simpan",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    TextEditingController? controller,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF768BBD)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
