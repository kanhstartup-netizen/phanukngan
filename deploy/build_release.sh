#!/bin/bash
# ==========================================
# PHANUKNGAN — Build Release Script
# ==========================================
# ວິທີໃຊ້: chmod +x deploy/build_release.sh && ./deploy/build_release.sh

set -e
echo "========================================"
echo "  PHANUKNGAN — Build Release"
echo "========================================"

# ---- ກວດ Flutter ----
if ! command -v flutter &> /dev/null; then
  echo "✗ Flutter ບໍ່ພົບ — ຕິດຕັ້ງກ່ອນ"
  exit 1
fi
echo "✓ Flutter: $(flutter --version | head -1)"

# ---- Clean ----
echo ""
echo "→ Clean Project..."
flutter clean
flutter pub get

# ---- ກວດ Code ----
echo ""
echo "→ Analyze Code..."
flutter analyze --no-fatal-infos || true

# ---- Test ----
echo ""
echo "→ Run Unit Tests..."
flutter test test/ || echo "⚠ Tests failed — ຍັງ Build ຕໍ່"

# ---- Build Android APK (ສຳລັບ Test) ----
echo ""
echo "→ Build Android APK..."
flutter build apk \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

echo "✓ APK: build/app/outputs/flutter-apk/app-release.apk"

# ---- Build Android AAB (ສຳລັບ Google Play) ----
echo ""
echo "→ Build Android App Bundle (Google Play)..."
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

echo "✓ AAB: build/app/outputs/bundle/release/app-release.aab"

# ---- ສ'ຄຮ່ວມ ----
echo ""
echo "========================================"
echo "  BUILD COMPLETE!"
echo "========================================"
echo ""
echo "ໄຟລ໌ທີ່ README:"
echo "  APK (Test): build/app/outputs/flutter-apk/app-release.apk"
echo "  AAB (Play): build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "ຂັ້ນຕໍ່ໄປ:"
echo "  1. ໄປ play.google.com/console"
echo "  2. Create App → ໃສ່ຊື່ PHANUKNGAN"
echo "  3. Upload .aab ໄຟລ໌"
echo "  4. ຕື່ມ Store Listing (ຮູບ, ຄຳອະທິບາຍ)"
echo "  5. ສົ່ງ Review (1-3 ວັນ)"
