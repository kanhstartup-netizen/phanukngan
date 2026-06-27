#!/bin/bash
# ==========================================
# PHANUKNGAN — Build + Sign Release
# ==========================================
set -e
echo ""
echo "╔══════════════════════════════════════╗"
echo "║   PHANUKNGAN — Build Release APK    ║"
echo "╚══════════════════════════════════════╝"
cd "$(dirname "$0")/.."

# ---- ກວດ Keystore ----
if [ ! -f "phanukngan-release.jks" ]; then
  echo ""
  echo "▶ ສ'ງ Keystore (ຄ'ງດ'ວ — ສ'ຄໄວ'ຢ'າງປອດໄພ!)"
  echo ""
  keytool -genkey -v \
    -keystore phanukngan-release.jks \
    -alias phanukngan \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -dname "CN=PHANUKNGAN, OU=App, O=PHANUKNGAN Co, L=Vientiane, S=Vientiane, C=LA"
  echo "  ✓ Keystore ສ'ງແລ'ວ: phanukngan-release.jks"
fi

# ---- ສ'ງ key.properties ----
if [ ! -f "android/key.properties" ]; then
  read -p "  Keystore Password: " STORE_PASS
  read -p "  Key Password     : " KEY_PASS
  cat > android/key.properties << EOF
storePassword=$STORE_PASS
keyPassword=$KEY_PASS
keyAlias=phanukngan
storeFile=../../phanukngan-release.jks
EOF
  echo "  ✓ android/key.properties ສ'ງແລ'ວ"
fi

# ---- Load Env ----
source deploy/.env 2>/dev/null || true

# ---- flutter clean + pub get ----
echo ""
echo "▶ Clean + Dependencies..."
flutter clean
flutter pub get
echo "  ✓ OK"

# ---- Build APK ----
echo ""
echo "▶ Build APK (ສ'ລ'ບ Test)..."
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info
APK="build/app/outputs/flutter-apk/app-release.apk"
echo "  ✓ APK: $APK ($(du -sh "$APK" | cut -f1))"

# ---- Build AAB ----
echo ""
echo "▶ Build App Bundle (Google Play)..."
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/debug-info
AAB="build/app/outputs/bundle/release/app-release.aab"
echo "  ✓ AAB: $AAB ($(du -sh "$AAB" | cut -f1))"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   Build ສ'ເລ'ດ!                               ║"
echo "╠══════════════════════════════════════════════╣"
echo "║                                              ║"
echo "║   APK (Test):  $APK"
echo "║   AAB (Play):  $AAB"
echo "║                                              ║"
echo "║   ຂ'ນຕ'ໄປ — Google Play:                      ║"
echo "║   1. play.google.com/console                 ║"
echo "║   2. Create App → PHANUKNGAN                ║"
echo "║   3. Production → Upload .aab               ║"
echo "║   4. Store Listing → ດ'ຮ'ບ deploy/store_listing.md"
echo "║   5. Submit → Review (1-3 ວ'ນ)              ║"
echo "╚══════════════════════════════════════════════╝"
