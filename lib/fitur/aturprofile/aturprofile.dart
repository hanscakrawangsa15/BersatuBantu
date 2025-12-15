import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/fitur/welcome/splash_screen.dart';

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
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variabel inisialisasi kosong/loading (Bukan Dummy)
  String _name = "Memuat..."; 
  String _email = "Memuat...";
  
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('[ProfileScreen] Widget updated - Refreshing profile data');
    _getProfileData();
  }

  // MURNI AMBIL DARI DATABASE
  Future<void> _getProfileData() async {
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
          title: const Text("Atur Profil", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            _buildPlaceholderItem(),
            _buildPlaceholderItem(),
            _buildPlaceholderItem(),
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
      // Bottom Navigation Bar disamakan dengan Dashboard
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Profil terpilih
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF768BBD),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0: // Beranda - Pop back to Dashboard dengan signal refresh
              print('[ProfileScreen] Navigate back to Dashboard via BottomNav');
              Navigator.of(context).pop(true); // Return true untuk signal refresh
              break;
            case 1: // Favorit (sementara: hanya snackbar atau TODO)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu Favorit belum tersedia')),
              );
              break;
            case 2: // Kategori (sementara: hanya snackbar atau TODO)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu Kategori belum tersedia')),
              );
              break;
            case 3: // Profil
              // sudah di halaman ini, tidak perlu apa-apa
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border_rounded), label: 'Favorit'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Kategori'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profil'),
        ],
      ),
      ),
    );
  }
  }

  Widget _buildPlaceholderItem() {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
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
        });
      } catch (e) {
        // Handle jika data tidak ada
      }
    }
  }

  // UPDATE KE DATABASE
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw "User not logged in";

      // Kirim Data Asli ke Supabase
      await supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': _fullNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'updated_at': DateTime.now().toIso8601String(),
      });

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
        Navigator.pop(context, true); // Return true to indicate data was updated
      }

    } catch (e) {
      // Jika Gagal (Internet mati / Error DB)
      print('[EditProfile] Error updating profile: $e');
      _showErrorDialog();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Dialog Error Exception Flow
  void _showErrorDialog() {
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
              child: const Icon(Icons.priority_high, size: 30, color: Colors.black),
            ),
            const SizedBox(height: 15),
            const Text(
              "Gagal Menyimpan Perubahan",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF768BBD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Oke", style: TextStyle(color: Colors.white)),
              ),
            )
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
        title: const Text("Edit Profil", style: TextStyle(fontWeight: FontWeight.bold)),
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
                          Row(children: [
                            ElevatedButton(
                              onPressed: (){}, 
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], elevation: 0, foregroundColor: Colors.black), 
                              child: const Text("Upload Foto", style: TextStyle(fontSize: 12))
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: (){}, 
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], elevation: 0, foregroundColor: Colors.black), 
                              child: const Text("Ambil Foto", style: TextStyle(fontSize: 12))
                            ),
                          ])
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- FORM INPUT ---
                  _buildLabel("Nama Lengkap"),
                  _buildTextField("Masukkan nama lengkap", controller: _fullNameController),
                  const SizedBox(height: 15),

                  _buildLabel("Email"),
                  _buildTextField("Email", controller: _emailController, inputType: TextInputType.emailAddress),
                  const SizedBox(height: 15),

                  _buildLabel("No. Telepon"),
                  _buildTextField("+62 ---", controller: _phoneController, inputType: TextInputType.phone),
                ],
              ),
            ),
          ),
          
          // --- TOMBOL AKSI ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Batal", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF768BBD),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Simpan", style: TextStyle(color: Colors.white)),
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
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
    );
  }

  Widget _buildTextField(String hint, {TextEditingController? controller, TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF768BBD))),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}