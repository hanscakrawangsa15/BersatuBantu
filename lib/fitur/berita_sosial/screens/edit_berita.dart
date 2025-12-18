import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Add Supabase import
import 'package:bersatubantu/fitur/berita_sosial/models/berita_model.dart';

class EditBeritaScreen extends StatefulWidget {
  final BeritaModel berita;

  const EditBeritaScreen({super.key, required this.berita});

  @override
  State<EditBeritaScreen> createState() => _EditBeritaScreenState();
}

class _EditBeritaScreenState extends State<EditBeritaScreen> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client; // 2. Init Supabase
  
  late TextEditingController _judulController;
  late TextEditingController _isiController;
  bool _isLoading = false; // To show loading state

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

  // --- UPDATE LOGIC HERE ---
  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final title = _judulController.text;
      final content = _isiController.text;

      // 1. Send Update to Database
      await supabase.from('news').update({
        'title': title,
        'content': content,
        // Add other fields here if you edit them (e.g. category, image_url)
      }).eq('id', widget.berita.id); // WHERE id = current ID

      // 2. Create updated model locally
      BeritaModel updatedBerita = BeritaModel(
        id: widget.berita.id,
        judul: title,
        isi: content,
        tanggal: widget.berita.tanggal,
        image: widget.berita.image,
        source: widget.berita.source,
        category: widget.berita.category,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perubahan berhasil disimpan")),
        );
        // 3. Return the new data to the previous screen
        Navigator.pop(context, updatedBerita);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                                Colors.black.withOpacity(0.3), BlendMode.darken),
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
                      onPressed: _isLoading ? null : _saveData, // Disable if loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Simpan", style: TextStyle(color: Colors.white)),
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