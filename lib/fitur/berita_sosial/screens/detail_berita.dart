import 'package:flutter/material.dart';
import 'package:bersatubantu/fitur/berita_sosial/models/berita_model.dart';
import 'package:bersatubantu/fitur/berita_sosial/screens/edit_berita.dart';

class DetailBeritaScreen extends StatefulWidget {
  final BeritaModel berita;
  final bool isAdmin; // Flag to determine access level

  const DetailBeritaScreen({
    super.key, 
    required this.berita, 
    this.isAdmin = false, // Default is false (User mode)
  });

  @override
  State<DetailBeritaScreen> createState() => _DetailBeritaScreenState();
}

class _DetailBeritaScreenState extends State<DetailBeritaScreen> {
  late BeritaModel currentBerita;

  @override
  void initState() {
    super.initState();
    currentBerita = widget.berita;
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "Yakin akan menghapus berita?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Tidak", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Call API to delete data here
                    Navigator.pop(context); // Close Dialog
                    Navigator.pop(context); // Close Screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Berita berhasil dihapus")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Ya", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Helper for image provider
    ImageProvider? imageProvider;
    if (currentBerita.image.isNotEmpty) {
      if (currentBerita.image.startsWith('http')) {
        imageProvider = NetworkImage(currentBerita.image);
      } else {
        imageProvider = AssetImage(currentBerita.image);
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Only show actions if user is Admin
        actions: widget.isAdmin 
          ? [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.indigo),
                onPressed: _confirmDelete,
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.indigo),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditBeritaScreen(berita: currentBerita),
                    ),
                  );

                  if (result != null && result is BeritaModel) {
                    setState(() {
                      currentBerita = result;
                    });
                  }
                },
              ),
              const SizedBox(width: 16),
            ]
          : null, // Return null hides the actions section
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                currentBerita.category,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            
            // Title
            Text(
              currentBerita.judul,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Date & Source
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  currentBerita.tanggal,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "•  ${currentBerita.source}",
                    style: const TextStyle(
                      color: Colors.indigo, 
                      fontSize: 12, 
                      fontWeight: FontWeight.bold
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
                image: imageProvider != null 
                  ? DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
              ),
              child: imageProvider == null
                  ? const Center(child: Icon(Icons.image, size: 80, color: Colors.grey))
                  : null,
            ),
            const SizedBox(height: 20),

            // Content
            Text(
              currentBerita.isi,
              style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}