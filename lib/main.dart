import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils/maps_availability.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:bersatubantu/providers/volunteer_event_provider.dart';
import 'package:bersatubantu/fitur/welcome/splash_screen.dart';
import 'package:bersatubantu/fitur/auth/lupapassword/resetpassword.dart';
import 'package:bersatubantu/fitur/auth/login/organization_login_screen.dart';
import 'package:bersatubantu/fitur/auth/login/admin_dashboard_screen.dart';
import 'package:bersatubantu/fitur/dashboard/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Initialize intl locale data for date/time formatting
  await initializeDateFormatting('id_ID');
  Intl.defaultLocale = 'id_ID';

  // Inject Google Maps JS (Web only)
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
      print(
        '[Maps] No GOOGLE_MAPS_API_KEY found in .env; web map will require adding the script tag to web/index.html',
      );
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VolunteerEventProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
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
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      print('[Auth] Event detected: $event');
      if (event == AuthChangeEvent.passwordRecovery) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
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
          onGenerateRoute: (settings) {
            print('[Router] Navigating to: ${settings.name}');

            if (settings.name == '/home') {
              return MaterialPageRoute(builder: (context) => const DashboardScreen());
            }

            if (settings.name == '/organization_login') {
              return MaterialPageRoute(builder: (context) => const OrganizationLoginScreen());
            }

            if (settings.name == '/admin_dashboard') {
              return MaterialPageRoute(builder: (context) => const AdminDashboardScreen());
            }

            if (settings.name == '/reset-password' ||
                settings.name?.contains('reset-password') == true ||
                settings.name?.contains('#/reset-password') == true) {
              return MaterialPageRoute(builder: (context) => const ResetPasswordScreen());
            }

            return null;
          },
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
    // small delay to allow auth listener setup
    await Future.delayed(const Duration(milliseconds: 300));

    final session = supabase.auth.currentSession;
    if (session != null) {
      print('[Init] Current user: ${session.user.email}');
    } else {
      print('[Init] No active session');
    }
  }
}