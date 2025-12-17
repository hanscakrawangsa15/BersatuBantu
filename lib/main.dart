import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils/maps_availability.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/fitur/welcome/splash_screen.dart';
import 'package:bersatubantu/fitur/auth/lupapassword/resetpassword.dart';
import 'package:bersatubantu/fitur/auth/login/organization_login_screen.dart';
import 'package:bersatubantu/fitur/auth/login/admin_dashboard_screen.dart';
import 'package:bersatubantu/fitur/dashboard/dashboard_screen.dart';
import 'package:bersatubantu/test_dashboard_debug.dart';

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

  // Run diagnostic test
  await testDashboardQuery();

  // If running on web and a Google Maps API key is present in .env, try to inject the
  // Google Maps JavaScript API automatically so the map can load without manual
  // index.html edits. This is optional but convenient for local dev.
  if (kIsWeb) {
    final mapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (mapsApiKey != null && mapsApiKey.isNotEmpty) {
      try {
        final ok = await injectGoogleMapsScript(mapsApiKey);
        print('[Maps] injectGoogleMapsScript result: $ok');
      } catch (e) {
        print('[Maps] Failed to inject Google Maps script: $e');
      }
    } else {
      print('[Maps] No GOOGLE_MAPS_API_KEY found in .env; web map will require adding the script tag to web/index.html');
    }
  }

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
        
        // Handle /home route (organization dashboard)
        if (settings.name == '/home') {
          print('[Router] Navigating to DashboardScreen');
          return MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          );
        }
        
        // Handle /organization_login route
        if (settings.name == '/organization_login') {
          print('[Router] Navigating to OrganizationLoginScreen');
          return MaterialPageRoute(
            builder: (context) => const OrganizationLoginScreen(),
          );
        }
        
        // Handle /admin_dashboard route
        if (settings.name == '/admin_dashboard') {
          print('[Router] Navigating to AdminDashboardScreen');
          return MaterialPageRoute(
            builder: (context) => const AdminDashboardScreen(),
          );
        }
        
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