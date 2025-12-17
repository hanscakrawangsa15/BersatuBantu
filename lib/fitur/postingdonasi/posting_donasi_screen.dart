import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';


class PostingDonasiScreen extends StatefulWidget {
  // organizationId akan dikirim dari DashboardScreen
    final String organizationId;

    const PostingDonasiScreen({
        super.key,
        required this.organizationId,
    });

    @override
    State<PostingDonasiScreen> createState() => _PostingDonasiScreenState();
}

class _PostingDonasiScreenState extends State<PostingDonasiScreen> {
    final _formKey = GlobalKey<FormState>();
    final supabase = Supabase.instance.client;

    // Controllers untuk input form
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();
    final TextEditingController _targetAmountController = TextEditingController();

    File? _imageFile;
    bool _isLoading = false;
    Uint8List? _imageBytes;
    String? _imageName;


    @override
    void dispose() {
        _titleController.dispose();
        _descriptionController.dispose();
        _targetAmountController.dispose();
        super.dispose();
    }

  // --- Fungsi Upload Gambar Cover ---
    Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // penting untuk web
    );

    if (result != null && result.files.single.bytes != null) {
        setState(() {
            _imageBytes = result.files.single.bytes!;
            _imageName = result.files.single.name;
        });
    }

    }


  // --- Fungsi Submit Donasi ---
    Future<void> _submitDonation() async {
        if (!_formKey.currentState!.validate()) {
        return;
        }
        if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mohon tambahkan gambar cover donasi.')),
        );
        return;
        }

        setState(() {
        _isLoading = true;
        });

        String? imageUrl;
        try {
        final targetAmount = double.tryParse(_targetAmountController.text);
        if (targetAmount == null || targetAmount <= 0) {
            throw 'Target dana tidak valid.';
        }

      // 1. Upload Gambar ke Supabase Storage
        final fileName = '${widget.organizationId}_${DateTime.now().millisecondsSinceEpoch}_${_imageName}';

        await supabase.storage.from('donation_covers').uploadBinary(
        fileName,
        _imageBytes!,
        fileOptions: const FileOptions(contentType: 'image/png'),
        );

        // ambil URL
        final imageUrl = supabase.storage.from('donation_covers').getPublicUrl(fileName);


      // 2. Simpan Data Donasi ke Tabel 'donations'
        await supabase.from('donations').insert({
        'organization_id': widget.organizationId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'target_amount': targetAmount,
        'current_amount': 0, // Awalnya 0
        'image_url': imageUrl,
        'status': 'active', // Set status aktif
        // Anda bisa menambahkan deadline di sini jika diperlukan
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kegiatan donasi berhasil diposting!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigasi kembali ke dashboard setelah sukses
        Navigator.pop(context);
      }

    } catch (e) {
      print('Error posting donation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memposting donasi: ${e.toString()}'),
            backgroundColor: Colors.red,
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
      appBar: AppBar(
        title: const Text(
          'Buat Kegiatan Donasi Baru',
          style: TextStyle(
            color: Color(0xFF364057),
            fontFamily: 'CircularStd',
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF364057)),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Input Judul
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Kampanye Donasi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Deskripsi
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi Detail'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Target Dana
              TextFormField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Target Dana (Rp)'),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Masukkan target dana yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Upload Image Section
              const Text(
                'Gambar Cover Donasi:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF364057),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _imageFile == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_search,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pilih Gambar Cover',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF768BBD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Posting Donasi',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'CircularStd',
                            ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}