import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HealthInsightsScreen extends StatelessWidget {
  const HealthInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              _buildTopBar(),

              // Title & Subtitle
              _buildTitleSection(),
              const SizedBox(height: 16),

              // Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatsCards(),
              ),
              const SizedBox(height: 16),

              // Tren Gula Darah Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildGlucoseTrendCard(),
              ),
              const SizedBox(height: 16),

              // Ringkasan AI Personal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildAISummaryCard(),
              ),
              const SizedBox(height: 16),

              // Achievement Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildAchievementCard(),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
              border: Border.all(color: AppColors.border, width: 1.5),
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

          // SIDIA Logo
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgGrey,
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Title Section ─────────────────────────────────────
  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Insights',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Analitik dan ringkasan kesehatan personal Anda.',
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

  // ─── Stats Cards ───────────────────────────────────────
  Widget _buildStatsCards() {
    return Column(
      children: [
        // Rata-rata Gula Darah
        _buildStatCard(
          label: 'Rata-rata Gula Darah',
          value: '112',
          unit: 'mg/dL',
          icon: Icons.water_drop_outlined,
          iconColor: AppColors.accentBlue,
        ),
        const SizedBox(height: 10),

        // Frekuensi Gejala
        _buildStatCard(
          label: 'Frekuensi Gejala (7 Hari)',
          value: '2',
          unit: 'kali',
          icon: Icons.verified_outlined,
          iconColor: AppColors.accentGreen,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      unit,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }

  // ─── Glucose Trend Card ────────────────────────────────
  Widget _buildGlucoseTrendCard() {
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
              Icon(Icons.bar_chart_rounded,
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tren Gula Darah (7 Hari Terakhir)',
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
          const SizedBox(height: 20),

          // Chart Area
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.bgGrey,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                // Grid lines
                ...List.generate(4, (i) {
                  return Positioned(
                    left: 0,
                    right: 0,
                    top: 20.0 + (i * 30),
                    child: Container(
                      height: 1,
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  );
                }),
                // Bars
                Positioned(
                  bottom: 10,
                  left: 20,
                  right: 20,
                  top: 10,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildChartBar(0.5, false),
                      _buildChartBar(0.6, false),
                      _buildChartBar(0.45, false),
                      _buildChartBar(0.7, true),
                      _buildChartBar(0.55, false),
                      _buildChartBar(0.65, false),
                      _buildChartBar(0.6, false),
                    ],
                  ),
                ),
                // "Chart Visualization Area" label
                Center(
                  child: Text(
                    'Chart Visualization Area',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(AppColors.accentGreen, 'Normal'),
              const SizedBox(width: 20),
              _buildLegend(AppColors.primaryRed, 'Tinggi'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(double heightFactor, bool isHighlighted) {
    return Container(
      width: 24,
      height: 100 * heightFactor,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: isHighlighted
            ? AppColors.primaryRed.withValues(alpha: 0.6)
            : AppColors.accentGreen.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ─── AI Summary Card ───────────────────────────────────
  Widget _buildAISummaryCard() {
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
              Icon(Icons.psychology_outlined,
                  size: 20, color: AppColors.accentBlue),
              const SizedBox(width: 8),
              const Text(
                'Ringkasan AI Personal',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Summary Text
          const Text(
            'Berdasarkan data minggu ini, tingkat glukosa Anda menunjukkan tren yang lebih stabil dibandingkan minggu lalu. Lonjakan pada hari Kamis tampaknya berkorelasi dengan asupan karbohidrat tinggi saat makan malam.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),

          // Tip Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.accentBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              'Pertimbangkan untuk berjalan santai 15 menit setelah makan malam untuk membantu menstabilkan gula darah malam hari Anda. Pertahankan rutinitas pemantauan pagi Anda yang konsisten!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.accentBlue,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Achievement Card ──────────────────────────────────
  Widget _buildAchievementCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
        children: [
          // Achievement Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentTeal.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: AppColors.accentTeal,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),

          // Title
          const Text(
            'Konsisten 7 Hari!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            'Anda telah mencatat data gula darah Anda secara berturut-turut. Teruskan kerja bagus ini!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Text Logo Fallback ────────────────────────────────
  Widget _buildTextLogo() {
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
