#!/bin/bash
# ==========================================
# PHANUKNGAN — Supabase Auto Setup
# ==========================================
set -e
echo ""
echo "╔══════════════════════════════════════╗"
echo "║   PHANUKNGAN — Supabase Setup        ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ---- 1. ຖາມ Keys ----
echo "▶ ຂັ້ນ 1: ໃສ່ Supabase Keys"
echo "  (ຈາກ supabase.com → Project Settings → API)"
echo ""
read -p "  Project URL   : " SUPA_URL
read -p "  Anon Key      : " SUPA_KEY
read -p "  Service Key   : " SUPA_SVC

# ---- 2. ຖາມ n8n ----
echo ""
echo "▶ ຂັ້ນ 2: ໃສ່ n8n URL"
echo "  (localhost:5678 ຫຼື Railway URL)"
read -p "  n8n URL       : " N8N_URL

# ---- 3. ຖາມ Brand ----
echo ""
echo "▶ ຂັ້ນ 3: ຂໍ້ມູນ Brand"
read -p "  ຊື່ Brand      : " BRAND
read -p "  ເບີຕິດຕໍ່     : " PHONE

# ---- 4. ຂຽນ main.dart ----
echo ""
echo "▶ ອັບເດດ lib/main.dart ..."
cd "$(dirname "$0")/.."
sed -i.bak "s|https://YOUR_PROJECT.supabase.co|$SUPA_URL|g" lib/main.dart
sed -i.bak "s|eyJYOUR_ANON_KEY|$SUPA_KEY|g"                 lib/main.dart
echo "  ✓ Supabase URL + Key ໃສ່ແລ້ວ"

# ---- 5. ຂຽນ n8n_service.dart ----
sed -i.bak "s|http://localhost:5678/webhook|${N8N_URL}/webhook|g" lib/services/n8n_service.dart
echo "  ✓ n8n URL ໃສ່ແລ້ວ"

# ---- 6. ສ'ງ .env ----
cat > deploy/.env << EOF
SUPABASE_URL=$SUPA_URL
SUPABASE_ANON_KEY=$SUPA_KEY
SUPABASE_SERVICE_KEY=$SUPA_SVC
N8N_WEBHOOK_URL=${N8N_URL}/webhook
BRAND_NAME=$BRAND
CONTACT_PHONE=$PHONE
EOF
echo "  ✓ deploy/.env ສ'ງແລ'ວ"

# ---- 7. flutter pub get ----
echo ""
echo "▶ flutter pub get ..."
flutter pub get
echo "  ✓ Dependencies OK"

# ---- 8. Supabase Schema ----
echo ""
echo "▶ ໂຄ'ດ SQL Database Schema"
echo "  ═══════════════════════════════════════"
echo "  1. ໄປ $SUPA_URL"
echo "  2. ກົດ SQL Editor (ເມ'ນ'ຊ'າຍ)"
echo "  3. Copy ທ'ງໝ'ດຈາກ: supabase/schema.sql"
echo "  4. Paste ໃສ' Editor → ກົດ RUN"
echo "  ═══════════════════════════════════════"
echo ""
read -p "  ກົດ Enter ເມ'ື Schema Run ສ'ເລ'ດ..."

# ---- 9. Enable Realtime ----
echo ""
echo "▶ Enable Realtime Tables"
echo "  Authentication → Supabase → Storage"
echo "  Table Editor → jobs → Enable Realtime ✓"
echo "  Table Editor → notifications → Enable Realtime ✓"
echo ""

# ---- Done ----
echo "╔══════════════════════════════════════╗"
echo "║   Setup ສ'ເລ'ດ! Run App:             ║"
echo "║                                      ║"
echo "║   flutter run                        ║"
echo "╚══════════════════════════════════════╝"
echo ""
