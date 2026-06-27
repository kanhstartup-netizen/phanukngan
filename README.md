# PHANUKNGAN Flutter App 🇱🇦

ທີມງານ 100 ຄົນ ພ້ອມຮັບຄຳສັ່ງ — Mobile App ສ້າງດ້ວຍ Flutter

---

## ຂັ້ນຕອນຕິດຕັ້ງ

### 1. ຕິດຕັ້ງ Flutter
```bash
# Windows: ດາວໂຫລດຈາກ https://flutter.dev
# ແລ້ວ Extract ໄປທີ່ C:\flutter
# ເພີ່ມ C:\flutter\bin ໃສ່ PATH

# ກວດ setup:
flutter doctor
```

### 2. ຕິດຕັ້ງ Android Studio
- ດາວໂຫລດ: https://developer.android.com/studio
- ເປີດ AVD Manager → ສ້າງ Virtual Device (Pixel 8 ແນະນຳ)

### 3. ດາວໂຫລດ Noto Sans Lao Font
```
ໄປ: https://fonts.google.com/noto/specimen/Noto+Sans+Lao
ດາວໂຫລດ: NotoSansLao-Regular.ttf + NotoSansLao-Bold.ttf
ວາງໄວ້: assets/fonts/
```

### 4. Run Project
```bash
cd phanukngan
flutter pub get
flutter run
```

---

## ໂຄງສ້າງ Project

```
lib/
├── main.dart              # Entry point + Router
├── theme/
│   └── app_theme.dart     # Colors, Fonts, Animations
├── screens/
│   ├── splash_screen.dart # Animated splash
│   ├── home_screen.dart   # Dashboard
│   ├── chat_screen.dart   # AI Chat ພາສາລາວ
│   ├── new_job_screen.dart# ສ້າງວຽກໃໝ່
│   └── other_screens.dart # Result, Scheduler, Team
└── widgets/
    ├── stat_card.dart     # ກ່ອງສະຖິຕິ
    ├── job_card.dart      # ກ່ອງວຽກ
    └── bottom_nav.dart    # Navigation bar
```

---

## Animation ທີ່ໃຊ້

| Package | ໃຊ້ໃນ |
|---------|--------|
| `flutter_animate` | Stagger fadeIn, slideY, scale ທຸກໜ້າ |
| `lottie` | Loading / Success animations |
| `rive` | Interactive character animations |
| `animate_do` | BounceIn, FadeInUp ງ່າຍ |
| `shimmer` | Skeleton loading effect |

---

## ພາສາລາວ

- Font: **Noto Sans Lao** (Google Fonts)
- Line height: `1.6` — ຈຳເປັນສຳລັບລາວ
- Unicode: UTF-8 ຄົບ
- Input: ຮອງຮັບ Lao keyboard ທຸກ Device

---

## Deploy ຂຶ້ນ Store

```bash
# Android APK
flutter build apk --release
# ໄຟລ໌: build/app/outputs/flutter-apk/app-release.apk

# Android App Bundle (Google Play)
flutter build appbundle --release

# iOS (ຕ້ອງໃຊ້ Mac)
flutter build ios --release
```
