import 'package:flutter/material.dart';
import '../models/berita_model.dart';
import 'detail_berita.dart';

class ListBeritaScreen extends StatefulWidget {
  const ListBeritaScreen({super.key});

  @override
  State<ListBeritaScreen> createState() => _ListBeritaScreenState();
}

class _ListBeritaScreenState extends State<ListBeritaScreen> {
  // --- STATE VARIABELS ---
  late PageController _pageController; // Controller untuk deteksi geser
  int _currentNewsIndex = 0; // Menyimpan index berita yang sedang aktif

  @override
  void initState() {
    super.initState();
    // viewportFraction 0.85 artinya kartu mengambil 85% lebar layar,
    // sisa 15% untuk menampilkan sedikit kartu di sebelahnya (peeking)
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Dummy Data
  List<BeritaModel> listBerita = [
    BeritaModel(
      id: '1',
      judul: 'KPK Sebut Kasus Bansos Presiden',
      isi: 'Komisi Pemberantasan Korupsi (KPK) memberikan update terbaru...',
      tanggal: '29 Juni 2024 • 10:15 WIB',
      imageUrl: '',
      author: 'Kompas.com',
    ),
    BeritaModel(
      id: '2',
      judul: 'Longsor Terjang Tiga Desa di Tasikmalaya',
      isi: 'Hujan deras mengguyur sejumlah kecamatan...',
      tanggal: '29 Juni 2024 • 10:00 WIB',
      imageUrl: '',
      author: 'Detik.com',
    ),
    BeritaModel(
      id: '3',
      judul: 'Bantuan Sembako untuk Korban Banjir',
      isi: 'Penyaluran bantuan sembako telah dilakukan...',
      tanggal: '30 Juni 2024 • 14:00 WIB',
      imageUrl: '',
      author: 'CNN Indonesia',
    ),
  ];

  final List<String> categories = [
    "Semua", "Bencana Alam", "Kemiskinan", "Hak Asasi", "Pendidikan"
  ];
  int selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // --- 1. HEADER & SEARCH BAR (Diperbaiki urutannya) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar Dulu (Sesuai Desain Figma)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          hintText: "Telusuri",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Judul Besar "Berita"
                    const Text(
                      "Berita",
                      style: TextStyle(
                        fontSize: 34, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5, // Sedikit rapat agar elegan
                      ),
                    ),
                  ],
                ),
              ),

              // --- 2. KATEGORI FILTER ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(categories.length, (index) {
                    bool isSelected = index == selectedCategoryIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoryIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF374151)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 24),

              // --- 3. BERITA TERBARU (Carousel Effect) ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Berita Terbaru",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Menggunakan SizedBox agar PageView punya tinggi pasti
              SizedBox(
                height: 240, 
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentNewsIndex = index; // Update index saat digeser
                    });
                  },
                  itemCount: listBerita.length,
                  itemBuilder: (context, index) {
                    final berita = listBerita[index];
                    // Cek apakah item ini yang sedang aktif (di tengah)
                    bool isActive = index == _currentNewsIndex;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(
                        horizontal: 8, 
                        vertical: isActive ? 0 : 10, // Efek zoom-in/out sedikit
                      ),
                      decoration: BoxDecoration(
                        // Logika Warna: Aktif = Biru Gelap, Tidak Aktif = Abu-abu Terang
                        color: isActive ? const Color(0xFF374151) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isActive 
                          ? [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))]
                          : [],
                      ),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetailBeritaScreen(berita: berita)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                berita.judul,
                                style: TextStyle(
                                  // Logika Warna Teks: Background Gelap = Teks Putih, Background Terang = Teks Hitam
                                  color: isActive ? Colors.white : Colors.black87,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    berita.tanggal.split('•')[0].trim(),
                                    style: TextStyle(
                                      color: isActive ? Colors.white70 : Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    berita.author,
                                    style: TextStyle(
                                      color: isActive ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // --- 4. TERPOPULER (List Bawah) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Terpopuler",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Lihat Semua", style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
              
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listBerita.length,
                itemBuilder: (context, index) {
                  final berita = listBerita[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailBeritaScreen(berita: berita)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                              image: berita.imageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: AssetImage(berita.imageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: berita.imageUrl.isEmpty 
                              ? const Icon(Icons.image, color: Colors.grey) 
                              : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  berita.judul,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  berita.author,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      )
    );
  }
}