#!/bin/bash
# ==========================================
# PHANUKNGAN — Build APK (Mac/Linux)
# ==========================================
set -e
echo ""
echo "╔══════════════════════════════════╗"
echo "║   PHANUKNGAN — Build APK         ║"
echo "╚══════════════════════════════════╝"
cd "$(dirname "$0")"

# ---- ກວດ Flutter ----
if ! command -v flutter &>/dev/null; then
  echo "✗ Flutter ບໍ'ພົບ!"
  echo "  ໄປ: https://flutter.dev/docs/get-started/install"
  exit 1
fi
echo "✓ Flutter: $(flutter --version | head -1)"

# ---- ເລ'ອກ Build Type ----
echo ""
echo "ເລ'ອກ APK ທ'ຕ'ອງການ:"
echo "  1) Debug APK   — ໃຊ'ໄດ'ທ'ນທ'  (ບ'ຕ'ອງ Sign)"
echo "  2) Release APK — ໄວ ສ'ດ ປລ'ດໄພ (ຕ'ອງ Keystore)"
read -p "ເລ'ອກ (1/2): " CHOICE

if [ "$CHOICE" = "2" ]; then
  # ---- Release Build ----
  echo ""
  echo "▶ ກວດ Keystore..."

  if [ ! -f "phanukngan-release.jks" ]; then
    echo "  ສ'ງ Keystore ໃໝ'..."
    keytool -genkey -v \
      -keystore phanukngan-release.jks \
      -alias phanukngan \
      -keyalg RSA -keysize 2048 -validity 10000 \
      -dname "CN=PHANUKNGAN,OU=App,O=PHANUKNGAN,L=Vientiane,C=LA"
  fi

  if [ ! -f "android/key.properties" ]; then
    read -sp "  Keystore Password: " SP && echo
    read -sp "  Key Password     : " KP && echo
    cat > android/key.properties << EOF
storePassword=$SP
keyPassword=$KP
keyAlias=phanukngan
storeFile=../../phanukngan-release.jks
EOF
  fi

  echo "▶ flutter pub get..."
  flutter pub get

  echo "▶ Build Release APK..."
  flutter build apk --release \
    --obfuscate \
    --split-debug-info=build/debug-info

  APK="build/app/outputs/flutter-apk/app-release.apk"
  TYPE="Release"

else
  # ---- Debug Build (ງ'າຍ ໄວ) ----
  echo ""
  echo "▶ flutter pub get..."
  flutter pub get

  echo "▶ Build Debug APK..."
  flutter build apk --debug

  APK="build/app/outputs/flutter-apk/app-debug.apk"
  TYPE="Debug"
fi

# ---- ສ'ຄຮ'ວມ ----
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   APK ສ'ເລ'ດ ($TYPE)!"
echo "╠══════════════════════════════════════════╣"
echo "║"
echo "║   ໄຟລ': $APK"
echo "║   ຂະໜ'ດ: $(du -sh "$APK" | cut -f1)"
echo "║"
echo "╠══════════════════════════════════════════╣"
echo "║   ວິທ'ຕ'ດຕ'ງໃນໂທລະສ'ບ:"
echo "║"
echo "║   ທາງ A (USB):"
echo "║   adb install $APK"
echo "║"
echo "║   ທາງ B (Manual):"
echo "║   1. ສ'ງ APK ໄປໂທລະສ'ບ"
echo "║   2. Settings → Security → Unknown Sources ON"
echo "║   3. ເປີດ APK → Install"
echo "╚══════════════════════════════════════════╝"

# ---- ຖ'ງວ'ສ'ງ ADB ----
if command -v adb &>/dev/null; then
  echo ""
  read -p "Install ໃສ'ໂທລະສ'ບ ທ'ຕ'ອ USB ຕອນນ'? (y/n): " INSTALL
  if [ "$INSTALL" = "y" ]; then
    adb install -r "$APK"
    echo "✓ Install ສ'ເລ'ດ!"
  fi
fi
