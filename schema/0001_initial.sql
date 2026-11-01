-- Life OS schema v1 (M0001). SQL trung lập nền tảng: Swift (GRDB/SQLiteData) và Android (SQLite) chạy cùng file này.
-- Quy tắc (ADR-0003, sửa bởi ADR-0016 để hợp với SyncEngine của SQLiteData):
--   khoá chính đơn TEXT UUID chữ thường; không UNIQUE ngoài PK; không khoá ngoại RESTRICT/NO ACTION (MVP không dùng FK);
--   mọi cột NOT NULL có "ON CONFLICT REPLACE" + DEFAULT (bản ghi từ máy chạy phiên bản cũ có thể thiếu cột);
--   xoá mềm = deleted_at (để Hoàn tác); migration chỉ thêm, không đổi tên/xoá cột; không đặt tên cột trùng tên dành riêng của CKRecord.
--   Ngày lịch TEXT 'YYYY-MM-DD', mốc thời gian INTEGER ms UTC (ADR-0013).
-- Bảng có cột `deleted_at` là bảng ĐỒNG BỘ (đăng ký trong CloudSync). Bảng tiền tố local_ KHÔNG đồng bộ.
-- Siêu dữ liệu đồng bộ nằm trong metadatabase riêng của SQLiteData, không ở đây.

PRAGMA foreign_keys = OFF;

-- ===== Việc =====
CREATE TABLE area (                 -- danh mục việc: Công việc, Sức khỏe, Nhà…
  id          TEXT PRIMARY KEY NOT NULL,
  name        TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
  icon        TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'circle',
  color       TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'dataSlate',   -- tên token data-*
  sort_key    TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'm',            -- fractional index (SPEC-sync §3.4)
  archived_at INTEGER,
  created_at  INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  updated_at  INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  deleted_at  INTEGER
);

CREATE TABLE task (
  id           TEXT PRIMARY KEY NOT NULL,
  title        TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
  notes        TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
  area_id      TEXT,                                -- NULL = không danh mục
  due_on       TEXT,                                -- 'YYYY-MM-DD' hoặc NULL
  priority     INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,          -- 0 không, 1 thấp, 2 vừa, 3 cao
  status       TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'open',        -- 'open' | 'done'
  completed_at INTEGER,
  inbox        INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,          -- 1 = chưa xếp (từ Ghi nhanh, không ngày, không danh mục)
  sort_key     TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'm',
  source       TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'manual',      -- 'manual' | 'capture'
  project_id   TEXT,                                -- mở đường GĐ2, MVP luôn NULL
  goal_id      TEXT,                                -- mở đường GĐ2, MVP luôn NULL
  created_at   INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  updated_at   INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  deleted_at   INTEGER
);
CREATE INDEX task_open_due ON task(status, due_on) WHERE deleted_at IS NULL;
CREATE INDEX task_inbox    ON task(inbox) WHERE deleted_at IS NULL AND status = 'open';

-- ===== Thói quen =====
CREATE TABLE habit (
  id           TEXT PRIMARY KEY NOT NULL,
  name         TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
  icon         TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'checkmark',
  color        TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'dataGreen',
  weekdays     INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 127,        -- bitmask T2=1, T3=2, … CN=64; 127 = mỗi ngày
  target_count INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 1,          -- [Mở rộng] "8 ly"
  reminder_at  TEXT,                                -- 'HH:mm' [Mở rộng]
  sort_key     TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'm',
  goal_id      TEXT,
  archived_at  INTEGER,
  created_at   INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  updated_at   INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  deleted_at   INTEGER
);

CREATE TABLE habit_log (              -- id = UUIDv5('habit_log:<habit_id>:<day>') (ADR-0014)
  id         TEXT PRIMARY KEY NOT NULL,
  habit_id   TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
  day        TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',                          -- 'YYYY-MM-DD'
  count      INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 1,
  status     TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'done',           -- 'done' | 'rest' [Mở rộng]
  created_at INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  updated_at INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  deleted_at INTEGER                                 -- bỏ tick = đặt deleted_at
);
CREATE INDEX habit_log_by_habit_day ON habit_log(habit_id, day) WHERE deleted_at IS NULL;

-- ===== Nhật ký và tâm trạng =====
CREATE TABLE journal_entry (          -- một mục mỗi ngày; id = UUIDv5('journal_entry:<day>')
  id          TEXT PRIMARY KEY NOT NULL,
  day         TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
  mood        INTEGER,                               -- 1..5 hoặc NULL
  energy      INTEGER,                               -- 1..5 hoặc NULL
  body        TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',             -- nội dung bài (MVP chưa mã hoá mức trường, ADR-0016)
  created_at  INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  updated_at  INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  deleted_at  INTEGER
);
CREATE INDEX journal_by_day ON journal_entry(day) WHERE deleted_at IS NULL;

-- ===== Thu chi =====
CREATE TABLE category (
  id          TEXT PRIMARY KEY NOT NULL,
  kind        TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',                         -- 'expense' | 'income'
  name        TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
  icon        TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'tag',
  color       TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'dataSlate',
  keywords    TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '[]',            -- JSON mảng chuỗi, cho Ghi nhanh đoán danh mục
  is_fallback INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,            -- 1 = "Khác" của loại đó
  sort_key    TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'm',
  archived_at INTEGER,
  created_at  INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  updated_at  INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  deleted_at  INTEGER
);

CREATE TABLE txn (                    -- "transaction" là từ khoá SQL nên đặt tên txn
  id           TEXT PRIMARY KEY NOT NULL,
  kind         TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',                        -- 'expense' | 'income'
  amount       INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,                     -- > 0, đơn vị nhỏ nhất (VND: đồng)
  currency     TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'VND',
  category_id  TEXT,
  note         TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',
  occurred_on  TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',                        -- 'YYYY-MM-DD'
  source       TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'manual',
  recurring_id TEXT,                                 -- [Mở rộng] khoản định kỳ
  project_id   TEXT,
  goal_id      TEXT,
  created_at   INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  updated_at   INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  deleted_at   INTEGER
);
CREATE INDEX txn_by_day ON txn(occurred_on) WHERE deleted_at IS NULL;
CREATE INDEX txn_by_cat ON txn(category_id, occurred_on) WHERE deleted_at IS NULL;

CREATE TABLE budget (                 -- id = UUIDv5('budget:<YYYY-MM>:<category_id|total>')
  id          TEXT PRIMARY KEY NOT NULL,
  month       TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',                         -- 'YYYY-MM'
  category_id TEXT,                                  -- NULL = tổng tháng
  amount      INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  created_at  INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  updated_at  INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  deleted_at  INTEGER
);

-- ===== Review tuần =====
CREATE TABLE weekly_review (          -- id = UUIDv5('weekly_review:<week_start>')
  id           TEXT PRIMARY KEY NOT NULL,
  week_start   TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',                        -- thứ Hai 'YYYY-MM-DD'
  rating       INTEGER,                              -- 1..5
  answers      TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '{}',           -- JSON {went_well, hard, learned}
  focus        TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '[]',           -- JSON mảng tối đa 3 chuỗi
  completed_at INTEGER,
  created_at   INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  updated_at   INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  deleted_at   INTEGER
);

-- ===== Cài đặt đồng bộ =====
CREATE TABLE setting (                -- id = UUIDv5('setting:<key>')
  id         TEXT PRIMARY KEY NOT NULL,
  key        TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',                          -- 'display_name', 'theme', 'today_cards', 'reminders'…
  value      TEXT NOT NULL ON CONFLICT REPLACE DEFAULT '',                          -- JSON
  created_at INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  updated_at INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0,
  deleted_at INTEGER
);

-- ===== Nội bộ, KHÔNG đồng bộ (không đăng ký với SyncEngine) =====
CREATE TABLE local_setting (          -- riêng từng máy: app_lock, primary_reminder_device, onboarding_step
  key   TEXT PRIMARY KEY NOT NULL,
  value TEXT NOT NULL
) WITHOUT ROWID;
