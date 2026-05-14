import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ),
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
      backgroundColor: AppColors.bgLoginScreen,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 142, horizontal: 16),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(32),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo SIDIA (kiri)
                    Image.asset(
                      'assets/images/logo_sidia.png',
                      width: 80,
                      height: 36,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildTextLogo();
                      },
                    ),
                    const SizedBox(height: 36),

                    // Welcome Text
                    const Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      'Masuk untuk melanjutkan perjalanan\nkesehatan Anda bersama asisten\ncerdas SIDIA.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Google Sign In Button
                    _buildGoogleButton(),
                    const SizedBox(height: 24),

                    // Divider ATAU
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'ATAU',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Daftar Akun Baru Button
                    _buildRegisterButton(),
                    const SizedBox(height: 32),

                    // Terms & Privacy Text
                    _buildTermsText(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          // TODO: Google Sign In
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: AppColors.bgWhite,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" icon (multi-color)
            Image.asset(
              'assets/images/google_icon.png',
              width: 22,
              height: 22,
              errorBuilder: (context, error, stackTrace) {
                return _buildGoogleIcon();
              },
            ),
            const SizedBox(width: 12),
            const Text(
              'Masuk dengan Google',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const RegisterScreen(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: AppColors.bgWhite,
        ),
        child: const Text(
          'Daftar Akun Baru',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'Dengan masuk, Anda menyetujui '),
            TextSpan(
              text: 'Syarat &\nKetentuan',
              style: const TextStyle(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // TODO: Open Terms
                },
            ),
            const TextSpan(text: ' serta '),
            TextSpan(
              text: 'Kebijakan Privasi',
              style: const TextStyle(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // TODO: Open Privacy Policy
                },
            ),
            const TextSpan(text: ' kami.'),
          ],
        ),
      ),
    );
  }

  /// Fallback Google icon jika asset tidak ada
  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }

  /// Fallback text logo jika asset tidak ada
  Widget _buildTextLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SI',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryNavy,
          ),
        ),
        Text(
          'D',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryRed,
          ),
        ),
        Text(
          'IA',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryNavy,
          ),
        ),
      ],
    );
  }
}

/// Custom painter untuk Google "G" icon berwarna
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w * 0.45;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r + 1, bgPaint);

    // Draw colored "G" using arcs
    final strokeWidth = r * 0.45;

    // Blue (right)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -0.4, 1.2, false, bluePaint,
    );

    // Green (bottom)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      0.8, 1.0, false, greenPaint,
    );

    // Yellow (bottom-left)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      1.8, 0.9, false, yellowPaint,
    );

    // Red (top)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      2.7, 0.9, false, redPaint,
    );

    // Horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(cx - 1, cy - strokeWidth / 2, r + 2, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
