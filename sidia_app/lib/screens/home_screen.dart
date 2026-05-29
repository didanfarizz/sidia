import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';
import 'main_navigation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

  Future<List<Map<String, String>>> _fetchNews() async {
    try {
      final response = await http.get(Uri.parse('https://rss.detik.com/index.php/health'));
      if (response.statusCode == 200) {
        final body = response.body;

        final itemReg = RegExp(r'<item>([\s\S]*?)<\/item>');
        final titleReg = RegExp(r'<title><!\[CDATA\[([\s\S]*?)\]\]><\/title>');
        final linkReg = RegExp(r'<link>([\s\S]*?)<\/link>');
        final descReg = RegExp(r'<description><!\[CDATA\[([\s\S]*?)\]\]><\/description>');
        final pubDateReg = RegExp(r'<pubDate>([\s\S]*?)<\/pubDate>');
        final enclosureReg = RegExp(r'<enclosure[^>]*url="([^"]*)"');

        final matches = itemReg.allMatches(body);
        final List<Map<String, String>> list = [];

        for (var match in matches) {
          final item = match.group(1) ?? '';
          
          final titleMatch = titleReg.firstMatch(item);
          final linkMatch = linkReg.firstMatch(item);
          final descMatch = descReg.firstMatch(item);
          final pubDateMatch = pubDateReg.firstMatch(item);
          final enclosureMatch = enclosureReg.firstMatch(item);

          final title = titleMatch?.group(1)?.trim() ?? '';
          final link = linkMatch?.group(1)?.trim() ?? '';
          var desc = descMatch?.group(1)?.trim() ?? '';
          final pubDate = pubDateMatch?.group(1)?.trim() ?? '';
          final image = enclosureMatch?.group(1)?.trim() ?? '';

          desc = desc.replaceAll(RegExp(r'<[^>]*>'), '').trim();

          list.add({
            'title': title,
            'link': link,
            'description': desc,
            'pubDate': pubDate,
            'image': image,
          });

          if (list.length >= 5) break;
        }

        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('Error fetching RSS: $e');
    }

    return [
      {
        'title': 'Mengelola Nutrisi: Panduan Diet Seimbang untuk Diabetisi',
        'link': 'https://www.kemkes.go.id',
        'description': 'Diet seimbang sangat penting bagi penderita diabetes untuk mengontrol kadar gula darah. Pilihlah karbohidrat kompleks dengan indeks glikemik rendah seperti gandum utuh, beras merah, dan perbanyak konsumsi serat dari sayur-sayuran.',
        'pubDate': '3 mnt baca',
        'image': '',
      },
      {
        'title': 'Pentingnya Olahraga Ringan Harian bagi Gula Darah',
        'link': 'https://www.kemkes.go.id',
        'description': 'Aktivitas fisik harian seperti jalan kaki selama 30 menit dapat membantu tubuh menggunakan insulin dengan lebih efisien, sehingga membantu menurunkan kadar gula darah secara stabil.',
        'pubDate': '5 mnt baca',
        'image': '',
      },
      {
        'title': 'Mengenal Gejala Awal Diabetes yang Sering Diabaikan',
        'link': 'https://www.kemkes.go.id',
        'description': 'Banyak orang tidak menyadari gejala awal diabetes seperti sering merasa haus secara berlebihan, frekuensi buang air kecil meningkat di malam hari, dan luka ringan yang membutuhkan waktu sangat lama untuk sembuh.',
        'pubDate': '4 mnt baca',
        'image': '',
      },
      {
        'title': 'Pentingnya Tidur Cukup dalam Menjaga Stabilitas Gula Darah',
        'link': 'https://www.kemkes.go.id',
        'description': 'Kurang tidur berkualitas dapat mengganggu sensitivitas tubuh terhadap hormon insulin, meningkatkan hormon stres seperti kortisol, yang pada akhirnya memicu peningkatan kadar gula darah di pagi hari.',
        'pubDate': '6 mnt baca',
        'image': '',
      },
      {
        'title': 'Manfaat Hidrasi: Mengapa Air Putih Sangat Baik untuk Diabetisi',
        'link': 'https://www.kemkes.go.id',
        'description': 'Minum air putih yang cukup membantu ginjal membuang kelebihan glukosa melalui urine. Hidrasi yang baik juga menjaga konsentrasi darah tetap seimbang dan menurunkan risiko dehidrasi bagi diabetisi.',
        'pubDate': '4 mnt baca',
        'image': '',
      }
    ];
  }

  String _formatPubDate(String pubDate) {
    if (pubDate.isEmpty) return '';
    try {
      final parts = pubDate.split(', ');
      if (parts.length > 1) {
        final datePart = parts[1].split(' +')[0].split(' -')[0];
        return datePart;
      }
      return pubDate;
    } catch (_) {
      return pubDate;
    }
  }

  void _showNewsSummary(BuildContext context, Map<String, String> article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sekilas Informasi',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentBlue,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textLight, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                article['title'] ?? '',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              if (article['image'] != null && article['image']!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      article['image']!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              Text(
                article['description'] ?? '',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final urlString = article['link'] ?? '';
                        if (urlString.isNotEmpty) {
                          final uri = Uri.parse(urlString);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tidak dapat membuka link berita.')),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Baca Selengkapnya',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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
                    child: _buildAssessmentCard(lastDiagnosis),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
  Widget _buildAssessmentCard(Map<String, dynamic>? lastDiagnosis) {
    return GestureDetector(
      onTap: () {
        final mainNav = context.findAncestorStateOfType<MainNavigationState>();
        if (mainNav != null) {
          mainNav.setIndex(2, isDiagnosisMode: true); // Navigasi ke tab Chatbot/Diagnosis (Index 2) dengan mode diagnosis aktif
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(initialDiagnosis: lastDiagnosis),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD6E0FF),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD6E0FF).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge & Navigation Indicator Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              ],
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

            // Beautiful Descriptive Inline Prompt
            Row(
              children: const [
                Text(
                  'Mulai Diagnosis',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentBlue,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: AppColors.accentBlue,
                ),
              ],
            ),
          ],
        ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: const [
              Icon(Icons.menu_book_outlined,
                  size: 20, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Berita Seputar Kesehatan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          FutureBuilder<List<Map<String, String>>>(
            future: _fetchNews(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: CircularProgressIndicator(color: AppColors.primaryNavy),
                  ),
                );
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Gagal memuat berita kesehatan.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
                );
              }

              final articles = snapshot.data!;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: articles.length,
                separatorBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: AppColors.borderLight, height: 1),
                ),
                itemBuilder: (context, index) {
                  final article = articles[index];
                  final isNetworkImage = article['image'] != null && article['image']!.isNotEmpty;
                  return GestureDetector(
                    onTap: () => _showNewsSummary(context, article),
                    child: _buildArticleItem(
                      article['title'] ?? '',
                      _formatPubDate(article['pubDate'] ?? ''),
                      isNetworkImage ? article['image']! : 'assets/images/article_nutrition.jpg',
                      isNetworkImage,
                      index % 2 == 0 ? const Color(0xFF8B5E3C) : const Color(0xFF4A7C59),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(Color placeholderColor) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: placeholderColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.newspaper_rounded,
        color: placeholderColor,
        size: 24,
      ),
    );
  }

  Widget _buildArticleItem(
    String title,
    String readTime,
    String imagePath,
    bool isNetworkImage,
    Color placeholderColor,
  ) {
    return Row(
      children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: isNetworkImage
              ? Image.network(
                  imagePath,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(placeholderColor),
                )
              : Image.asset(
                  imagePath,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(placeholderColor),
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
