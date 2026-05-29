import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'assessment_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _isDiagnosisMode = false;

  bool get isDiagnosisMode => _isDiagnosisMode;
  int get currentIndex => _currentIndex;

  void setIndex(int index, {bool isDiagnosisMode = false}) {
    setState(() {
      _currentIndex = index;
      _isDiagnosisMode = isDiagnosisMode;
    });
  }

  void exitDiagnosisMode() {
    setState(() {
      _isDiagnosisMode = false;
      _currentIndex = 0; // Kembali ke Beranda
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const HistoryScreen(),
      _isDiagnosisMode ? const AssessmentScreen() : const ChatScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded),
                _buildNavItem(1, Icons.history),
                _buildNavItem(2, Icons.medical_services),
                _buildNavItem(3, Icons.person),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() {
        _currentIndex = index;
        if (index != 2) {
          _isDiagnosisMode = false; // Reset diagnosis mode jika pindah ke tab lain
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE2E8F0) : Colors.transparent, // Grey background
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 26,
          color: isActive ? const Color(0xFF475569) : const Color(0xFF94A3B8), // Darker grey if active
        ),
      ),
    );
  }
}
