import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:bersatubantu/providers/volunteer_event_provider.dart';
import 'package:bersatubantu/fitur/welcome/splash_screen.dart';
import 'package:bersatubantu/fitur/auth/lupapassword/resetpassword.dart';
import 'package:bersatubantu/fitur/auth/login/organization_login_screen.dart';
import 'package:bersatubantu/fitur/auth/login/admin_dashboard_screen.dart';

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

  // Initialize intl locale data for date/time formatting
  await initializeDateFormatting('id_ID');
  Intl.defaultLocale = 'id_ID';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VolunteerEventProvider()),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
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

            if (settings.name == '/organization_login') {
              print('[Router] Navigating to OrganizationLoginScreen');
              return MaterialPageRoute(
                builder: (context) => const OrganizationLoginScreen(),
              );
            }

            if (settings.name == '/admin_dashboard') {
              print('[Router] Navigating to AdminDashboardScreen');
              return MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              );
            }

            if (settings.name == '/reset-password' ||
                settings.name?.contains('reset-password') == true ||
                settings.name?.contains('#/reset-password') == true) {
              print('[Router] Detected reset-password route, navigating to ResetPasswordScreen');
              return MaterialPageRoute(
                builder: (context) => const ResetPasswordScreen(),
              );
            }

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

              final session = supabase.auth.currentSession;
              if (session != null) {
                print('[Init] Has session: ${session.user.id}');
              }

              return const SplashScreen();
            },
          ),
        ),
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