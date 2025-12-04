import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/core/theme/app_theme.dart';
import 'package:bersatubantu/fitur/welcome/splash_screen.dart';
import 'package:bersatubantu/core/theme/app_constants.dart';
import 'package:bersatubantu/fitur/welcome/splash_screen.dart';
import 'package:bersatubantu/core/utils/navigation_helper.dart';
import 'package:bersatubantu/fitur/auth/login/login_screen.dart';
import 'package:bersatubantu/cekkoneksi/cek_koneksi.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://kkacuemmgvgtyhgmxidy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrYWN1ZW1tZ3ZndHloZ214aWR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxMzkyODUsImV4cCI6MjA3OTcxNTI4NX0.OQAkmObcWSQkXaPzLoMJ7sqooSC72MbKSYqe_KsRkD0',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BersatuBantu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => LoginScreen(),
        '/auth': (context) => LoginScreen(),
        '/cek_koneksi': (context) => CekKoneksiPage(),
      },
    );
  }
}

