import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

              // Greeting
              _buildGreeting(),
              const SizedBox(height: 16),

              // Assessment Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildAssessmentCard(),
              ),
              const SizedBox(height: 16),

              // Health Status Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildHealthStatusCard(),
              ),
              const SizedBox(height: 16),

              // Recent Glucose Trend Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildGlucoseTrendCard(),
              ),
              const SizedBox(height: 16),

              // Insights & Education Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildInsightsCard(),
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

  // ─── Greeting ──────────────────────────────────────────
  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Good Morning, Alex',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Here is your daily health overview.',
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
              children: [
                Icon(Icons.assignment_outlined,
                    size: 14, color: AppColors.accentBlue),
                const SizedBox(width: 6),
                const Text(
                  'Ready for Assessment',
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
            'Start Daily Diagnosis',
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
            'Begin your AI-guided medical data input. We\'ll analyze your current readings to provide immediate insights.',
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
              onPressed: () {},
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
                    'Begin Session',
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
  Widget _buildHealthStatusCard() {
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
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.monitor_heart_outlined,
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              const Text(
                'Health Status',
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Last updated: 2 hours ago',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textLight,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status Circle
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentGreen,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Status: Stabil',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'All vitals in normal range',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.accentGreen.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
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
              Icon(Icons.show_chart_rounded,
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              const Text(
                'Recent Glucose Trend',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bar Chart
          SizedBox(
            height: 160,
            child: _buildBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final data = [
      {'day': 'Mon', 'value': 0.45},
      {'day': 'Tue', 'value': 0.50},
      {'day': 'Wed', 'value': 0.55},
      {'day': 'Thu', 'value': 0.65},
      {'day': 'Today', 'value': 0.78},
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isToday = item['day'] == 'Today';
        final value = item['value'] as double;
        final barHeight = 110.0 * value;

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Value label (only on Today)
              if (isToday)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '105',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                const SizedBox(height: 24),

              // Bar
              Container(
                width: 32,
                height: barHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isToday
                      ? AppColors.accentTeal
                      : AppColors.accentTeal.withValues(alpha: 0.3 + (index * 0.1)),
                ),
              ),
              const SizedBox(height: 8),

              // Day label
              Text(
                item['day'] as String,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                  color: isToday ? AppColors.textPrimary : AppColors.textLight,
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
            color: Colors.black.withValues(alpha: 0.04),
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
              Icon(Icons.menu_book_outlined,
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Insights & Education',
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
                  'View All',
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
            'Managing Nutrition: A Balanced Diet Guide',
            '3 min read',
            'assets/images/article_nutrition.jpg',
            const Color(0xFF8B5E3C),
          ),
          const SizedBox(height: 14),

          // Divider
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 14),

          // Article 2
          _buildArticleItem(
            'The Importance of Light Daily Exercise',
            '5 min read',
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
                  color: placeholderColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: placeholderColor.withValues(alpha: 0.5),
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
                style: TextStyle(
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
