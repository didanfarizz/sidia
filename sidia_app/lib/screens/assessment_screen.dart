import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _currentStep = 0;
  final int _totalSteps = 3;
  bool _isLoading = false;

  // Controllers Phase 1
  final TextEditingController _usiaController = TextEditingController();
  final TextEditingController _beratController = TextEditingController();
  final TextEditingController _tinggiController = TextEditingController();
  String? _jenisKelamin;
  String? _riwayatKeluarga;

  // Symptoms Phase 2
  final List<Map<String, dynamic>> _symptoms = [
    {'id': 'G01', 'name': 'Poliuria (Sering Buang Air Kecil)', 'cf': 0.9, 'selected': false},
    {'id': 'G02', 'name': 'Polidipsia (Sering Haus)', 'cf': 0.9, 'selected': false},
    {'id': 'G03', 'name': 'Polifagia (Sering Lapar)', 'cf': 0.9, 'selected': false},
    {'id': 'G04', 'name': 'Penurunan Berat Badan Tanpa Sebab', 'cf': 0.7, 'selected': false},
    {'id': 'G05', 'name': 'Kesemutan/Mati Rasa', 'cf': 0.7, 'selected': false},
    {'id': 'G06', 'name': 'Luka Sulit Sembuh', 'cf': 0.7, 'selected': false},
    {'id': 'G07', 'name': 'Penglihatan Kabur/Buram', 'cf': 0.8, 'selected': false},
  ];

  bool _noSymptoms = false;

  final List<String> _stepTitles = [
    'Physical Metrics',
    'Symptoms Checklist',
    'Review & Process'
  ];

  @override
  void dispose() {
    _usiaController.dispose();
    _beratController.dispose();
    _tinggiController.dispose();
    super.dispose();
  }

  // --- CF Calculation Logic ---
  Future<void> _processAnalysis() async {
    if (_usiaController.text.isEmpty || 
        _beratController.text.isEmpty || 
        _tinggiController.text.isEmpty || 
        _jenisKelamin == null || 
        _riwayatKeluarga == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data wajib pada Step 1.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulasi loading analisis AI sesuai permintaan
      await Future.delayed(const Duration(seconds: 2));

      final double usia = double.tryParse(_usiaController.text) ?? 0;
      final double berat = double.tryParse(_beratController.text) ?? 0;
      final double tinggiCm = double.tryParse(_tinggiController.text) ?? 1;
      final double tinggiM = tinggiCm / 100;
      final double imt = berat / (tinggiM * tinggiM);

      List<double> cfValues = [];

      // Risk Factors
      if (usia > 40) cfValues.add(0.4); // F01
      if (imt >= 23) cfValues.add(0.4); // F02
      if (_riwayatKeluarga == 'Ya') cfValues.add(0.8); // F03

      // Symptoms
      List<String> selectedSymptoms = [];
      for (var s in _symptoms) {
        if (s['selected'] == true) {
          cfValues.add(s['cf']);
          selectedSymptoms.add(s['name']);
        }
      }

      // Calculate CF Combine
      double finalCf = 0.0;
      if (cfValues.isNotEmpty) {
        finalCf = cfValues[0];
        for (int i = 1; i < cfValues.length; i++) {
          finalCf = finalCf + cfValues[i] * (1 - finalCf);
        }
      }

      double percentage = finalCf * 100;

      // Determine Risk Level & Recommendations
      String riskLevel = '';
      List<String> recommendationsList = [];

      if (percentage < 50) {
        riskLevel = 'Risiko Rendah';
        recommendationsList = [
          'Tetap jaga pola hidup sehat.',
          'Lakukan diagnosis berkala jika ada keluhan tambahan.',
          'Pertahankan indeks massa tubuh (IMT) ideal.',
        ];
      } else if (percentage < 70) {
        riskLevel = 'Risiko Sedang';
        recommendationsList = [
          'Pantau kadar gula darah mandiri secara rutin.',
          'Perbaiki pola makan dengan mengurangi konsumsi gula dan karbohidrat sederhana.',
          'Lakukan olahraga ringan hingga sedang 30 menit sehari.',
        ];
      } else if (percentage < 80) {
        riskLevel = 'Risiko Cukup Tinggi';
        recommendationsList = [
          'Segera konsultasi dengan tenaga medis atau dokter terdekat.',
          'Lakukan pengecekan HbA1c dan gula darah puasa di laboratorium.',
          'Jaga asupan makan dengan sangat disiplin.',
        ];
      } else {
        riskLevel = 'Risiko Tinggi';
        recommendationsList = [
          'Segera lakukan pemeriksaan medis formal di fasilitas kesehatan terdekat.',
          'Konsultasikan segera dengan dokter spesialis endokrinologi.',
          'Monitor gula darah secara ketat dan hindari luka pada tubuh.',
        ];
      }

      final User? currentUser = FirebaseAuth.instance.currentUser;
      
      String primaryAssessment = 'Observasi Normal';
      if (percentage >= 50) primaryAssessment = 'Indikasi Pra-Diabetes';
      if (percentage >= 80) primaryAssessment = 'Type 2 Diabetes Suspected';

      Map<String, dynamic> diagnosisData = {
        'id_user': currentUser?.uid ?? 'guest',
        'createdAt': FieldValue.serverTimestamp(),
        'status_diagnosis': riskLevel,
        'deskripsi_singkat': 'Skor keyakinan analisis sistem pakar: ${percentage.toStringAsFixed(2)}%',
        'primary_assessment': primaryAssessment,
        'severity': '${percentage.toStringAsFixed(1)}%',
        'confidence_score': finalCf > 0.8 ? 'Tinggi' : (finalCf > 0.5 ? 'Sedang' : 'Rendah'),
        'recommendations': recommendationsList,
        'usia': usia,
        'berat_badan': berat,
        'tinggi_badan': tinggiCm,
        'imt': double.parse(imt.toStringAsFixed(1)),
        'jenis_kelamin': _jenisKelamin,
        'riwayat_keluarga': _riwayatKeluarga,
        'gejala': selectedSymptoms,
      };

      if (currentUser != null) {
        // Save to Firestore
        await FirebaseFirestore.instance.collection('Diagnosis').add(diagnosisData);
      }

      setState(() => _isLoading = false);

      if (!mounted) return;
      // Berikan data statis waktu untuk UI Result
      diagnosisData['createdAt'] = Timestamp.now(); 

      Navigator.pop(context, diagnosisData);

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Medical Information',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: AppColors.primaryNavy),
                SizedBox(height: 20),
                Text(
                  'Sistem sedang memproses perhitungan Certainty Factor...',
                  style: TextStyle(
                    fontFamily: 'Poppins', 
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              _buildStepperHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Icon(Icons.info_outline, color: AppColors.primaryNavy, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Prasyarat: Mohon lengkapi data medis Anda untuk mendapatkan hasil analisis AI yang akurat sebelum memulai sesi konsultasi.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _stepTitles[_currentStep],
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Please provide your current medical details to help us generate an accurate assessment.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStepContent(),
                    ],
                  ),
                ),
              ),
              _buildBottomButtons(),
            ],
          ),
    );
  }

  Widget _buildStepperHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.bgWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_totalSteps, (index) {
          bool isActive = index == _currentStep;
          bool isCompleted = index < _currentStep;
          
          return Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive || isCompleted ? AppColors.primaryNavy : AppColors.bgGrey,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isActive ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              if (index < _totalSteps - 1)
                Container(
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: 2,
                  color: isCompleted ? AppColors.primaryNavy : AppColors.bgGrey,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPhase1();
      case 1:
        return _buildPhase2();
      case 2:
        return _buildPhase3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhase1() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.show_chart, color: AppColors.primaryNavy),
              SizedBox(width: 8),
              Text(
                'Step 1: Physical Metrics',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField('Usia (Tahun)', 'Contoh: 45', _usiaController, TextInputType.number),
          const SizedBox(height: 16),
          _buildTextField('Berat Badan (kg)', 'Contoh: 70', _beratController, TextInputType.number),
          const SizedBox(height: 16),
          _buildTextField('Tinggi Badan (cm)', 'Contoh: 165', _tinggiController, TextInputType.number),
          const SizedBox(height: 16),
          _buildLabel('Jenis Kelamin Biologis'),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _jenisKelamin,
            hint: 'Pilih...',
            items: ['Pria', 'Wanita'],
            onChanged: (val) => setState(() => _jenisKelamin = val),
          ),
          const SizedBox(height: 16),
          _buildLabel('Riwayat Diabetes Keluarga'),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _riwayatKeluarga,
            hint: 'Pilih riwayat...',
            items: ['Ya', 'Tidak'],
            onChanged: (val) => setState(() => _riwayatKeluarga = val),
          ),
        ],
      ),
    );
  }

  Widget _buildPhase2() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.checklist_rtl, color: AppColors.primaryNavy),
              SizedBox(width: 8),
              Text(
                'Step 2: Symptoms Checklist',
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
          const Text(
            'Pilih gejala yang sering Anda alami akhir-akhir ini:',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ..._symptoms.map((symptom) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderLight,
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: AppColors.border,
                  ),
                  child: CheckboxListTile(
                    value: symptom['selected'],
                    onChanged: (bool? value) {
                      setState(() {
                        symptom['selected'] = value ?? false;
                        if (symptom['selected']) {
                          _noSymptoms = false;
                        }
                      });
                    },
                    title: Text(
                      symptom['name'],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    activeColor: AppColors.primaryNavy,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            );
          }).toList(),
          
          // Opsi tidak ada gejala
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _noSymptoms ? AppColors.accentOrange : AppColors.borderLight,
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: AppColors.border,
              ),
              child: CheckboxListTile(
                value: _noSymptoms,
                onChanged: (bool? value) {
                  setState(() {
                    _noSymptoms = value ?? false;
                    if (_noSymptoms) {
                      for (var s in _symptoms) {
                        s['selected'] = false;
                      }
                    }
                  });
                },
                title: Text(
                  'Tidak ada keluhan / gejala',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: _noSymptoms ? AppColors.accentOrange : AppColors.textPrimary,
                    fontWeight: _noSymptoms ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                activeColor: AppColors.accentOrange,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhase3() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.precision_manufacturing_outlined, color: AppColors.primaryNavy),
              SizedBox(width: 8),
              Text(
                'Step 3: Review & Process',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expert System Analysis Ready:',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('• ', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    Expanded(
                      child: Text(
                        'Forward Chaining logic will evaluate rules (e.g., IF Age > 40 OR BMI >= 23 THEN Increased Risk).',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('• ', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    Expanded(
                      child: Text(
                        'Symptom weightings will be applied to determine preliminary diagnosis using Certainty Factor.',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Icon(Icons.autorenew, color: AppColors.textSecondary, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ready to calculate risk profile based on provided metrics.',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, TextInputType type, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryNavy, width: 1.5),
            ),
            filled: true,
            fillColor: AppColors.bgWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({required String? value, required String hint, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textLight)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textLight),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primaryNavy),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Kembali',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ] else ...[
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primaryNavy),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep == 0) {
                  if (_usiaController.text.isEmpty || 
                      _beratController.text.isEmpty || 
                      _tinggiController.text.isEmpty || 
                      _jenisKelamin == null || 
                      _riwayatKeluarga == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harap lengkapi Usia, Berat, Tinggi, Jenis Kelamin, dan Riwayat terlebih dahulu.'),
                        backgroundColor: AppColors.primaryRed,
                      ),
                    );
                    return;
                  }
                }

                if (_currentStep < _totalSteps - 1) {
                  setState(() => _currentStep++);
                } else {
                  _processAnalysis();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentStep == _totalSteps - 1)
                    const Icon(Icons.psychology_outlined, color: Colors.white, size: 20),
                  if (_currentStep == _totalSteps - 1)
                    const SizedBox(width: 8),
                  Text(
                    _currentStep == _totalSteps - 1 ? 'Proses Analisis' : 'Selanjutnya',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
