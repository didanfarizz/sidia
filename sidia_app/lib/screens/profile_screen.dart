import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Section (Light blue background, Avatar, Name, ID)
              _buildTopSection(),
              
              // Data Diri Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildDataDiriCard(),
              ),
              const SizedBox(height: 24),
              
              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildLogoutButton(context),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F5FA), // Light blue background matching the design
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      padding: const EdgeInsets.only(top: 40, bottom: 24),
      child: Column(
        children: [
          // Avatar with SIDIA logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logo_sidia.png',
                width: 60,
                errorBuilder: (context, error, stackTrace) => const Text('SIDIA', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          const Text(
            'Budi Santoso',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Patient ID Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD1F4E6), // Light green background
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Patient ID: SID-8492',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F4C47), // Dark teal text
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataDiriCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.badge_outlined, color: AppColors.primaryNavy, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Data Diri',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          // Form fields
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFormField('Nama Lengkap', 'Budi Santoso', null),
                const SizedBox(height: 16),
                _buildFormField('Jenis Kelamin', 'Pria', null),
                const SizedBox(height: 16),
                _buildFormField('Tanggal Lahir', '12 Mei 1985', Icons.calendar_today_outlined),
                const SizedBox(height: 16),
                _buildFormField('Email', 'budi.santoso@email.com', Icons.mail_outline),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String value, IconData? icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
              if (icon != null) Icon(icon, color: AppColors.textLight, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            await FirebaseAuth.instance.signOut();
          } catch (e) {
            debugPrint('Sign out failed: \$e');
          }
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              (route) => false,
            );
          }
        },
        icon: const Icon(Icons.logout, size: 20, color: Colors.white),
        label: const Text(
          'Keluar',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB92B27), // Red button matching design
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
