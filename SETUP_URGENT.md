# ຄູ່ມືຕັ້ງ 3 ໂຕດ່ວນ — PHANUKNGAN

---

## ໂຕດ່ວນ 1 — Supabase Backend (15 ນາທີ)

### ຂັ້ນຕອນ:

**1. ສ້າງ Project**
- ໄປ https://supabase.com → Sign Up ຟຣີ
- ກົດ "New Project" → ໃສ່ຊື່ `phanukngan`
- ເລືອກ Region: Southeast Asia (Singapore)

**2. ສ້າງ Database**
- ໄປ SQL Editor (ເມນູຊ້າຍ)
- Copy ເນື້ອໃນ `supabase/schema.sql` ທັງໝົດ
- Paste ໃສ່ SQL Editor → ກົດ RUN

**3. ເອົາ API Keys**
- Project Settings → API
- Copy: `Project URL` → ໃສ່ `_supabaseUrl` ໃນ `main.dart`
- Copy: `anon/public key` → ໃສ່ `_supabaseAnonKey` ໃນ `main.dart`

```dart
// lib/main.dart
const _supabaseUrl     = 'https://xxxx.supabase.co';   // ← ປ່ຽນ
const _supabaseAnonKey = 'eyJxxxxxxxx';                 // ← ປ່ຽນ
```

---

## ໂຕດ່ວນ 2 — Login Screen (ໃຊ້ໄດ້ທັນທີ)

Login Screen ສ້າງໂດຍ Supabase Auth — ບໍ່ຕ້ອງຕັ້ງຫຍັງເພີ່ມ!

```
flutter pub get
flutter run
→ ຈະ Redirect ໄປ /login ອັດຕະໂນມັດ
→ ສ້າງ Account → ເຂົ້າ Home ໄດ້ທັນທີ
```

**ຖ້າຢາກ Confirm Email ອັດຕະໂນມັດ (ສຳລັບ Dev):**
- Supabase → Authentication → Settings
- ປິດ "Enable email confirmations" ລະຫວ່າງ Test

---

## ໂຕດ່ວນ 3 — n8n ຕັ້ງ + API Keys (30 ນາທີ)

### ທາງ A: Docker (ໃນ PC)
```bash
docker run -it --rm \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
```
ເຂົ້າ: http://localhost:5678

### ທາງ B: Railway (Online 24/7 — ແນະນຳ)
1. ໄປ https://railway.app → Login ດ້ວຍ GitHub
2. New Project → Deploy from template → ຊອກ "n8n"
3. Deploy → ໄດ້ URL ທັນທີ

### ໃສ່ API Keys ໃນ n8n:
| Key | ເອົາຈາກ |
|-----|---------|
| `ANTHROPIC_API_KEY` | console.anthropic.com |
| `FB_PAGE_TOKEN` | developers.facebook.com |
| `FB_PAGE_ID` | Facebook Page → About |
| `PHANUKNGAN_API_URL` | Supabase URL + `/rest/v1` |

### Import Workflows:
- n8n → Workflows → Import from file
- Import ທຸກໄຟລ໌ `n8n-workflows/*.json`
- ກົດ Activate ທຸກ Workflow

### ອັບເດດ Flutter ໃຫ້ Webhook URL ຕົວຈິງ:
```dart
// lib/services/n8n_service.dart
static const String _baseUrl = 'https://YOUR-N8N.railway.app/webhook';
```

---

## ກວດສອບທຸກຢ່າງ

```bash
flutter pub get
flutter run

# ກວດ:
# ✓ Splash → Logo ໂຕ 2 ຫຼ້ນ Animation
# ✓ → Login Screen ສວຍງາມ
# ✓ → ສ້າງ Account → Home
# ✓ → Dashboard ດຶງ Stats ຈາກ Supabase
# ✓ → Chat → Webhook → n8n
```
