import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers untuk mengambil input pengguna
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // State untuk visibilitas password
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Warna utama sesuai desain (Blue-ish Purple)
  final Color _primaryColor = const Color(0xFF6C82BA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indikator garis kecil di atas (opsional, mirip modal sheet)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const Center(
                child: Text(
                  "Lengkapi Data Diri",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: postPrimaryColor, // Menggunakan warna biru atau hitam sesuai preferensi
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Bagian Nama Lengkap
              _buildLabel("Nama Lengkap"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _firstNameController,
                hintText: "Nama depan",
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _lastNameController,
                hintText: "Nama belakang",
              ),
              
              const SizedBox(height: 20),

              // Bagian Nomor Telepon
              _buildLabel("Nomor Telepon"),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "+62",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: Colors.grey.shade300),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: "---",