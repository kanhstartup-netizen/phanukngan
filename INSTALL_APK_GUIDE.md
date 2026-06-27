# ຄ'ມ'ອ Build + ຕ'ດຕ'ງ APK — PHANUKNGAN

## ວິທ'ທ' 1: ງ'າຍທ'ສ'ດ — Debug APK (ໃຊ'ໄດ'ທ'ນທ')

### Windows
```
1. ເປີດ CMD ໃນ Folder phanukngan
2. Double-click BUILD_APK_NOW.bat
3. ລໍຖ'າ 2-5 ນາທ'
4. APK ຢ'ທ': build\app\outputs\flutter-apk\app-debug.apk
```

### Mac / Linux
```bash
cd phanukngan
bash BUILD_APK_NOW.sh
# ເລ'ອກ 1 (Debug)
# ລໍຖ'າ 2-5 ນາທ'
```

---

## ວິທ'ຕ'ດຕ'ງໃນໂທລະສ'ບ Android

### ທາງ A — USB (ໄວທ'ສ'ດ)
```bash
# ຕ'ອ USB + Enable USB Debugging
adb devices              # ກວດວ'າໂທລະສ'ບ Connect
adb install app-debug.apk
```

### ທາງ B — ສ'ງໄຟລ'
```
1. ສ'ງ .apk ໄປ Google Drive / Telegram / Email
2. ເປີດ Link ໃນໂທລະສ'ບ
3. Download APK
4. Settings → Security → Install Unknown Apps → ON
5. ກົດ APK → Install
```

### ທາງ C — QR Code (ໄວ)
```bash
# ໃຊ' Python ສ'ງ HTTP Server
cd build/app/outputs/flutter-apk
python3 -m http.server 8000
# ສ'ງ QR Code: http://IP:8000/app-debug.apk
```

---

## ວິທ'ທ' 2: Release APK (ສ'ລ'ບ ສ'ງຄ'ນ)

```bash
bash BUILD_APK_NOW.sh
# ເລ'ອກ 2 (Release)
# ໃສ' Keystore Password
# ລໍຖ'າ 3-7 ນາທ'
# APK: build/app/outputs/flutter-apk/app-release.apk
```

Release APK:
- ເລ'ວກວ'າ Debug
- ຂະໜ'ດນ'ອຍກວ'າ
- ສ'ງຄ'ນໄດ' (ບ'ມ' Debug info)
- ຕ'ອງ Sign ດ'ວຍ Keystore

---

## ຖ'ຜິດພາດ

### "flutter: command not found"
```
1. ໄປ https://flutter.dev
2. Download Flutter SDK
3. Extract → C:\flutter (Windows) ຫ'ື ~/flutter (Mac)
4. ເພ'ມ PATH: C:\flutter\bin
5. ເປີດ CMD ໃໝ' → flutter doctor
```

### "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter build apk --debug
```

### "SDK not found"
```bash
flutter doctor  # ກວດ Android SDK
# ຖ'ບ'ມ': ຕ'ດຕ'ງ Android Studio
```

### APK ຕ'ດຕ'ງໃນໂທລະສ'ບບ'ໄດ'
```
Settings → Apps → Special App Access
→ Install Unknown Apps
→ ເລ'ອກ File Manager / Browser → Allow
```
