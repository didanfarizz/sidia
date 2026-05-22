import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>?> _fetchUserData() async {
    if (currentUser == null) return null;
    
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Pengguna')
          .doc(currentUser!.uid)
          .get();
          
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data;
            final namaLengkap = userData?['nama_lengkap'] ?? currentUser?.displayName ?? 'Pengguna';
            final email = userData?['email'] ?? currentUser?.email ?? 'Tidak ada email';
            final jenisKelamin = userData?['jenis_kelamin'] ?? 'Belum Diatur';
            
            // Format Tanggal Lahir
            String tanggalLahir = 'Belum Diatur';
            if (userData != null && userData['tanggal_lahir'] != null) {
              try {
                final date = DateTime.parse(userData['tanggal_lahir']);
                tanggalLahir = DateFormat('dd MMMM yyyy', 'id_ID').format(date);
              } catch (e) {
                tanggalLahir = 'Format Tanggal Salah';
              }
            }

            // Potong UID untuk Patient ID (8 karakter pertama)
            final patientId = currentUser?.uid != null 
                ? 'SID-${currentUser!.uid.substring(0, 8).toUpperCase()}' 
                : 'SID-UNKNOWN';

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Top Section
                  _buildTopSection(namaLengkap, patientId),
                  
                  // Data Diri Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildDataDiriCard(namaLengkap, jenisKelamin, tanggalLahir, email),
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
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildTopSection(String name, String patientId) {
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
                  color: Colors.black.withOpacity(0.05),
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
          Text(
            name,
            style: const TextStyle(
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
            child: Text(
              'Patient ID: $patientId',
              style: const TextStyle(
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

  Widget _buildDataDiriCard(String name, String gender, String dob, String email) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                _buildFormField('Nama Lengkap', name, null),
                const SizedBox(height: 16),
                _buildFormField('Jenis Kelamin', gender, null),
                const SizedBox(height: 16),
                _buildFormField('Tanggal Lahir', dob, Icons.calendar_today_outlined),
                const SizedBox(height: 16),
                _buildFormField('Email', email, Icons.mail_outline),
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
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
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
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Konfirmasi Keluar', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              content: const Text('Apakah Anda yakin ingin keluar dari akun ini?', style: TextStyle(fontFamily: 'Poppins')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Keluar', style: TextStyle(fontFamily: 'Poppins', color: AppColors.primaryRed)),
                ),
              ],
            ),
          );

          if (confirm == true) {
            try {
              await FirebaseAuth.instance.signOut();
            } catch (e) {
              debugPrint('Sign out failed: $e');
            }
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            }
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
