# inference_engine.py

# 1. Knowledge Base
KNOWLEDGE_BASE = {
    "symptoms": {
        "G01": {"name": "poliuria", "cf": 0.9},
        "G02": {"name": "polidipsia", "cf": 0.9},
        "G03": {"name": "polifagia", "cf": 0.9},
        "G04": {"name": "penurunan berat badan", "cf": 0.7},
        "G05": {"name": "neuropati (kesemutan/kebas)", "cf": 0.7},
        "G06": {"name": "luka sulit sembuh", "cf": 0.7},
        "G07": {"name": "penglihatan kabur", "cf": 0.8},
    },
    "risk_factors": {
        "F01": {"name": "usia > 40 tahun", "cf": 0.4},
        "F02": {"name": "IMT >= 23 kg/m²", "cf": 0.4},
        "F03": {"name": "riwayat keluarga diabetes", "cf": 0.8},
    }
}

# 2. Fungsi combine_cf
def combine_cf(cf_values):
    """
    Menggabungkan nilai CF menggunakan rumus berulang:
    CF_combine = CF1 + CF2 * (1 - CF1)
    """
    if not cf_values:
        return 0.0
    
    cf_combine = cf_values[0]
    for cf in cf_values[1:]:
        cf_combine = cf_combine + cf * (1 - cf_combine)
        
    return cf_combine

# 3. Fungsi get_risk_level
def get_risk_level(percentage):
    """
    Menentukan tingkat risiko dan rekomendasi berdasarkan persentase CF akhir (0-100%).
    """
    if 0 <= percentage < 50:
        return {
            "risk_level": "Risiko Rendah",
            "recommendation": "Tetap jaga pola hidup sehat dan lakukan diagnosis berkala."
        }
    elif 50 <= percentage < 70:
        return {
            "risk_level": "Risiko Sedang",
            "recommendation": "Pantau kadar gula darah mandiri dan perbaiki pola makan."
        }
    elif 70 <= percentage < 80:
        return {
            "risk_level": "Risiko Cukup Tinggi",
            "recommendation": "Konsultasi dengan tenaga medis atau dokter terdekat."
        }
    else: # 80 - 100%
        return {
            "risk_level": "Risiko Tinggi",
            "recommendation": "Segera lakukan pemeriksaan medis formal di fasilitas kesehatan."
        }

if __name__ == "__main__":
    # Kasus Uji
    cf_values = [0.4, 0.8, 0.9, 0.9, 0.7]
    
    # Hitung CF Combine
    final_cf = combine_cf(cf_values)
    
    # Konversi ke persentase
    percentage = final_cf * 100
    
    # Dapatkan tingkat risiko dan rekomendasi
    result = get_risk_level(percentage)
    
    print("=== Hasil Uji Coba Inference Engine ===")
    print(f"Nilai CF input: {cf_values}")
    print(f"Hasil CF Combine: {final_cf:.4f}")
    print(f"Persentase Akhir: {percentage:.2f}%")
    print(f"Tingkat Risiko: {result['risk_level']}")
    print(f"Rekomendasi: {result['recommendation']}")
