import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/fitur/welcome/splash_screen.dart';
import 'package:bersatubantu/fitur/auth/lupapassword/resetpassword.dart';
import 'package:bersatubantu/services/supabase.dart' as app_supabase;
import 'package:bersatubantu/services/debug_auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase dengan environment variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}

// Global Supabase client
final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // Listen untuk auth state changes termasuk password recovery
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      
      print('[Auth] Event detected: $event');
      
      if (event == AuthChangeEvent.passwordRecovery) {
        // User klik link reset password dari email
        print('[Auth] Password recovery event - navigating to reset screen');
        
        // Navigate ke reset password screen
        Future.delayed(const Duration(milliseconds: 100), () {
          _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ResetPasswordScreen(),
            ),
            (route) => false,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
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
      // Tambahkan route handler untuk web reset password
      onGenerateRoute: (settings) {
        print('[Router] Navigating to: ${settings.name}');
        
        // Handle /reset-password route dari email
        if (settings.name == '/reset-password' || 
            settings.name?.contains('reset-password') == true ||
            settings.name?.contains('#/reset-password') == true) {
          print('[Router] Detected reset-password route, navigating to ResetPasswordScreen');
          return MaterialPageRoute(
            builder: (context) => const ResetPasswordScreen(),
          );
        }
        
        // Default route - tidak ada yang cocok
        return null;
      },
      // Initial route berdasarkan auth state
      home: FutureBuilder(
        future: _checkInitialAuth(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF768BBD),
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          }
          
          // Cek apakah ada recovery session
          final session = supabase.auth.currentSession;
          if (session != null) {
            print('[Init] Has session: ${session.user.id}');
            // Auth listener akan handle navigation ke reset password
            // jika ini adalah recovery session
          }
          
          // Default ke splash screen
          return const SplashScreen();
        },
      ),
    );
  }

  Future<void> _checkInitialAuth() async {
    // Tunggu sebentar untuk auth state listener setup
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Log current auth state
    final session = supabase.auth.currentSession;
    if (session != null) {
      print('[Init] Current user: ${session.user.email}');
    } else {
      print('[Init] No active session');
    }
  }
}