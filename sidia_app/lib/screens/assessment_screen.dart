import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'diagnosis_result_screen.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _currentStep = 0;
  final int _totalSteps = 7;

  // Step data
  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Personal Details',
      'subtitle': 'Kita perlu mengetahui beberapa data kesehatan\nAnda untuk diagnosis yang lebih akurat',
      'icon': Icons.person_outline,
    },
    {
      'title': 'Physical Measurements',
      'subtitle': 'Masukkan data pengukuran fisik Anda',
      'icon': Icons.straighten_outlined,
    },
    {
      'title': 'Symptoms Checklist',
      'subtitle': 'Pilih gejala yang Anda alami',
      'icon': Icons.checklist_outlined,
    },
    {
      'title': 'Medical History',
      'subtitle': 'Riwayat kesehatan keluarga dan pribadi',
      'icon': Icons.medical_services_outlined,
    },
    {
      'title': 'Lifestyle Habits',
      'subtitle': 'Kebiasaan gaya hidup sehari-hari',
      'icon': Icons.directions_run_outlined,
    },
    {
      'title': 'Blood Test Results',
      'subtitle': 'Masukkan hasil tes darah terakhir',
      'icon': Icons.bloodtype_outlined,
    },
    {
      'title': 'Review & Finalize',
      'subtitle': 'Tinjau semua data yang telah diisi',
      'icon': Icons.fact_check_outlined,
    },
  ];

  // Symptom data
  final List<Map<String, dynamic>> _symptoms = [
    {'name': 'Sering haus', 'selected': false, 'icon': Icons.water_drop_outlined},
    {'name': 'Sering buang air kecil', 'selected': false, 'icon': Icons.wc_outlined},
    {'name': 'Penurunan berat badan', 'selected': false, 'icon': Icons.monitor_weight_outlined},
    {'name': 'Kelelahan', 'selected': false, 'icon': Icons.battery_1_bar},
    {'name': 'Penglihatan kabur', 'selected': false, 'icon': Icons.visibility_off_outlined},
    {'name': 'Luka sulit sembuh', 'selected': false, 'icon': Icons.healing_outlined},
    {'name': 'Kesemutan', 'selected': false, 'icon': Icons.back_hand_outlined},
    {'name': 'Gatal-gatal', 'selected': false, 'icon': Icons.dry_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            _buildAppBar(),

            // Progress bar
            _buildProgressBar(),

            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildStepContent(),
              ),
            ),

            // Bottom buttons
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.bgWhite,
      child: Row(
        children: [
          if (_currentStep > 0)
            GestureDetector(
              onTap: () {
                setState(() => _currentStep--);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.bgGrey,
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 18, color: AppColors.textPrimary),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  _steps[_currentStep]['title'],
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.bgGrey,
            ),
            child: Icon(
              _steps[_currentStep]['icon'],
              size: 20,
              color: AppColors.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppColors.bgWhite,
      child: Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 4 : 0),
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: isCompleted
                        ? AppColors.accentGreen
                        : isCurrent
                            ? AppColors.primaryNavy
                            : AppColors.bgGrey,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _steps[_currentStep]['subtitle'],
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalDetailsStep();
      case 1:
        return _buildPhysicalMeasurementsStep();
      case 2:
        return _buildSymptomsStep();
      case 3:
        return _buildMedicalHistoryStep();
      case 4:
        return _buildLifestyleStep();
      case 5:
        return _buildBloodTestStep();
      case 6:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormField('Nama Lengkap', 'Masukkan nama lengkap', Icons.person_outline),
        const SizedBox(height: 16),
        _buildFormField('Usia', 'Masukkan usia', Icons.cake_outlined,
            keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildLabel('Jenis Kelamin'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildOptionChip('Pria', true)),
            const SizedBox(width: 12),
            Expanded(child: _buildOptionChip('Wanita', false)),
          ],
        ),
        const SizedBox(height: 16),
        _buildFormField('Riwayat Diabetes Keluarga', 'Ya / Tidak',
            Icons.family_restroom_outlined),
      ],
    );
  }

  Widget _buildPhysicalMeasurementsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormField('Berat Badan (kg)', 'Masukkan berat badan',
            Icons.monitor_weight_outlined,
            keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildFormField('Tinggi Badan (cm)', 'Masukkan tinggi badan',
            Icons.height,
            keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildFormField('Lingkar Pinggang (cm)', 'Masukkan lingkar pinggang',
            Icons.straighten_outlined,
            keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        // BMI Calculator card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentTeal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calculate_outlined,
                    color: AppColors.accentTeal, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMI Calculator',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'BMI will be calculated automatically',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '--',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentTeal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih gejala yang Anda alami saat ini:',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_symptoms.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _symptoms[index]['selected'] =
                      !_symptoms[index]['selected'];
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _symptoms[index]['selected']
                      ? AppColors.primaryNavy.withValues(alpha: 0.06)
                      : AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _symptoms[index]['selected']
                        ? AppColors.primaryNavy
                        : AppColors.border,
                    width: _symptoms[index]['selected'] ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _symptoms[index]['icon'],
                      size: 22,
                      color: _symptoms[index]['selected']
                          ? AppColors.primaryNavy
                          : AppColors.textLight,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _symptoms[index]['name'],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: _symptoms[index]['selected']
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _symptoms[index]['selected']
                              ? AppColors.primaryNavy
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: _symptoms[index]['selected']
                            ? AppColors.primaryNavy
                            : AppColors.bgGrey,
                        border: Border.all(
                          color: _symptoms[index]['selected']
                              ? AppColors.primaryNavy
                              : AppColors.border,
                        ),
                      ),
                      child: _symptoms[index]['selected']
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMedicalHistoryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Riwayat Penyakit'),
        const SizedBox(height: 8),
        _buildMultiSelectItem('Hipertensi', false),
        const SizedBox(height: 8),
        _buildMultiSelectItem('Penyakit Jantung', false),
        const SizedBox(height: 8),
        _buildMultiSelectItem('Kolesterol Tinggi', false),
        const SizedBox(height: 8),
        _buildMultiSelectItem('Obesitas', false),
        const SizedBox(height: 20),
        _buildLabel('Obat yang Dikonsumsi'),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Tuliskan obat yang sedang dikonsumsi...',
          ),
        ),
        const SizedBox(height: 20),
        _buildLabel('Riwayat Diabetes Keluarga'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildOptionChip('Ya', true)),
            const SizedBox(width: 12),
            Expanded(child: _buildOptionChip('Tidak', false)),
          ],
        ),
      ],
    );
  }

  Widget _buildLifestyleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Frekuensi Olahraga'),
        const SizedBox(height: 8),
        _buildDropdownField('Pilih frekuensi'),
        const SizedBox(height: 16),
        _buildLabel('Pola Makan'),
        const SizedBox(height: 8),
        _buildDropdownField('Pilih pola makan'),
        const SizedBox(height: 16),
        _buildLabel('Merokok'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildOptionChip('Ya', false)),
            const SizedBox(width: 12),
            Expanded(child: _buildOptionChip('Tidak', true)),
          ],
        ),
        const SizedBox(height: 16),
        _buildLabel('Konsumsi Alkohol'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildOptionChip('Ya', false)),
            const SizedBox(width: 12),
            Expanded(child: _buildOptionChip('Tidak', true)),
          ],
        ),
        const SizedBox(height: 16),
        _buildLabel('Jam Tidur per Hari'),
        const SizedBox(height: 8),
        _buildFormField('', 'Masukkan jam tidur', Icons.bedtime_outlined,
            keyboardType: TextInputType.number),
      ],
    );
  }

  Widget _buildBloodTestStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Masukkan hasil tes darah terakhir Anda jika tersedia',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildFormField('Gula Darah Puasa (mg/dL)', 'Masukkan nilai',
            Icons.bloodtype_outlined,
            keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildFormField('HbA1c (%)', 'Masukkan nilai',
            Icons.science_outlined,
            keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildFormField('Tekanan Darah Sistolik', 'Masukkan nilai',
            Icons.favorite_outline,
            keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildFormField('Tekanan Darah Diastolik', 'Masukkan nilai',
            Icons.favorite_outline,
            keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildFormField('Kolesterol Total (mg/dL)', 'Masukkan nilai',
            Icons.water_drop_outlined,
            keyboardType: TextInputType.number),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Lengkap!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Semua data telah diisi. Tinjau sebelum mengirim.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildReviewSection('Data Pribadi', [
          _buildReviewItem('Nama', 'Budi Santoso'),
          _buildReviewItem('Usia', '35 tahun'),
          _buildReviewItem('Jenis Kelamin', 'Pria'),
        ]),
        const SizedBox(height: 16),

        _buildReviewSection('Pengukuran Fisik', [
          _buildReviewItem('Berat Badan', '75 kg'),
          _buildReviewItem('Tinggi Badan', '170 cm'),
          _buildReviewItem('BMI', '25.9'),
        ]),
        const SizedBox(height: 16),

        _buildReviewSection('Gejala', [
          _buildReviewItem('Gejala Terpilih', 'Sering haus, Kelelahan'),
        ]),
        const SizedBox(height: 16),

        _buildReviewSection('Hasil Tes Darah', [
          _buildReviewItem('Gula Darah Puasa', '126 mg/dL'),
          _buildReviewItem('HbA1c', '6.5%'),
        ]),
      ],
    );
  }

  Widget _buildReviewSection(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryNavy,
            ),
          ),
          const Divider(color: AppColors.borderLight),
          ...items,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String hint, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          _buildLabel(label),
          const SizedBox(height: 8),
        ],
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildOptionChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryNavy : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? AppColors.primaryNavy.withValues(alpha: 0.05)
            : AppColors.bgWhite,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primaryNavy : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectItem(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryNavy : AppColors.border,
        ),
        color: isSelected
            ? AppColors.primaryNavy.withValues(alpha: 0.05)
            : AppColors.bgWhite,
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? AppColors.primaryNavy : AppColors.border,
              ),
              color: isSelected ? AppColors.primaryNavy : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        color: AppColors.bgWhite,
      ),
      child: Row(
        children: [
          Text(
            hint,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textLight, size: 22),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _currentStep--);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sebelumnya',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep < _totalSteps - 1) {
                  setState(() => _currentStep++);
                } else {
                  // Navigate to results
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DiagnosisResultScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentStep == _totalSteps - 1
                    ? AppColors.accentTeal
                    : AppColors.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep == _totalSteps - 1
                    ? 'Kirim Diagnosis'
                    : 'Selanjutnya',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
