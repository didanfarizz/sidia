import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor WhatsApp tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Format the number (assuming Indonesian numbers)
    String formattedPhone = phone;
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '+62\${formattedPhone.substring(1)}';
    } else if (!formattedPhone.startsWith('+')) {
      formattedPhone = '+62\$formattedPhone';
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (rare on web/some devices, but good to handle)
          // We let the OTP screen handle actual sign in for consistent flow
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengirim OTP: \${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                verificationId: verificationId,
                phoneNumber: formattedPhone,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handled silently
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      // Fallback for UI testing if Firebase is not configured
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase belum dikonfigurasi. Lanjut ke layar OTP untuk UI Preview.')),
      );
      // Dummy navigation for UI preview
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              verificationId: 'dummy_id',
              phoneNumber: formattedPhone,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button (optional, usually login is root)
                const SizedBox(height: 20),
                
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo_sidia.png',
                    height: 50,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'SIDIA',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // Heading
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masukkan nomor WhatsApp Anda untuk masuk atau mendaftar',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Phone Input Field
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Country Code Prefix
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              '🇮🇩',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '+62',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Input TextField
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText: '812 3456 7890',
                            hintStyle: TextStyle(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Kirim Kode OTP',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Kami akan mengirimkan kode OTP via WhatsApp/SMS\nuntuk verifikasi nomor Anda.',
                    textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}
