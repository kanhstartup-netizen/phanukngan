-- ==========================================
-- PHANUKNGAN — Supabase Database Schema
-- ==========================================
-- ວິທີໃຊ້: ເຂົ້າ supabase.com → SQL Editor → Paste ແລ້ວ Run

-- ---- PROFILES (ຂໍ້ມູນເຈົ້ານາຍ) ----
CREATE TABLE profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  full_name   TEXT,
  brand_name  TEXT DEFAULT 'PHANUKNGAN',
  contact     TEXT,
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ---- TEAMS (ທີມງານ 100 ຄົນ) ----
CREATE TABLE teams (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,         -- 'Video Editor'
  name_lao    TEXT NOT NULL,         -- 'ທີມຕັດຄລິບ'
  role        TEXT NOT NULL,         -- 'video' | 'graphic' | 'content' | 'marketing' | 'social' | 'qc'
  member_count INT DEFAULT 20,
  is_available BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Seed ທີມທັງ 6
INSERT INTO teams (name, name_lao, role, member_count) VALUES
  ('Video Editor',    'ທີມຕັດຄລິບ',         'video',     20),
  ('Graphic Design',  'ທີມແຕ່ງຮູບ',          'graphic',   20),
  ('Content Creator', 'ທີມຂຽນ Content',      'content',   20),
  ('Marketing',       'ທີມການຕະຫຼາດ',       'marketing', 15),
  ('Social Media',    'ທີມ Social Media',    'social',    15),
  ('QC Team',         'ທີມກວດຄຸນນະພາບ',     'qc',        10);

-- ---- JOBS (ວຽກທັງໝົດ) ----
CREATE TABLE jobs (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id      UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title         TEXT NOT NULL,
  title_lao     TEXT,
  type          TEXT NOT NULL,  -- 'video' | 'graphic' | 'content' | 'banner' | 'general'
  command       TEXT,           -- ຄຳສັ່ງພາສາລາວ
  status        TEXT DEFAULT 'pending',
                -- 'pending' | 'doing' | 'qc' | 'done' | 'cancelled'
  team_id       UUID REFERENCES teams(id),
  file_url      TEXT,           -- Footage / ຮູບດິບ
  result_url    TEXT,           -- Output ສຳເລັດ
  caption       TEXT,           -- Caption ລາວ ທີ່ Claude ຂຽນ
  platforms     TEXT[],         -- ['facebook','tiktok','instagram']
  schedule_time TIMESTAMPTZ,    -- ເວລາໂພສ
  posted_at     TIMESTAMPTZ,
  priority      INT DEFAULT 3,  -- 1=ດ່ວນ, 2=ສຳຄັນ, 3=ທຳມະດາ
  deadline      TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER jobs_updated_at BEFORE UPDATE ON jobs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ---- NOTIFICATIONS (ແຈ້ງເຕືອນ) ----
CREATE TABLE notifications (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id    UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  type        TEXT,   -- 'job_complete' | 'approval_required' | 'morning_plan' | 'weekly_report'
  job_id      UUID REFERENCES jobs(id),
  is_read     BOOLEAN DEFAULT FALSE,
  data        JSONB,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ---- WEEKLY REPORTS ----
CREATE TABLE reports (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id    UUID REFERENCES profiles(id) ON DELETE CASCADE,
  week_start  DATE NOT NULL,
  content_lao TEXT,             -- Report ພາສາລາວ ຈາກ Claude
  stats       JSONB,            -- { total, done, teams_performance }
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- ROW LEVEL SECURITY (ຄວາມປອດໄພ)
-- ==========================================
ALTER TABLE profiles      ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs          ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports       ENABLE ROW LEVEL SECURITY;

-- ແຕ່ລະຄົນເຫັນສະເພາະຂໍ້ມູນຕົນເອງ
CREATE POLICY "own_profile"      ON profiles      FOR ALL USING (auth.uid() = id);
CREATE POLICY "own_jobs"         ON jobs          FOR ALL USING (auth.uid() = owner_id);
CREATE POLICY "own_notifications" ON notifications FOR ALL USING (auth.uid() = owner_id);
CREATE POLICY "own_reports"      ON reports       FOR ALL USING (auth.uid() = owner_id);
CREATE POLICY "teams_public"     ON teams         FOR SELECT USING (true);

-- ==========================================
-- REALTIME (ໃຊ້ Supabase Realtime)
-- ==========================================
ALTER PUBLICATION supabase_realtime ADD TABLE jobs;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
