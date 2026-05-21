import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'main_navigation.dart';
import 'register_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() async {
    final smsCode = _otpController.text.trim();
    if (smsCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan 6 digit kode OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Mock logic if verificationId is 'dummy_id' (Firebase not configured)
      if (widget.verificationId == 'dummy_id') {
        await Future.delayed(const Duration(seconds: 1));
        // Mock successful login -> Go to Register for UI preview
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterScreen(phoneNumber: widget.phoneNumber),
            ),
          );
        }
        return;
      }

      // Real Firebase verification
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Check if user has completed profile in Firestore
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (!mounted) return;

        if (userDoc.exists) {
          // User already has profile -> Go to Home
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false,
          );
        } else {
          // New user -> Go to Register / Data Diri
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterScreen(phoneNumber: widget.phoneNumber),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kode OTP salah atau kedaluwarsa: \${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Verifikasi Kode',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Masukkan 6 digit kode OTP yang telah dikirimkan ke nomor '),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // OTP Input Field
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
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                    hintStyle: TextStyle(
                      color: AppColors.textLight,
                      letterSpacing: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                  ),
                  onChanged: (val) {
                    if (val.length == 6) {
                      _verifyOtp();
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
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
                          'Verifikasi',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum menerima kode? ',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Resend logic
                    },
                    child: const Text(
                      'Kirim Ulang',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
