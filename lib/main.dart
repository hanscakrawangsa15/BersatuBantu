import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/fitur/welcome/splash_screen.dart';
import 'package:bersatubantu/services/supabase.dart' as app_supabase;
import 'package:bersatubantu/services/debug_auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://kkacuemmgvgtyhgmxidy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrYWN1ZW1tZ3ZndHloZ214aWR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxMzkyODUsImV4cCI6MjA3OTcxNTI4NX0.OQAkmObcWSQkXaPzLoMJ7sqooSC72MbKSYqe_KsRkD0',
  );

  runApp(const MyApp());
}

// Global Supabase client
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BersatuBantu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF768BBD),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'CircularStd',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF768BBD),
          primary: const Color(0xFF768BBD),
          secondary: const Color(0xFF364057),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}