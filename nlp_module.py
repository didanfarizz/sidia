import re
from inference_engine import KNOWLEDGE_BASE

# Data Korpus (dari Tabel 3.1)
# Diperkaya dengan regex capture groups opsional (?:...) 
# agar bisa menangani variasi bahasa/slang dengan lebih baik.
SYMPTOMS_CORPUS = {
    "G01": [
        r"sering buang air kecil", r"kencing terus", r"buang air kecil di malam hari", 
        r"beser", r"sering kencing", r"kencing melulu", r"pipis terus"
    ],
    "G02": [
        r"sering merasa haus", r"haus terus", r"cepat haus(?: padahal sudah minum)?", 
        r"gampang kehausan", r"haus mulu", r"bawaannya haus"
    ],
    "G03": [
        r"sering merasa lapar", r"bawaannya lapar terus", r"mudah lapar", 
        r"ingin makan terus", r"lapar melulu", r"habis makan masih lapar"
    ],
    "G04": [
        r"berat badan.*turun drastis", r"makin kurus", r"kurus mendadak(?: padahal makan banyak)?", 
        r"bb turun terus", r"badan makin kurus(?: tanpa sebab)?"
    ],
    "G05": [
        r"sering(?: merasa)? kesemutan", r"kaki(?: terasa)? kebas", r"tangan mati rasa", 
        r"kaki(?: terasa)? panas(?: atau terbakar)?", r"kesemutan terus", r"kebas(?: kebas)?"
    ],
    "G06": [
        r"luka susah kering", r"luka lama sembuh(?:nya)?", r"borok tidak sembuh(?:-sembuh)?", 
        r"luka sulit sembuh", r"luka tidak kering(?: kering)?"
    ],
    "G07": [
        r"mata buram", r"penglihatan kabur", r"pandangan kabur", 
        r"mata kurang awas", r"pandangan tidak jelas", r"nulis(?: jadi)? nggak jelas", r"lihat jadi ganda"
    ]
}

# Kompilasi pola Regex untuk pencarian yang lebih cepat
COMPILED_CORPUS = {}
for code, patterns in SYMPTOMS_CORPUS.items():
    # Gabungkan semua pola untuk satu gejala dengan OR (|)
    combined_pattern = '|'.join(patterns)
    COMPILED_CORPUS[code] = re.compile(combined_pattern, re.IGNORECASE)

def extract_symptoms(text):
    """
    1. Mengekstrak kode gejala dari teks alami pengguna.
    Menggunakan pencocokan Regex berbasis rule dari data korpus.
    """
    detected_symptoms = []
    text = text.lower() # Normalisasi teks
    
    for code, regex in COMPILED_CORPUS.items():
        if regex.search(text):
            detected_symptoms.append(code)
            
    return detected_symptoms

def get_cf_values_from_symptoms(symptom_codes):
    """
    2. Mengambil bobot CF dari KNOWLEDGE_BASE (dari Prompt 1A)
    berdasarkan kode gejala yang terdeteksi.
    """
    cf_values = []
    kb_symptoms = KNOWLEDGE_BASE.get("symptoms", {})
    
    for code in symptom_codes:
        if code in kb_symptoms:
            cf_values.append(kb_symptoms[code]["cf"])
            
    return cf_values

if __name__ == "__main__":
    # 3. Contoh pengujian
    test_text = "Saya sering haus terus dan kaki saya sering kesemutan, berat badan juga turun drastis"
    
    print("=== Uji Coba Modul NLP (Rule-based + Regex) ===")
    print(f"Teks Input: '{test_text}'\n")
    
    # Eksekusi Fungsi 1
    detected_codes = extract_symptoms(test_text)
    print(f"[1] Kode Gejala Terdeteksi: {detected_codes}")
    
    # Menampilkan rincian gejala untuk validasi
    kb_sym = KNOWLEDGE_BASE.get("symptoms", {})
    for code in detected_codes:
        sym_name = kb_sym.get(code, {}).get("name", "Unknown")
        cf_weight = kb_sym.get(code, {}).get("cf", 0.0)
        print(f"    -> {code}: {sym_name} (Bobot CF: {cf_weight})")
        
    # Eksekusi Fungsi 2
    cf_vals = get_cf_values_from_symptoms(detected_codes)
    print(f"\n[2] Nilai CF yang Diambil: {cf_vals}")
