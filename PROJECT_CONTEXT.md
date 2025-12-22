code
Markdown
# 🚀 PROJE ANAYASASI VE TEKNİK DOKÜMANTASYON

## 1. PROJE KİMLİĞİ
**Proje Adı:** Sağlıklı Yaşam ve AI Asistanı (MVP)
**Amaç:** Kullanıcıların kalori, su ve aktivitelerini takip etmesi; yemek fotoğraflarını ve kan tahlillerini Gemini AI ile analiz etmesi.
**Strateji:** Backend First (Önce Node.js API, Sonra Flutter UI).
**Kritik Kural:** Resim/Dosya sunucuda depolanmaz (No Cloudinary). RAM üzerinden anlık işlenir.

---

## 2. TEKNOLOJİ YIĞINI (TECH STACK)
*   **Backend:** Node.js, Express.js
*   **Database:** MongoDB (Mongoose ODM)
*   **AI:** Google Gemini 2.5 Flash (Google Generative AI SDK)
*   **Mobile:** Flutter (Dart)
*   **State Management:** GetX (Modular Pattern)
*   **Paketler (Backend):** `multer` (MemoryStorage), `dotenv`, `cors`, `jsonwebtoken`, `bcryptjs`.
*   **Paketler (Mobile):** `dio`, `get`, `get_storage`, `fl_chart`, `image_picker`, `file_picker`, `intl`, `mobile_scanner`, `permission_handler`.

---

## 3. KODLAMA KURALLARI (KESİN UYULACAK)
1.  **Dil:** Değişkenler İngilizce (`calculateBMR`), Yorumlar **TÜRKÇE**.
2.  **Yorum Satırları (ZORUNLU):** Her fonksiyonun başında amacı, parametreleri ve mantığı anlatan Türkçe blok yorum olacak.
3.  **Mimari (Backend - MCS):** Logic işlemleri `Service` katmanında olacak.
4.  **Mimari (Mobile - GetX Modular):** UI içinde logic olmayacak. Her özellik kendi modülünde olacak.

---

## 4. PROJE MİMARİSİ (KLASÖR AĞACI)

### 4.1. BACKEND (Node.js)
```text
src/
├── config/         (db.js)
├── controllers/    (authController, foodController, activityController, healthController)
├── models/         (User, DailyLog, HealthReport)
├── routes/         (authRoutes, foodRoutes, activityRoutes, healthRoutes)
├── services/       (authService, geminiService, logService, calculationService)
├── middleware/     (authMiddleware, uploadMiddleware)
└── utils/          (responseHelper)
4.2. MOBİL (Flutter - GetX Detailed)
code
Text
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart      (API URL'leri)
│   │   ├── app_colors.dart         (Renk paleti)
│   │   └── app_strings.dart        (Sabit metinler)
│   ├── theme/
│   │   └── app_theme.dart          (ThemeData ayarları)
│   ├── utils/
│   │   ├── date_formatter.dart     (Tarih formatlama)
│   │   └── validators.dart         (Form kontrolleri)
│   └── widgets/                    (Ortak UI Parçaları)
│       ├── custom_button.dart
│       ├── custom_textfield.dart
│       ├── calorie_ring_chart.dart (Ana sayfadaki halka grafik)
│       └── loading_overlay.dart    (AI beklerken çıkan animasyon)
│
├── data/
│   ├── models/                     (Backend JSON karşılıkları)
│   │   ├── user_model.dart
│   │   ├── daily_log_model.dart
│   │   └── health_report_model.dart
│   ├── services/
│   │   ├── dio_service.dart        (Interceptorlı HTTP İstemcisi)
│   │   └── storage_service.dart    (GetStorage Token Yönetimi)
│   └── providers/
│       └── api_provider.dart       (Uç noktalara istek atan metodlar)
│
├── routes/
│   ├── app_pages.dart              (GetPage listesi)
│   └── app_routes.dart             (Route isimleri: /home, /login)
│
└── modules/                        (MODÜLLER)
    ├── root/                       (Bottom Navigation Bar Tutucu)
    │   ├── bindings/root_binding.dart
    │   ├── controllers/root_controller.dart
    │   └── views/root_view.dart
    │
    ├── auth/                       (Giriş & Kayıt & Kurulum)
    │   ├── bindings/auth_binding.dart
    │   ├── controllers/auth_controller.dart
    │   └── views/
    │       ├── login_view.dart
    │       ├── register_view.dart
    │       └── onboarding_view.dart    (Yaş, Kilo, Hedef seçilen 3 adımlı sihirbaz)
    │
    ├── home/                       (Ana Dashboard)
    │   ├── bindings/home_binding.dart
    │   ├── controllers/home_controller.dart
    │   └── views/home_view.dart        (Kalori Halkası ve Su Barı burada)
    │
    ├── diary/                      (Günlük Detay Geçmişi)
    │   ├── bindings/diary_binding.dart
    │   ├── controllers/diary_controller.dart
    │   └── views/diary_view.dart       (Geçmiş yemek listesi)
    │
    ├── food/                       (Yemek Ekleme İşlemleri)
    │   ├── bindings/food_binding.dart
    │   ├── controllers/food_controller.dart
    │   └── views/
    │       ├── food_entry_view.dart    (Kamera/Galeri/Manuel seçim ekranı)
    │       ├── ai_analysis_view.dart   (AI sonucu gelen JSON'u onaylama ekranı)
    │       └── manual_add_view.dart    (El ile isim/kalori girme ekranı)
    │
    ├── activity/                   (Aktivite Ekleme)
    │   ├── bindings/activity_binding.dart
    │   ├── controllers/activity_controller.dart
    │   └── views/activity_add_view.dart (Spor seçimi ve süre girişi)
    │
    ├── health/                     (Tahlil Analizi)
    │   ├── bindings/health_binding.dart
    │   ├── controllers/health_controller.dart
    │   └── views/
    │       ├── health_history_view.dart (Eski raporlar listesi)
    │       └── analysis_result_view.dart (Yüklenen PDF'in AI yorumu)
    │
    └── profile/                    (Profil Ayarları)
        ├── bindings/profile_binding.dart
        ├── controllers/profile_controller.dart
        └── views/profile_view.dart     (Kilo güncelleme, Çıkış yap)
5. VERİTABANI ŞEMALARI
A. User (Kullanıcı)
email, password, ad_soyad
profil: { yas, boy, kilo, cinsiyet, aktivite_seviyesi }
hedefler: { gunluk_kalori (Otomatik), su_hedefi_ml (Default: 2500) }
B. DailyLog (Günlük Kayıt)
user_id: ObjectId, tarih: String ("YYYY-MM-DD") -> Unique Index
toplam_alinan_kalori, toplam_yakilan_kalori, su_tuketimi_ml
yemekler: Array [{ isim, kalori, makrolar: {prot, karb, yag}, kaynak: 'ai/barkod/manuel' }]
aktiviteler: Array [{ isim, sure_dk, yakilan_kalori }]
C. HealthReport (Tahlil)
ai_analiz_metni: String
oneriler: Array [String]
tarih: Date
6. DETAYLI ÖZELLİK AKIŞLARI (FLOWS)
Akış 1: Kayıt ve Hedef Belirleme (Auth)
Mobil: Kullanıcı Ad, Soyad, Email, Şifre, Yaş, Boy, Kilo, Cinsiyet, Aktivite bilgisini girer (Onboarding View).
Backend: BMR hesaplar, kalori hedefini belirler ve kaydeder.
Akış 2: Dashboard ve Hesaplama
Mobil: /api/logs/:tarih endpointinden veri çeker.
Hesap: Kalan = Hedef - (Alınan - Yakilan). Halka grafiği doldurulur.
Akış 3: AI ile Yemek Ekleme
Mobil: FoodEntryView -> Kamera açılır -> Foto MultipartFile olarak atılır.
Backend: Dosya RAM -> Base64 -> Gemini. JSON döner.
Mobil: AiAnalysisView açılır. Kullanıcı onaylarsa /api/food/confirm ile kaydedilir.
Akış 4: Manuel Yemek Ekleme
Mobil: ManualAddView -> İsim ve Kalori girilir.
Backend: /api/food/add ile listeye eklenir.
Akış 5: Su Takibi
Mobil: Dashboard üzerindeki (+200ml) butonu tetiklenir.
Backend: /api/water/update çağrılır.
Akış 6: Aktivite Ekleme
Mobil: ActivityAddView -> Spor seç, süre gir.
Backend: /api/activity/add ile yakılan kalori işlenir.
Akış 7: Kan Tahlili Analizi
Mobil: HealthHistoryView -> Dosya Yükle -> Backend'e atılır.
Backend: Dosya -> Base64 -> Gemini ("Yorumla").
Mobil: AnalysisResultView ekranında AI yorumu gösterilir.
7. API ENDPOINT LISTESİ
POST /api/auth/register
POST /api/auth/login
POST /api/food/analyze
POST /api/food/confirm
POST /api/food/add (Manuel)
POST /api/water/update
POST /api/activity/add
POST /api/health/analyze
GET /api/logs/:date