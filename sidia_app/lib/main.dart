import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: \$e');
  }
  runApp(const SidiaApp());
}

class SidiaApp extends StatelessWidget {
  const SidiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIDIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
