import sys
from nlp_module import extract_symptoms, get_cf_values_from_symptoms
from inference_engine import combine_cf, get_risk_level, KNOWLEDGE_BASE

DISPLAY_NAMES = {
    "G01": "Sering buang air kecil (Poliuria)",
    "G02": "Sering merasa haus (Polidipsia)",
    "G03": "Sering merasa lapar (Polifagia)",
    "G04": "Penurunan berat badan tanpa sebab",
    "G05": "Kaki terasa kesemutan (Neuropati)",
    "G06": "Luka sulit sembuh",
    "G07": "Penglihatan kabur / buram"
}

def hitung_imt(berat, tinggi_cm):
    """
    Menghitung IMT dan mengembalikan nilai IMT beserta status risiko (>=23).
    """
    tinggi_m = tinggi_cm / 100.0
    if tinggi_m == 0:
        return 0, False
    imt = berat / (tinggi_m ** 2)
    return imt, imt >= 23

def proses_fase1(usia, berat, tinggi, riwayat_keluarga):
    """
    Memproses data metrik fisik dan menghasilkan list CF factors yang terpicu.
    """
    cf_values = []
    imt, is_high_imt = hitung_imt(berat, tinggi)
    
    if usia > 40:
        cf_values.append(0.4) # F01
    if is_high_imt:
        cf_values.append(0.4) # F02
    if riwayat_keluarga.lower() in ["iya", "ya", "y"]:
        cf_values.append(0.8) # F03
        
    return cf_values

def proses_fase2(teks_gejala=None):
    """
    Mengekstrak gejala dari teks, meminta konfirmasi user, 
    dan mengizinkan input ulang jika salah.
    """
    if teks_gejala is None:
        teks_gejala = input("Ceritakan gejala atau keluhan yang Anda rasakan akhir-akhir ini:\n> ")
        
    while True:
        codes = extract_symptoms(teks_gejala)
        
        details = [DISPLAY_NAMES.get(code, code) for code in codes]
        
        print("\nGejala yang kami deteksi dari cerita Anda:")
        if details:
            for d in details:
                print(f" - {d}")
        else:
            print(" - (Tidak ada gejala diabetes spesifik yang terdeteksi)")
            
        konfirmasi = input("\nApakah daftar gejala di atas sudah benar? (y/t): ")
        if konfirmasi.lower() == 'y':
            return codes, details
        else:
            teks_gejala = input("\nSilakan ceritakan kembali keluhan Anda dengan lebih jelas:\n> ")

def proses_fase3(cf_fisik, cf_gejala, symptom_details):
    """
    Menggabungkan CF fisik dan gejala, mengkalkulasi CF Combine,
    lalu mencetak ringkasan hasil secara rapi.
    """
    all_cf = cf_fisik + cf_gejala
    final_cf = combine_cf(all_cf)
    percentage = final_cf * 100
    
    risk_info = get_risk_level(percentage)
    risk_level = risk_info['risk_level']
    recommendation = risk_info['recommendation']
    
    print("\n" + "="*40)
    print("📋 RINGKASAN DIAGNOSA ANDA")
    print("="*40)
    print("\n✅ Gejala terdeteksi:")
    if symptom_details:
        for detail in symptom_details:
            print(f"- {detail}")
    else:
        print("- Tidak ada")
        
    print(f"\n📊 HASIL DIAGNOSA")
    print(f"Persentase risiko: {percentage:.1f}%")
    print(f"Tingkat risiko: {risk_level.upper()}")
    
    print(f"\n💡 REKOMENDASI")
    print(f"{recommendation}")
    print("="*40 + "\n")

def main():
    print("="*40)
    print("SISTEM PAKAR DIAGNOSIS DIABETES MELITUS TIPE 2")
    print("="*40)
    
    # === FASE 1 ===
    print("\n--- FASE 1: Input Data Fisik ---")
    try:
        usia = int(input("Masukkan usia Anda (Tahun): "))
        berat = float(input("Masukkan berat badan Anda (kg): "))
        tinggi = float(input("Masukkan tinggi badan Anda (cm): "))
    except ValueError:
        print("Input tidak valid. Menggunakan nilai fallback (Usia 30, BB 60, TB 160).")
        usia, berat, tinggi = 30, 60.0, 160.0
        
    riwayat = input("Apakah ada riwayat keluarga diabetes? (iya/tidak): ")
    
    cf_fisik = proses_fase1(usia, berat, tinggi, riwayat)
    
    # === FASE 2 ===
    print("\n--- FASE 2: Input Gejala (Teks Bebas) ---")
    codes, details = proses_fase2()
    cf_gejala = get_cf_values_from_symptoms(codes)
    
    # === FASE 3 ===
    print("\n--- FASE 3: Review & Proses ---")
    print("Sistem pakar sedang memproses data Anda menggunakan Forward Chaining dan Certainty Factor...")
    import time
    time.sleep(1) # Simulasi loading singkat
    proses_fase3(cf_fisik, cf_gejala, details)

if __name__ == "__main__":
    main()
