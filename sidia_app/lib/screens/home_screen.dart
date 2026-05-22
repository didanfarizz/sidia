import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'assessment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>> _fetchHomeData() async {
    if (currentUser == null) return {};
    
    String namaLengkap = currentUser?.displayName ?? 'Pengguna';
    Map<String, dynamic>? lastDiagnosis;

    try {
      // Ambil nama pengguna
      final userDoc = await FirebaseFirestore.instance.collection('Pengguna').doc(currentUser!.uid).get();
      if (userDoc.exists) {
        namaLengkap = userDoc.data()?['nama_lengkap'] ?? namaLengkap;
      }

      // Ambil diagnosis terakhir (Asumsi ada koleksi 'Diagnosis')
      final diagnosisQuery = await FirebaseFirestore.instance
          .collection('Diagnosis')
          .where('id_user', isEqualTo: currentUser!.uid)
          .get();
          
      if (diagnosisQuery.docs.isNotEmpty) {
        final docs = diagnosisQuery.docs.toList();
        docs.sort((a, b) {
          final aTime = a.data()['createdAt'] as Timestamp?;
          final bTime = b.data()['createdAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
        lastDiagnosis = docs.first.data();
      }
    } catch (e) {
      debugPrint('Error fetching home data: $e');
      // Firebase index error is expected if composite index is missing, we handle gracefully.
    }

    return {
      'nama_lengkap': namaLengkap,
      'last_diagnosis': lastDiagnosis,
    };
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchHomeData(),
          builder: (context, snapshot) {
            final nama = snapshot.data?['nama_lengkap'] ?? '...';
            final lastDiagnosis = snapshot.data?['last_diagnosis'];
            final isLoading = snapshot.connectionState == ConnectionState.waiting;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  _buildTopBar(),

                  // Greeting
                  _buildGreeting(nama, isLoading),
                  const SizedBox(height: 16),

                  // Assessment Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildAssessmentCard(),
                  ),
                  const SizedBox(height: 16),

                  // Health Status / Diagnosis Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildHealthStatusCard(lastDiagnosis, isLoading),
                  ),
                  const SizedBox(height: 16),

                  // Berita Edukasi Diabetes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildInsightsCard(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Top Bar ───────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryNavy,
              border: Border.all(
                color: AppColors.border,
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/avatar_user.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 22),
                  );
                },
              ),
            ),
          ),
          const Spacer(),

          // SIDIA Logo (center)
          Image.asset(
            'assets/images/logo_sidia.png',
            width: 70,
            height: 28,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildTextLogo();
            },
          ),
          const Spacer(),

          // Settings Icon
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgGrey,
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Greeting ──────────────────────────────────────────
  Widget _buildGreeting(String name, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getGreeting()}, ${isLoading ? "..." : name}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Berikut adalah ringkasan kesehatan Anda hari ini.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Assessment Card ───────────────────────────────────
  Widget _buildAssessmentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD6E0FF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD6E0FF)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.assignment_outlined,
                    size: 14, color: AppColors.accentBlue),
                SizedBox(width: 6),
                Text(
                  'Siap untuk Diagnosis',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Title
          const Text(
            'Mulai Diagnosis Harian',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Description
          const Text(
            'Mulai sesi input data medis Anda yang dipandu oleh AI. Kami akan menganalisis data Anda untuk memberikan wawasan medis yang akurat.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Begin Session Button
          SizedBox(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AssessmentScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Mulai Sesi',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Health Status Card ────────────────────────────────
  Widget _buildHealthStatusCard(Map<String, dynamic>? lastDiagnosis, bool isLoading) {
    String status = 'Belum Ada Riwayat';
    String desc = 'Silakan mulai diagnosis pertama Anda.';
    Color color = AppColors.textSecondary;
    IconData icon = Icons.history_rounded;
    String dateStr = '';

    if (lastDiagnosis != null) {
      status = lastDiagnosis['status_diagnosis'] ?? 'Selesai';
      desc = lastDiagnosis['deskripsi_singkat'] ?? 'Lihat hasil selengkapnya.';
      color = AppColors.accentGreen;
      icon = Icons.check_circle_outline;
      
      if (status.toLowerCase().contains('diabetes') || status.toLowerCase().contains('perhatian')) {
        color = AppColors.accentOrange;
        icon = Icons.warning_amber_rounded;
      }
      
      if (lastDiagnosis['createdAt'] != null) {
        try {
          final dt = (lastDiagnosis['createdAt'] as Timestamp).toDate();
          dateStr = 'Terakhir diperbarui: ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt)}';
        } catch (e) {
          dateStr = '';
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: const [
              Icon(Icons.monitor_heart_outlined,
                  size: 20, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text(
                'Ringkasan Diagnosis Terakhir',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (dateStr.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                dateStr,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Status Content
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    status,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: color.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─── Insights & Education Card ─────────────────────────
  Widget _buildInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.menu_book_outlined,
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Berita Seputar Diabetes',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Article 1
          _buildArticleItem(
            'Mengelola Nutrisi: Panduan Diet Seimbang untuk Diabetisi',
            '3 mnt baca',
            'assets/images/article_nutrition.jpg',
            const Color(0xFF8B5E3C),
          ),
          const SizedBox(height: 14),

          // Divider
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 14),

          // Article 2
          _buildArticleItem(
            'Pentingnya Olahraga Ringan Harian bagi Gula Darah',
            '5 mnt baca',
            'assets/images/article_exercise.jpg',
            const Color(0xFF4A7C59),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleItem(
    String title,
    String readTime,
    String imagePath,
    Color placeholderColor,
  ) {
    return Row(
      children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: placeholderColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: placeholderColor.withOpacity(0.5),
                  size: 24,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                readTime,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Text Logo Fallback ────────────────────────────────
  Widget _buildTextLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
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
