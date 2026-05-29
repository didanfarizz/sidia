import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class DiagnosisResultScreen extends StatelessWidget {
  final Map<String, dynamic> diagnosisData;

  const DiagnosisResultScreen({super.key, required this.diagnosisData});

  @override
  Widget build(BuildContext context) {
    final status = diagnosisData['status_diagnosis'] ?? 'Selesai';
    final desc = diagnosisData['deskripsi_singkat'] ?? 'Tidak ada deskripsi.';
    final recommendations = List<String>.from(diagnosisData['recommendations'] ?? []);

    String dateStr = '';
    if (diagnosisData['createdAt'] != null) {
      try {
        final dt = (diagnosisData['createdAt'] as Timestamp).toDate();
        dateStr = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
      } catch (_) {
        dateStr = diagnosisData['createdAt'].toString();
      }
    }

    final isWarning = status.toLowerCase().contains('perhatian') || status.toLowerCase().contains('diabetes');
    final color = isWarning ? AppColors.accentOrange : AppColors.accentGreen;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgWhite,
        elevation: 0,
        title: const Text('Hasil Diagnosis', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          status,
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: color),
                        ),
                      ),
                      if (dateStr.isNotEmpty)
                        Text(dateStr, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textLight)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(desc, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  if (recommendations.isNotEmpty) ...[
                    const Text('Rekomendasi', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    for (var rec in recommendations)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
                            Expanded(child: Text(rec, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textPrimary, height: 1.5))),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali', style: TextStyle(fontFamily: 'Poppins')),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy),
            ),
          ],
        ),
      ),
    );
  }
}
