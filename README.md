<div align="center">

# 📖 Senin Masalın

### Çocuğuna Özel, Yapay Zeka Destekli Kişiselleştirilmiş Masallar

*An AI-powered mobile application that generates personalized bedtime stories for children — bringing imagination to life, one tale at a time.*

---

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Node.js](https://img.shields.io/badge/Node.js-Express-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Hugging Face](https://img.shields.io/badge/🤗_Hugging_Face-Fine--Tuned-FFD21E?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-In_Development-orange?style=for-the-badge)

</div>

---

## 📌 İçindekiler

- [📖 Proje Hakkında](#-proje-hakkında)
- [✨ Temel Özellikler](#-temel-özellikler)
- [🛠️ Teknoloji Yığını](#%EF%B8%8F-teknoloji-yığını)
- [🚦 Proje Durumu](#-proje-durumu)
- [🤖 Model Performansı](#-model-performansı)
- [📂 Proje Yapısı](#-proje-yapısı)
- [🚀 Kurulum ve Çalıştırma](#-kurulum-ve-çalıştırma)
- [☁️ Model Erişimi](#%EF%B8%8F-model-erişimi)
- [🗺️ Gelecek Yol Haritası](#%EF%B8%8F-gelecek-yol-haritası)
- [🤝 Katkıda Bulunma](#-katkıda-bulunma)
- [📄 Lisans](#-lisans)

---

## 📖 Proje Hakkında

**Senin Masalın**, çocukların hayal güçlerini beslemeye ve uyku öncesi kaliteli bir zaman geçirmelerine yardımcı olmak için tasarlanmış, **yapay zeka destekli bir mobil hikaye uygulamasıdır**. Ebeveynler, çocuklarının adını, sevdiği karakterleri ve temayı seçerek sadece onlara özel, benzersiz masallar oluşturabilir.

Uygulama; modern bir Flutter mobil arayüzünü, güvenli bir Node.js/Express backend'ini ve Türkçe masal üretimi için özel olarak fine-tune edilmiş bir **LLM (Large Language Model)** modelini bir araya getirmektedir.

> 💡 **Vizyon:** Her çocuk, kendi adıyla başrole geçtiği bir masalı hak eder.

---

## ✨ Temel Özellikler

| Özellik | Açıklama |
|---|---|
| 🪄 **Kişiselleştirilmiş Masal Üretimi** | Çocuğun adı, karakterleri ve temaya göre özgün masal oluşturma |
| 📚 **Hazır Masal Kütüphanesi** | 50+ klasik dünya masalı (Sindirella, Kırmızı Başlıklı Kız, vb.) |
| 🎧 **Sesli Dinleme (TTS)** | Google Cloud Text-to-Speech ile masalı sesli dinleme |
| 🔐 **Kimlik Doğrulama** | Firebase Auth ile Google Sign-In ve e-posta girişi |
| 🖼️ **Dinamik Görseller** | fal.ai entegrasyonu ile masala özel illüstrasyon üretimi |
| 🧩 **Puzzle Modu** | Masal ilustrasyonlarıyla interaktif bulmaca aktivitesi |
| ☁️ **Bulut Senkronizasyonu** | Cloud Firestore ile tüm masallar ve ayarlar senkronize |
| 🌙 **Uyku Dostu Arayüz** | Göz yormayan, çocuk dostu tasarım ve animasyonlar |

---

## 🛠️ Teknoloji Yığını

### 📱 Mobil Uygulama (Frontend)

| Katman | Teknoloji |
|---|---|
| **Dil & Framework** | Dart / Flutter 3.x |
| **State Management** | Riverpod + Riverpod Generator |
| **Navigasyon** | Go Router |
| **Kimlik Doğrulama** | Firebase Auth + Google Sign-In |
| **Veritabanı** | Cloud Firestore |
| **Depolama** | Firebase Storage |
| **Ses (TTS)** | just_audio |
| **UI & Animasyon** | flutter_animate, Lottie, Shimmer |
| **Font** | Google Fonts |

### ⚙️ Backend (API Sunucusu)

| Katman | Teknoloji |
|---|---|
| **Runtime** | Node.js (ESM) |
| **Framework** | Express.js |
| **Güvenlik** | Helmet, express-rate-limit, CORS |
| **AI – Masal Üretimi** | Google Generative AI (Gemini API) |
| **AI – Görsel Üretimi** | fal.ai Serverless Client |
| **TTS** | Google Cloud Text-to-Speech |
| **Veritabanı** | Firebase Admin SDK |
| **Logging** | Morgan |

### 🤖 Yapay Zeka Modeli (LLM)

| Katman | Teknoloji |
|---|---|
| **Temel Model** | LLaMA / Mistral bazlı (8B parametre) |
| **Fine-Tuning Yöntemi** | QLoRA (Quantized Low-Rank Adaptation) |
| **Eğitim Ortamı** | Google Colab (GPU) |
| **Framework** | Python, Hugging Face Transformers, PEFT |
| **Quantization** | GGUF formatı (llama.cpp uyumlu) |
| **Değerlendirme** | BLEU-4, ROUGE-L metrikleri |
| **Veri İşleme** | Custom Python pipeline |

---

## 🚦 Proje Durumu

```
📱 Mobil Uygulama (Flutter)   ████████████████████  ✅ Tamamlandı
⚙️  Backend API (Node.js)      ████████████████████  ✅ Tamamlandı
🤖 AI Model Eğitimi           ████████████████████  ✅ Tamamlandı (V3)
🔗 Model–Uygulama Entegrasyonu ░░░░░░░░░░░░░░░░░░░░  ⏳ Planlandı
🚀 Prodüksiyon Deployment      ░░░░░░░░░░░░░░░░░░░░  ⏳ Planlandı
```

> ⚠️ **Mevcut Durum Notu:**
> Mobil uygulama arayüzleri, backend API servisleri ve yapay zeka modelinin eğitimi **tamamlanmış** olup her bileşen bağımsız olarak çalışır durumdadır. Ancak özel fine-tune modelin mobil uygulama ve backend ile **entegrasyonu henüz gerçekleştirilmemiştir** — bu aşama aktif geliştirme yol haritasındadır.

---

## 🤖 Model Performansı

Özel eğitimli Türkçe masal modeli **3 versiyon** boyunca iteratif olarak iyileştirilmiştir.

### 📉 Eğitim & Validasyon Kaybı

<details>
<summary><strong>V1 — Eğitim Loss Grafiği (3B, 3 Epoch)</strong></summary>

![V1 Training Loss](llm-model/rapor_metrikleri/v1_egitim_loss_grafigi.png)

</details>

<details>
<summary><strong>V3 — Eğitim Loss Grafiği (8B, 3 Epoch, Optimized)</strong></summary>

![V3 Training Loss](llm-model/rapor_metrikleri/v3_egitim_loss_grafigi.png)

</details>

---

### 📊 Model Karşılaştırması: V1 vs V2

![V1 vs V2 BLEU-ROUGE](llm-model/rapor_metrikleri/v1_v2_bleu_rouge.png)

---

### 📊 Model Karşılaştırması: V1 vs V2 vs V3

![V1 vs V2 vs V3 BLEU-ROUGE](llm-model/rapor_metrikleri/v1_v2_v3_bleu_rouge.png)

---

### 📈 Çok Boyutlu Performans Karşılaştırması

![V1 vs V2 vs V3 Performans](llm-model/rapor_metrikleri/v1_v2_v3_performans.png)

---

### 🏆 Sonuç Metrikleri Özeti

| Model | Parametre | Epoch | BLEU-4 | ROUGE-L | Kelime Uyumu | Mutlu Son |
|---|---|---|---|---|---|---|
| **V1** | 3B | 3 | 0.0551 | 0.2201 | ~0.80 | ~0.47 |
| **V2** | 8B | 5 | 0.0604 | 0.1991 | ~0.80 | ~0.50 |
| **V3** ⭐ | 8B | 3 (Opt.) | **0.0679** | **0.2348** | ~0.73 | **~0.73** |

> 🏆 **V3**, BLEU-4 ve ROUGE-L skorlarında en yüksek sonuçları elde etmiş ve "Mutlu Son" oranını %73'e yükselterek en dengeli model olduğunu kanıtlamıştır.

---

## 📂 Proje Yapısı

```
senin-masalin/
│
├── 📱 frontend/                    # Flutter Mobil Uygulaması
│   ├── lib/
│   │   ├── core/                   # Tema, sabitler, yardımcılar
│   │   ├── features/               # Özellik bazlı modüller
│   │   │   ├── auth/               # Kimlik doğrulama
│   │   │   ├── tales/              # Masal listeleme & okuma
│   │   │   ├── ai_tale/            # AI masal üretimi
│   │   │   └── puzzle/             # Bulmaca aktivitesi
│   │   └── main.dart
│   ├── assets/                     # Görseller, animasyonlar, sesler
│   └── pubspec.yaml
│
├── ⚙️  backend/                     # Node.js / Express API
│   ├── src/
│   │   ├── routes/                 # API endpoint tanımları
│   │   ├── controllers/            # İstek işleyiciler
│   │   ├── services/               # Gemini AI, TTS, fal.ai servisleri
│   │   ├── middlewares/            # Auth, rate limit
│   │   └── server.js               # Giriş noktası
│   └── package.json
│
├── 🤖 llm-model/                   # Özel Fine-Tune LLM
│   ├── 1_veri_on_isleme.py         # Veri ön işleme pipeline
│   ├── 2_colab_finetune.ipynb      # Google Colab eğitim defteri
│   ├── evaluate_model.py           # BLEU / ROUGE değerlendirme
│   ├── masal_uret.py               # Masal üretim scripti
│   ├── rapor_metrikleri/           # Eğitim grafikleri ve metrikler
│   └── model_gguf/                 # GGUF formatındaki model dosyaları
│
├── 🗄️  database/                    # Firebase şema tanımları & kuralları
├── 📊 dataset/                     # Masal eğitim veri seti
└── README.md
```

---

## 🚀 Kurulum ve Çalıştırma

### Ön Gereksinimler

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.3.0
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.0.0
- [Node.js](https://nodejs.org/) ≥ 18.x
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Python](https://www.python.org/) ≥ 3.9 (model scripti için)
- Bir Firebase projesi ve etkin servisler (Auth, Firestore, Storage)

---

### 📱 Mobil Uygulamayı Çalıştırma

```bash
# 1. Repoyu klonlayın
git clone https://github.com/kullanici-adi/senin-masalin.git
cd senin-masalin/frontend

# 2. Bağımlılıkları yükleyin
flutter pub get

# 3. Firebase yapılandırmasını ekleyin
# google-services.json (Android) → android/app/
# GoogleService-Info.plist (iOS) → ios/Runner/

# 4. Ortam değişkenlerini ayarlayın
# dev.json dosyasına backend API URL'nizi ekleyin

# 5. Uygulamayı başlatın
flutter run
```

---

### ⚙️ Backend API'yi Çalıştırma

```bash
cd senin-masalin/backend

# 1. Bağımlılıkları yükleyin
npm install

# 2. Ortam değişkenlerini ayarlayın
cp .env.example .env
# .env dosyasını API anahtarlarınızla doldurun:
# GEMINI_API_KEY, FAL_AI_KEY, GOOGLE_TTS_KEY, Firebase credentials

# 3. Geliştirme sunucusunu başlatın
npm run dev

# Sunucu varsayılan olarak http://localhost:3000 adresinde çalışır
```

---

### 🤖 Model Scriptlerini Çalıştırma

```bash
cd senin-masalin/llm-model

# Bağımlılıkları yükleyin
pip install transformers peft torch accelerate datasets

# Veri ön işleme
python 1_veri_on_isleme.py

# Model değerlendirme (mevcut modelle)
python evaluate_model.py

# Masal üretme (test)
python masal_uret.py
```

> 💡 **Not:** Model eğitimi için `2_colab_finetune.ipynb` dosyasını Google Colab'da GPU (A100/T4) ile çalıştırmanız önerilir.

---

## ☁️ Model Erişimi

Fine-tune edilmiş **Senin Masalın V3 Modeli** (GGUF formatı), model ağırlıkları büyüklüğü nedeniyle Google Drive üzerinde barındırılmaktadır.

### ⬇️ Model İndirme

| Model | Format | Boyut | Bağlantı |
|---|---|---|---|
| **Senin Masalın V3** ⭐ (Önerilen) | GGUF (Q4_K_M) | ~5 GB | **[📥 Google Drive'dan İndir][GOOGLE_DRIVE_MODEL_LINK]** |
| Senin Masalın V1 | GGUF (Q4_K_M) | ~2 GB | **[📥 Google Drive'dan İndir][GOOGLE_DRIVE_MODEL_V1_LINK]** |
| Senin Masalın V2 | GGUF (Q4_K_M) | ~5 GB | **[📥 Google Drive'dan İndir][GOOGLE_DRIVE_MODEL_V2_LINK]** |

> 🔗 **`https://drive.google.com/drive/u/0/folders/1EbTjM-WAe5SpIuKGgVxAKVFWHhj15UaI`** — *Buraya V3 model dosyasının Google Drive bağlantısını ekleyin.*
> 🔗 **`https://drive.google.com/drive/u/0/folders/1AikLMNG8FIFZDwROLil6KFpzxQV5-JVb`** — *Buraya V1 model dosyasının Google Drive bağlantısını ekleyin.*

### Modeli Kullanma

```bash
# Modeli indirdikten sonra model_gguf/ dizinine yerleştirin
mv senin_masalin_v3.gguf senin-masalin/llm-model/model_gguf/

# Masal üretme scriptini çalıştırın
python masal_uret.py --model model_gguf/senin_masalin_v3.gguf
```

---

## 🗺️ Gelecek Yol Haritası

### 🔜 Yakın Vadeli (Öncelikli)

- [ ] 🔗 **Model–Uygulama Entegrasyonu** — Fine-tune V3 modelinin backend API'ye bağlanması
- [ ] 🌐 **Model API Servisi** — llama.cpp veya Hugging Face Inference API üzerinden servis kurulumu
- [ ] 🧪 **Uçtan Uca Test** — Entegre sistem testleri ve kalite güvence süreci
- [ ] 🚀 **Prodüksiyon Deployment** — Backend'in cloud platformuna (Railway, GCP, vb.) taşınması

### 🔮 Orta Vadeli

- [ ] 👶 **Yaş Bazlı Uyarlama** — Çocuğun yaşına göre dil karmaşıklığı ayarı
- [ ] 🌍 **Çok Dil Desteği** — Türkçe'ye ek olarak İngilizce ve Almanca masal üretimi
- [ ] 💾 **Offline Mod** — İnternetsiz kullanım için model on-device çalıştırma
- [ ] 📊 **Ebeveyn Paneli** — Çocuğun okuma istatistiklerini ve favori masallarını izleme
- [ ] 🎨 **Daha Fazla Kişiselleştirme** — Masal tonu, uzunluk ve ders seçimi

### 🏁 Uzun Vadeli

- [ ] 🤝 **Model V4** — Daha büyük ve çeşitli veri seti ile yeniden eğitim
- [ ] 🏪 **App Store & Google Play** — Resmi mağaza yayını
- [ ] 🎮 **Gamification** — Masal okuma alışkanlığı için rozet ve ödül sistemi

---

## 🤝 Katkıda Bulunma

Katkılarınız projeyi daha iyi hale getirir! Lütfen aşağıdaki adımları izleyin:

1. **Fork** edin ve yerel makinenize klonlayın
2. Yeni bir **feature branch** oluşturun:
   ```bash
   git checkout -b feature/yeni-ozellik
   ```
3. Değişikliklerinizi **commit** edin:
   ```bash
   git commit -m "feat: yeni özellik eklendi"
   ```
4. Branch'inizi **push** edin:
   ```bash
   git push origin feature/yeni-ozellik
   ```
5. Bir **Pull Request** açın ve değişikliklerinizi açıklayın

### Commit Mesajı Kuralları

| Prefix | Kullanım |
|---|---|
| `feat:` | Yeni özellik |
| `fix:` | Hata düzeltmesi |
| `docs:` | Dokümantasyon değişikliği |
| `style:` | Kod formatı (mantık değişikliği yok) |
| `refactor:` | Kod yeniden yapılandırma |
| `test:` | Test ekleme veya güncelleme |
| `chore:` | Build / bağımlılık güncellemesi |

---

## 📄 Lisans

Bu proje **MIT Lisansı** kapsamında lisanslanmıştır. Daha fazla bilgi için [LICENSE](LICENSE) dosyasına bakın.

```
MIT License — Copyright (c) 2025 Senin Masalın Team
```

---

<div align="center">

**Senin Masalın** ile her çocuk kendi hikayesinin kahramanı olur. 🌟

*Made with ❤️ for little dreamers everywhere*

</div>
