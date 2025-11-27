import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'fitur/auth/login/login_screen.dart';
import 'core/app-route.dart';

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
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/auth': (context) => const LoginScreen(),
      },
    );
  }
}

// Global accessor untuk Supabase client
final supabase = Supabase.instance.client;