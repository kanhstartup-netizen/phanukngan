#!/bin/bash
# ==========================================
# PHANUKNGAN — Deploy n8n ຂ'ນ Railway
# ==========================================
set -e
echo ""
echo "╔══════════════════════════════════════╗"
echo "║   PHANUKNGAN — Deploy n8n Railway    ║"
echo "╚══════════════════════════════════════╝"

# ---- ກວດ railway CLI ----
if ! command -v railway &>/dev/null; then
  echo ""
  echo "▶ ຕິດຕ'ງ Railway CLI..."
  npm install -g @railway/cli
fi
echo "  ✓ Railway CLI OK"

echo ""
echo "▶ Login Railway..."
railway login

echo ""
echo "▶ ສ'ງ Project..."
railway init --name phanukngan-n8n

echo ""
echo "▶ ໃສ' Environment Variables..."

source "$(dirname "$0")/.env" 2>/dev/null || true

railway variables set \
  N8N_BASIC_AUTH_ACTIVE=true \
  N8N_BASIC_AUTH_USER=phanukngan \
  N8N_BASIC_AUTH_PASSWORD=changeme123 \
  GENERIC_TIMEZONE=Asia/Vientiane \
  ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-CHANGE_ME}" \
  OPENAI_API_KEY="${OPENAI_API_KEY:-CHANGE_ME}" \
  FB_PAGE_ID="${FB_PAGE_ID:-CHANGE_ME}" \
  FB_PAGE_TOKEN="${FB_PAGE_TOKEN:-CHANGE_ME}" \
  TIKTOK_ACCESS_TOKEN="${TIKTOK_ACCESS_TOKEN:-CHANGE_ME}" \
  PHANUKNGAN_API_URL="${SUPABASE_URL:-CHANGE_ME}/rest/v1" \
  BRAND_NAME="${BRAND_NAME:-PHANUKNGAN}" \
  CONTACT_PHONE="${CONTACT_PHONE:-020-XXXX-XXXX}"

echo "  ✓ Variables ໃສ'ແລ'ວ"

echo ""
echo "▶ Deploy n8n Docker Image..."
cat > /tmp/railway-n8n.json << 'JSON'
{
  "image": "n8nio/n8n:latest",
  "ports": [{"port": 5678, "exposedPort": 443}],
  "volumes": [{"mountPath": "/home/node/.n8n"}]
}
JSON

railway up --dockerfile /dev/null

echo ""
echo "▶ ດ'ງ URL..."
N8N_URL=$(railway status --json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('url',''))" 2>/dev/null || echo "ກວດໃນ Railway Dashboard")

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   n8n Deploy ສ'ເລ'ດ!                         ║"
echo "║                                              ║"
echo "║   URL: $N8N_URL"
echo "║                                              ║"
echo "║   ຂ'ນຕ'ໄປ:                                   ║"
echo "║   1. ເຂ'າ n8n URL                            ║"
echo "║   2. Login: phanukngan / changeme123         ║"
echo "║   3. Workflows → Import → ເລ'ອກ 5 JSON     ║"
echo "║   4. Activate ທ'ກ Workflow                   ║"
echo "╚══════════════════════════════════════════════╝"
