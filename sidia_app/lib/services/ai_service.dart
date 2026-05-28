import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  AiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
      throw Exception('API Key Gemini tidak ditemukan di .env');
    }

    // Konfigurasi model Gemini terbaru (Gemini 3.5 Flash) sesuai ketersediaan di AI Studio 2026
    _model = GenerativeModel(
      model: 'gemini-3.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system('''
Anda adalah SIDIA (Sistem Diagnosis Diabetes AI Assistant), asisten medis virtual yang pakar dalam bidang penyakit Diabetes Melitus Tipe 2. 
Tugas utama Anda adalah memberikan edukasi, saran gaya hidup, serta informasi medis umum mengenai Diabetes Tipe 2 berdasarkan hasil diagnosis pengguna.

ATURAN PENTING:
1. Anda TIDAK BOLEH memberikan resep obat, diagnosis medis pasti, atau menggantikan peran dokter spesialis. Selalu sarankan pengguna untuk berkonsultasi dengan fasilitas kesehatan terdekat.
2. Jawab pertanyaan HANYA yang berkaitan dengan kesehatan, diabetes, pola makan, olahraga, dan gaya hidup sehat.
3. Jika pengguna bertanya di luar topik kesehatan, jawab dengan sopan bahwa Anda hanya diprogram untuk melayani konsultasi terkait kesehatan.
4. Gunakan bahasa Indonesia yang ramah, profesional, empati, dan mudah dipahami.
5. Anda juga akan menerima konteks "Hasil Diagnosis" awal pengguna. Gunakan konteks tersebut untuk membuat jawaban yang lebih personal dan relevan.
'''),
    );

    _chatSession = _model.startChat();
  }

  /// Memasukkan konteks awal (hasil diagnosis) ke dalam riwayat obrolan AI
  /// tanpa menampilkan pesannya ke UI pengguna
  void addContextFromDiagnosis(Map<String, dynamic> diagnosisData) {
    final status = diagnosisData['status_diagnosis'] ?? 'Unknown';
    final severity = diagnosisData['severity'] ?? 'N/A';
    final recommendations = List<String>.from(diagnosisData['recommendations'] ?? []);
    
    final prompt = '''
[SISTEM]: Pengguna baru saja melakukan tes diagnosis dengan hasil berikut:
- Status: $status
- Tingkat Keparahan/Risiko: $severity
- Rekomendasi Sistem: ${recommendations.join(", ")}

Gunakan informasi ini sebagai konteks jika pengguna bertanya tentang hasil diagnosisnya. Jangan merespon pesan ini, cukup pahami saja konteksnya.
''';
    
    try {
      // Kita buat sesi chat baru dengan menyertakan riwayat lama + prompt diagnosis baru
      final updatedHistory = _chatSession.history.toList();
      updatedHistory.addAll([
        Content.text(prompt),
        Content.model([TextPart('Baik, saya telah memahami hasil diagnosis pengguna dan akan menggunakannya sebagai konteks.')])
      ]);

      _chatSession = _model.startChat(history: updatedHistory);
    } catch (e) {
      print("Gagal menambahkan konteks ke AI: $e");
    }
  }

  /// Mengirim pesan pengguna ke Gemini dan menerima respons
  Future<String> sendMessage(String text) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      return response.text ?? 'Maaf, saya tidak dapat merespon saat ini.';
    } catch (e) {
      return 'Maaf, terjadi kesalahan saat menghubungi server SIDIA: $e';
    }
  }
}
