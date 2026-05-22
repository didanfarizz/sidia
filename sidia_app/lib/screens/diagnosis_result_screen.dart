import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DiagnosisResultScreen extends StatefulWidget {
  final Map<String, dynamic>? diagnosisData;

  const DiagnosisResultScreen({super.key, this.diagnosisData});

  @override
  State<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Results content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Diagnosis Card
                      _buildDiagnosisCard(),
                      const SizedBox(height: 20),

                      // Severity & Confidence
                      _buildMetricsRow(),
                      const SizedBox(height: 20),

                      // Recommendations
                      _buildRecommendationsCard(),
                      const SizedBox(height: 20),

                      // SIDIA Logo Card
                      _buildSidiaCard(),
                      const SizedBox(height: 20),

                      // Action Buttons
                      _buildActionButtons(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hasil Pemeriksaan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.share_outlined,
                    color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Analisis medis pendeteksi masalah diabetes Anda telah tersedia',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard() {
    final status = widget.diagnosisData?['status_diagnosis'] ?? 'Perlu Perhatian';
    final primaryAssesment = widget.diagnosisData?['primary_assessment'] ?? 'Type 2 Diabetes';
    
    bool isWarning = status.toLowerCase().contains('perhatian') || status.toLowerCase().contains('diabetes');
    Color badgeColor = isWarning ? AppColors.accentOrange : AppColors.accentGreen;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: badgeColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main diagnosis icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isWarning 
                  ? [const Color(0xFFF59E0B), const Color(0xFFFBBF24)]
                  : [AppColors.accentTeal, const Color(0xFF14B8A6)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: badgeColor.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.analytics_outlined,
                  color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Diagnostic Analysis 📊',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'Primary Assessment',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              primaryAssesment,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    final severity = widget.diagnosisData?['severity'] ?? '90%';
    final confidence = widget.diagnosisData?['confidence_score'] ?? 'High';
    
    // Determine color based on severity string if possible, else default
    Color severityColor = AppColors.primaryRed;
    if (severity.contains('%')) {
      final val = int.tryParse(severity.replaceAll('%', ''));
      if (val != null && val < 50) severityColor = AppColors.accentOrange;
      if (val != null && val < 20) severityColor = AppColors.accentGreen;
    } else if (severity.toLowerCase() == 'low' || severity.toLowerCase() == 'rendah') {
      severityColor = AppColors.accentGreen;
    }

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Tingkat Risiko',
            severity,
            severityColor,
            Icons.warning_amber_rounded,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildMetricCard(
            'Tingkat Keyakinan',
            confidence,
            AppColors.accentTeal,
            Icons.verified_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    List<dynamic> rawRecs = widget.diagnosisData?['recommendations'] ?? [
      'Konsultasikan segera dengan dokter spesialis endokrinologi',
      'Terapkan pola makan rendah gula, perbanyak serat dan sayuran hijau',
      'Lakukan olahraga ringan-sedang minimal 30 menit per hari',
      'Monitor gula darah secara teratur, minimal 2x sehari',
      'Jaga pola tidur 7-8 jam setiap malam',
    ];
    
    // Predefined emojis based on index for simplicity, or we can just use dots
    List<String> emojis = ['🏥', '🍽️', '🏃', '💊', '😴', '💡', '💧'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lightbulb_outline,
                    color: AppColors.accentBlue, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Rekomendasi',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(rawRecs.length, (index) {
            final emoji = index < emojis.length ? emojis[index] : '📌';
            return _buildRecommendationItem(emoji, rawRecs[index].toString());
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidiaCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryNavy, Color(0xFF2D4A7A)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          // Logo
          Image.asset(
            'assets/images/logo_sidia_white.png',
            width: 100,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('SI',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  Text('D',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryRed)),
                  Text('IA',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Jamin keamanan data Anda dengan konsultasi langsung bersama tim profesional kami',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Kami membantu untuk melakukan pengecekan data agar akurasi pendeteksian diabetes yang dilakukan Anda semakin optimal dengan kerjasama tim ahli kami.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Chat with AI button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.chat_outlined, size: 20),
            label: const Text(
              'Tutup Halaman',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Download / Share
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text(
                  'Unduh',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryNavy,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text(
                  'Bagikan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryNavy,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
