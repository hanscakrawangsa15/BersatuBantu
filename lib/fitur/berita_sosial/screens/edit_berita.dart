import 'package:flutter/material.dart';
import 'package:bersatubantu/fitur/berita_sosial/models/berita_model.dart';

class EditBeritaScreen extends StatefulWidget {
  final BeritaModel berita;

  const EditBeritaScreen({super.key, required this.berita});

  @override
  State<EditBeritaScreen> createState() => _EditBeritaScreenState();
}

class _EditBeritaScreenState extends State<EditBeritaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _isiController;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.berita.judul);
    _isiController = TextEditingController(text: widget.berita.isi);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  void _saveData() {
    if (_formKey.currentState!.validate()) {
      // Membuat object BeritaModel baru dengan data yang diedit
      BeritaModel updatedBerita = BeritaModel(
        id: widget.berita.id,
        judul: _judulController.text,
        isi: _isiController.text,
        // Data di bawah ini tetap sama (kecuali Anda buat form inputnya juga)
        tanggal: widget.berita.tanggal,
        image: widget.berita.image, // Sesuaikan dengan nama di Model
        source: widget.berita.source, // Sesuaikan dengan nama di Model
        category: widget.berita.category,
      );

      // TODO: Panggil API Update Data di sini

      // Kembali ke layar detail membawa data baru
      Navigator.pop(context, updatedBerita);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perubahan berhasil disimpan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Berita Sosial", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Judul", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _judulController,
                decoration: InputDecoration(
                  hintText: "Masukkan Judul Berita",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value!.isEmpty ? "Judul tidak boleh kosong" : null,
              ),
              const SizedBox(height: 20),
              
              const Text("Isi Berita", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _isiController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: "Tulis isi berita disini...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value!.isEmpty ? "Isi berita tidak boleh kosong" : null,
              ),
              const SizedBox(height: 20),
              
              const Text("Foto Berita", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  // TODO: Implement Image Picker Logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fitur upload gambar belum tersedia")),
                  );
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400),
                    image: widget.berita.image.isNotEmpty
                        ? DecorationImage(
                            image: widget.berita.image.startsWith('http')
                                ? NetworkImage(widget.berita.image)
                                : AssetImage(widget.berita.image) as ImageProvider,
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3), BlendMode.darken), // Gelapkan sedikit agar teks terlihat
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.add_a_photo, size: 40, color: Colors.grey[100]),
                       const SizedBox(height: 8),
                       Text("Ganti Foto", style: TextStyle(color: Colors.grey[100], fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Simpan", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}