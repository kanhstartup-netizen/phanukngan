#!/bin/bash
# ==========================================
# PHANUKNGAN — Quick Setup Script
# ==========================================
echo "PHANUKNGAN Setup"
echo "================"

# 1. ກວດ Flutter
if ! command -v flutter &>/dev/null; then
  echo "✗ Flutter ບໍ'ພົບ — ໄປ flutter.dev"
  exit 1
fi
echo "✓ Flutter OK"

# 2. ຖາມ Supabase Keys
echo ""
echo "ໃສ' Supabase Project URL (ຈາກ supabase.com → Settings → API):"
read SUPA_URL
echo "ໃສ' Supabase Anon Key:"
read SUPA_KEY

# 3. ອັບເດດ main.dart
sed -i "s|https://YOUR_PROJECT.supabase.co|$SUPA_URL|g" lib/main.dart
sed -i "s|eyJYOUR_ANON_KEY|$SUPA_KEY|g" lib/main.dart
echo "✓ Supabase Keys ໃສ'ແລ'ວ"

# 4. ຖາມ n8n URL
echo ""
echo "ໃສ' n8n URL (localhost:5678 ຫ'ືຫ' Railway URL):"
read N8N_URL
sed -i "s|http://localhost:5678/webhook|$N8N_URL/webhook|g" lib/services/n8n_service.dart
echo "✓ n8n URL ໃສ'ແລ'ວ"

# 5. flutter pub get
echo ""
echo "→ flutter pub get..."
flutter pub get
echo "✓ Dependencies OK"

echo ""
echo "========================================"
echo "Setup ສ'ເລັດ! Run App:"
echo "  flutter run"
echo "========================================"
