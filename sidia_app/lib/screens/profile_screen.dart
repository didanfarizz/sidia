import 'package:flutter/material.dart';
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
              // Profile Header Card
              _buildProfileHeader(),
              const SizedBox(height: 20),

              // Data Diri Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildDataDiriCard(),
              ),
              const SizedBox(height: 24),

              // Keluar Button
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

  // ─── Profile Header ────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Logo Circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logo_sidia.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildSmallLogo();
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          const Text(
            'Budi Santoso',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Patient ID Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Patient ID: SID-8492',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.accentGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Data Diri Card ────────────────────────────────────
  Widget _buildDataDiriCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.assignment_ind_outlined,
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
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
          const SizedBox(height: 20),

          // Nama Lengkap
          _buildFieldLabel('Nama Lengkap'),
          const SizedBox(height: 6),
          _buildReadOnlyField('Budi Santoso'),
          const SizedBox(height: 16),

          // Jenis Kelamin
          _buildFieldLabel('Jenis Kelamin'),
          const SizedBox(height: 6),
          _buildReadOnlyField('Pria'),
          const SizedBox(height: 16),

          // Tanggal Lahir
          _buildFieldLabel('Tanggal Lahir'),
          const SizedBox(height: 6),
          _buildReadOnlyField(
            '12 Mei 1985',
            suffixIcon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 16),

          // Email
          _buildFieldLabel('Email'),
          const SizedBox(height: 6),
          _buildReadOnlyField(
            'budi.santoso@email.com',
            suffixIcon: Icons.email_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildReadOnlyField(String value, {IconData? suffixIcon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        color: AppColors.bgWhite,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (suffixIcon != null)
            Icon(suffixIcon, size: 20, color: AppColors.textLight),
        ],
      ),
    );
  }

  // ─── Logout Button ─────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              'Keluar',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Fallback Logo ─────────────────────────────────────
  Widget _buildSmallLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SI',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryNavy,
          ),
        ),
        Text(
          'D',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryRed,
          ),
        ),
        Text(
          'IA',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryNavy,
          ),
        ),
      ],
    );
  }
}
