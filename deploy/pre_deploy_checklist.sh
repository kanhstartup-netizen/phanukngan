#!/bin/bash
# ==========================================
# PHANUKNGAN — Pre-Deploy Checklist
# ==========================================
# ວິທີໃຊ້: bash deploy/pre_deploy_checklist.sh

PASS=0
FAIL=0

check() {
  local desc=$1
  local cmd=$2
  if eval "$cmd" > /dev/null 2>&1; then
    echo "  ✓ $desc"
    PASS=$((PASS+1))
  else
    echo "  ✗ $desc"
    FAIL=$((FAIL+1))
  fi
}

echo ""
echo "========================================"
echo "  PHANUKNGAN Pre-Deploy Checklist"
echo "========================================"

# ---- Flutter ----
echo ""
echo "[ Flutter ]"
check "Flutter ຕິດຕັ້ງແລ້ວ"          "command -v flutter"
check "Dart ຕິດຕັ້ງແລ້ວ"             "command -v dart"
check "Android SDK ພ້ອມ"             "command -v adb"
check "flutter doctor ຜ່ານ"          "flutter doctor | grep -v '✗'"

# ---- Project ----
echo ""
echo "[ Project Files ]"
check "pubspec.yaml ມີ"              "test -f pubspec.yaml"
check "supabase_flutter ໃນ deps"     "grep -q supabase_flutter pubspec.yaml"
check "google_fonts ໃນ deps"         "grep -q google_fonts pubspec.yaml"
check "flutter_animate ໃນ deps"      "grep -q flutter_animate pubspec.yaml"
check "Supabase URL ຕັ້ງໄວ້"         "grep -q 'supabase.co' lib/main.dart"
check "Logo file ມີ"                 "test -f lib/widgets/brand/phanukngan_logo.dart"
check "Login Screen ມີ"             "test -f lib/screens/auth/login_screen.dart"
check "Upload Screen ມີ"            "test -f lib/screens/jobs/upload_screen.dart"
check "n8n Workflows ມີ"             "test -d n8n-workflows"

# ---- Android ----
echo ""
echo "[ Android ]"
check "AndroidManifest.xml ມີ"       "test -f android/app/src/main/AndroidManifest.xml"
check "Keystore ມີ (optional)"       "test -f phanukngan-release.jks"
check "key.properties ມີ"           "test -f android/key.properties"

# ---- Environment ----
echo ""
echo "[ Environment Variables ]"
check "SUPABASE_URL ຕັ້ງ"            "test -n '$SUPABASE_URL'"
check "ANTHROPIC_API_KEY ຕັ້ງ"       "test -n '$ANTHROPIC_API_KEY'"
check "FB_PAGE_TOKEN ຕັ້ງ"           "test -n '$FB_PAGE_TOKEN'"

# ---- n8n ----
echo ""
echo "[ n8n ]"
check "Docker ຕິດຕັ້ງ"              "command -v docker"
check "docker-compose.yml ມີ"        "test -f deploy/docker-compose.yml"
check "Workflow files ມີ"            "ls n8n-workflows/*.json > /dev/null 2>&1"

# ---- Build Test ----
echo ""
echo "[ Build Test ]"
check "flutter pub get ຜ່ານ"        "flutter pub get"
check "flutter analyze ຜ່ານ"        "flutter analyze --no-fatal-infos 2>&1 | grep -v 'error'"

# ---- Summary ----
echo ""
echo "========================================"
TOTAL=$((PASS+FAIL))
echo "  ຜ່ານ: $PASS / $TOTAL"
if [ $FAIL -gt 0 ]; then
  echo "  ✗ ຍັງມີ $FAIL ຢ່າງທີ່ຕ'ອງແກ'ໄຂ"
  echo ""
  echo "  ໂດດ Deploy ໄດ'ຖ'ານ $PASS >= $((TOTAL*8/10)) ຢ່າງ"
else
  echo "  ✓ ທຸກຢ'າງ READY — Deploy ໄດ'ເລີຍ!"
fi
echo "========================================"
