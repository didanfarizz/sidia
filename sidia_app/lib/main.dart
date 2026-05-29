import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: File .env tidak ditemukan, menggunakan nilai default.");
  }
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const SidiaApp());
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Gagal menghubungkan ke Firebase:\n$e', textAlign: TextAlign.center),
        ),
      ),
    ));
  }
}

class SidiaApp extends StatefulWidget {
  const SidiaApp({super.key});

  @override
  State<SidiaApp> createState() => _SidiaAppState();
}

class _SidiaAppState extends State<SidiaApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Timer? _authTimer;
  // Durasi sesi (30 detik untuk testing, bisa diubah ke jam untuk produksi)
  static const Duration _authTimeout = Duration(minutes: 30);

  @override
  void initState() {
    super.initState();
    _startAuthTimer();
  }

  void _startAuthTimer() {
    _authTimer?.cancel();
    _authTimer = Timer(_authTimeout, _handleSessionTimeout);
  }

  void _handleUserInteraction([_]) {
    _startAuthTimer();
  }

  Future<void> _handleSessionTimeout() async {
    // Hanya logout jika user sedang login
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesi Anda telah berakhir karena tidak ada aktivitas (30 detik). Silakan login kembali.'),
              duration: Duration(seconds: 4),
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        debugPrint('Auto-logout error: $e');
      }
    } else {
      // Jika belum login, cukup restart timer
      _startAuthTimer();
    }
  }

  @override
  void dispose() {
    _authTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handleUserInteraction,
      onPointerMove: _handleUserInteraction,
      onPointerUp: _handleUserInteraction,
      behavior: HitTestBehavior.translucent,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'SIDIA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
