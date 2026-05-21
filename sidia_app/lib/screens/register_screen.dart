import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'main_navigation.dart';

class RegisterScreen extends StatefulWidget {
  final String phoneNumber;
  
  const RegisterScreen({super.key, required this.phoneNumber});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  String _selectedGender = 'Pria';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _saveUserData() async {
    if (_nameController.text.isEmpty || _dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi data diri Anda')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // If user is null, it means we are in UI preview mode without actual Firebase Auth
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'gender': _selectedGender,
          'dateOfBirth': _dobController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': widget.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Mock delay for UI testing
        await Future.delayed(const Duration(seconds: 1));
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: \${e.toString()}')),
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
        title: const Text(
          'Lengkapi Data Diri',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Halo!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lengkapi profil Anda untuk pengalaman diagnosis yang lebih personal dan akurat.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Form
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Nama Lengkap'),
                    _buildTextField(_nameController, 'Misal: Budi Santoso', Icons.person_outline),
                    const SizedBox(height: 20),

                    _buildLabel('Jenis Kelamin'),
                    _buildGenderDropdown(),
                    const SizedBox(height: 20),

                    _buildLabel('Tanggal Lahir'),
                    _buildTextField(
                      _dobController,
                      'DD/MM/YYYY',
                      Icons.calendar_today_outlined,
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Email (Opsional)'),
                    _buildTextField(
                      _emailController,
                      'Misal: budi@email.com',
                      Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveUserData,
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
                          'Simpan & Lanjutkan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedGender = newValue;
              });
            }
          },
          items: <String>['Pria', 'Wanita']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
