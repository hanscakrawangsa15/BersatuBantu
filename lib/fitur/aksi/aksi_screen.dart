import 'package:flutter/material.dart';

class AksiScreen extends StatelessWidget {
  const AksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aksi', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8FA3CC),
      ),
      body: Center(
        child: Text(
          'Belum ada aksi yang tersedia',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ),
    );
  }
}
