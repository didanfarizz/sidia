import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _hasStarted = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),

            if (!_hasStarted)
              Expanded(child: _buildIntroScreen())
            else ...[
              // Messages
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // Date separator
                    _buildDateSeparator('Today, 9:41 AM'),
                    const SizedBox(height: 16),

                    // AI Message 1
                    _buildAIMessage(
                      _buildRichText1(),
                    ),
                    const SizedBox(height: 12),

                    // User Message 1
                    _buildUserMessage(
                      'I feel okay, maybe a little more tired than usual. I did have a larger pasta dinner last night around 8 PM. Could that be it?',
                      '9:45 AM',
                    ),
                    const SizedBox(height: 12),

                    // AI Message 2
                    _buildAIMessage(
                      _buildRichText2(),
                    ),
                    const SizedBox(height: 4),

                    // Diagnostic Analysis Card (embedded in chat)
                    _buildDiagnosticCard(),
                    const SizedBox(height: 4),

                    // Recommendation Box
                    _buildRecommendationBox(),
                    const SizedBox(height: 16),

                    // Typing indicator
                    _buildTypingIndicator(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Input Area
              _buildInputArea(),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Top Bar ───────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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

  // ─── Intro Screen (Empty State) ────────────────────────
  Widget _buildIntroScreen() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Robot Avatar
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentBlue,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.smart_toy,
                          color: Colors.white,
                          size: 45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Heading
                    const Text(
                      'Halo!',
                      style: TextStyle(
                        fontFamily: 'Georgia', // Using a serif-like font similar to design
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtitle
                    const Text(
                      'Saya Asisten SIDIA Anda. Mari kita mulai proses penilaian risiko diabetes Anda untuk mendapatkan panduan medis yang tepat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Button Area
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasStarted = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E40AF), // Deeper blue matching design
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Mulai Diagnosis',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'SIDIA can make mistakes. Always consult your primary care physician for final medical decisions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Date Separator ────────────────────────────────────
  Widget _buildDateSeparator(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bgGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textLight,
          ),
        ),
      ),
    );
  }

  // ─── AI Message ────────────────────────────────────────
  Widget _buildAIMessage(Widget content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // S Avatar
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryNavy,
          ),
          child: const Center(
            child: Text(
              'S',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SIDIA label
              const Text(
                'SIDIA',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              // Bubble
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: content,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── User Message ──────────────────────────────────────
  Widget _buildUserMessage(String text, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  // ─── Rich Text for AI Message 1 ────────────────────────
  Widget _buildRichText1() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
        children: [
          TextSpan(
            text:
                'Hello. I\'ve reviewed your latest fasting blood glucose readings and the dietary log from yesterday. Your morning reading was ',
          ),
          TextSpan(
            text: '112 mg/dL',
            style: TextStyle(
              color: AppColors.accentBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text:
                ', which is slightly elevated from your baseline. How are you feeling this morning? Have you experienced any unusual fatigue or thirst?',
          ),
        ],
      ),
    );
  }

  // ─── Rich Text for AI Message 2 ────────────────────────
  Widget _buildRichText2() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
        children: [
          TextSpan(
            text:
                'Based on your elevated fasting reading, reported fatigue, and previous health markers in your history, I have performed a diagnostic analysis. There is a ',
          ),
          TextSpan(
            text: '90% probability of Type 2 Diabetes',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: ' or pre-diabetes.'),
        ],
      ),
    );
  }

  // ─── Diagnostic Analysis Card ──────────────────────────
  Widget _buildDiagnosticCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Diagnostic Analysis',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.assessment_outlined,
                    size: 18, color: AppColors.accentBlue),
              ],
            ),
            const SizedBox(height: 16),

            // Data rows
            _buildDiagnosticRow('Primary\nCondition', 'Type 2\nDiabetes',
                isBold: true),
            const Divider(color: AppColors.borderLight, height: 24),
            _buildDiagnosticRow('Probability', '90%',
                valueColor: AppColors.primaryRed),
            const Divider(color: AppColors.borderLight, height: 24),
            _buildDiagnosticRow('Confidence Score', 'High',
                valueColor: AppColors.accentGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── Recommendation Box ────────────────────────────────
  Widget _buildRecommendationBox() {
    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: AppColors.accentOrange,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendation:',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.accentOrange,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Given the 90% probability, we strongly advise scheduling an HbA1c test with your primary care physician to confirm the diagnosis and discuss management strategies immediately.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Typing Indicator ──────────────────────────────────
  Widget _buildTypingIndicator() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Placeholder for alignment
        const SizedBox(width: 36),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            '...',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Input Area ────────────────────────────────────────
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Input Row
          Row(
            children: [
              // + Button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgGrey,
                ),
                child: const Icon(Icons.add,
                    color: AppColors.textSecondary, size: 22),
              ),
              const SizedBox(width: 10),

              // Text Field
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bgGrey,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message or describe\nsymptoms...',
                      hintMaxLines: 2,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Send Button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentBlue,
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Disclaimer
          Text(
            'SIDIA can make mistakes. Always consult your primary care physician for final medical decisions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: AppColors.textLight,
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
