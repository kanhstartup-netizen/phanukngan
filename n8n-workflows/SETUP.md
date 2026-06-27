# ຄູ່ມືຕິດຕັ້ງ n8n Workflows — PHANUKNGAN

## Workflows ທີ່ມີ

| ໄຟລ໌ | ໜ້າທີ່ | Trigger |
|-------|--------|---------|
| `01-morning-brain.json` | ວິເຄາະ + ແຈກຈ່າຍວຽກ | ທຸກມື້ 06:00 |
| `02-image-pipeline.json` | ສ້າງຮູບ Midjourney → Canva → Caption | Webhook |
| `03-video-pipeline.json` | ຕັດຄລິບ CapCut → Subtitle → ໂພສ | Webhook |
| `04-auto-social-post.json` | Approve → QC → FB + TikTok + IG | Webhook |
| `05-weekly-report.json` | Report ທີມ ທຸກວັນເສົາ | ທຸກວັນເສົາ 20:00 |

---

## ຂັ້ນຕອນຕິດຕັ້ງ

### 1. ເລີ່ມ n8n
```bash
docker run -it --rm \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  --env-file .env \
  n8nio/n8n
```

### 2. Import Workflows
- ເປີດ http://localhost:5678
- ໄປ **Workflows → Import from file**
- Import ທຸກໄຟລ໌ `.json` ທີ່ຢູ່ໃນໂຟລເດີນີ້

### 3. ຕັ້ງ Credentials
ໄປ **Settings → Credentials → Add**:

| Credential | ຊ່ອງ |
|-----------|------|
| Anthropic API | API Key ຈາກ console.anthropic.com |
| OpenAI API | API Key ສຳລັບ Whisper |
| Facebook Page | Page ID + Access Token |
| TikTok | Access Token ຈາກ Developer Portal |

### 4. ຕັ້ງ Environment Variables
```bash
cp .env.example .env
# ແກ້ໄຂ .env ໃສ່ຄ່າຕົວຈິງ
```

### 5. Activate Workflows
- ກົດ Toggle **Active** ໃນທຸກ Workflow
- ທົດສອບໂດຍກົດ **Execute Workflow**

---

## ທົດສອບ Webhook ຈາກ Flutter

```dart
// ທົດສອບ Image Pipeline
await N8nService.instance.sendNewJob(
  title: 'ທົດສອບຮູບໂປຣໂມດ',
  type: 'graphic',
  command: 'ສ້າງຮູບສິນຄ້າ ພື້ນຫຼັງຂາວ ສວຍງາມ',
);
```

---

## API Keys ຕ້ອງໄດ້ຮັບ

| Service | ລິ້ງ | ຄ່າໃຊ້ຈ່າຍ |
|---------|------|----------|
| Anthropic | console.anthropic.com | $15-75/M tokens |
| Midjourney | midjourney.com | $10-30/ເດືອນ |
| Canva | canva.com/developers | ຟຣີ + Pro |
| CapCut | open.capcut.com | ຟຣີ |
| Shotstack | shotstack.io | $10-50/ເດືອນ |
| Facebook | developers.facebook.com | ຟຣີ |
| TikTok | developers.tiktok.com | ຟຣີ |
