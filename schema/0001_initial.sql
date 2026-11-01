-- Life OS schema v1 (M0001). SQL trung lập nền tảng: Swift (GRDB) và Android (SQLite) chạy cùng file này.
-- Quy tắc (ADR-0003): khoá chính TEXT UUID chữ thường; không UNIQUE ngoài PK; không CASCADE;
-- xoá = deleted_at; migration chỉ thêm. Ngày lịch TEXT 'YYYY-MM-DD', mốc thời gian INTEGER ms UTC (ADR-0013).
-- Bảng có cột `deleted_at` là bảng ĐỒNG BỘ. Bảng tiền tố sync_/local_ KHÔNG đồng bộ.

PRAGMA foreign_keys = OFF;

-- ===== Việc =====
CREATE TABLE area (                 -- danh mục việc: Công việc, Sức khỏe, Nhà…
  id          TEXT PRIMARY KEY NOT NULL,
  name        TEXT NOT NULL,
  icon        TEXT NOT NULL DEFAULT 'circle',
  color       TEXT NOT NULL DEFAULT 'dataSlate',   -- tên token data-*
  sort_key    TEXT NOT NULL DEFAULT 'm',            -- fractional index (SPEC-sync §3.4)
  archived_at INTEGER,
  created_at  INTEGER NOT NULL,
  updated_at  INTEGER NOT NULL,
  deleted_at  INTEGER
);

CREATE TABLE task (
  id           TEXT PRIMARY KEY NOT NULL,
  title        TEXT NOT NULL,
  notes        TEXT NOT NULL DEFAULT '',
  area_id      TEXT,                                -- NULL = không danh mục
  due_on       TEXT,                                -- 'YYYY-MM-DD' hoặc NULL
  priority     INTEGER NOT NULL DEFAULT 0,          -- 0 không, 1 thấp, 2 vừa, 3 cao
  status       TEXT NOT NULL DEFAULT 'open',        -- 'open' | 'done'
  completed_at INTEGER,
  inbox        INTEGER NOT NULL DEFAULT 0,          -- 1 = chưa xếp (từ Ghi nhanh, không ngày, không danh mục)
  sort_key     TEXT NOT NULL DEFAULT 'm',
  source       TEXT NOT NULL DEFAULT 'manual',      -- 'manual' | 'capture'
  project_id   TEXT,                                -- mở đường GĐ2, MVP luôn NULL
  goal_id      TEXT,                                -- mở đường GĐ2, MVP luôn NULL
  created_at   INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL,
  deleted_at   INTEGER
);
CREATE INDEX task_open_due ON task(status, due_on) WHERE deleted_at IS NULL;
CREATE INDEX task_inbox    ON task(inbox) WHERE deleted_at IS NULL AND status = 'open';

-- ===== Thói quen =====
CREATE TABLE habit (
  id           TEXT PRIMARY KEY NOT NULL,
  name         TEXT NOT NULL,
  icon         TEXT NOT NULL DEFAULT 'checkmark',
  color        TEXT NOT NULL DEFAULT 'dataGreen',
  weekdays     INTEGER NOT NULL DEFAULT 127,        -- bitmask T2=1, T3=2, … CN=64; 127 = mỗi ngày
  target_count INTEGER NOT NULL DEFAULT 1,          -- [Mở rộng] "8 ly"
  reminder_at  TEXT,                                -- 'HH:mm' [Mở rộng]
  sort_key     TEXT NOT NULL DEFAULT 'm',
  goal_id      TEXT,
  archived_at  INTEGER,
  created_at   INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL,
  deleted_at   INTEGER
);

CREATE TABLE habit_log (              -- id = UUIDv5('habit_log:<habit_id>:<day>') (ADR-0014)
  id         TEXT PRIMARY KEY NOT NULL,
  habit_id   TEXT NOT NULL,
  day        TEXT NOT NULL,                          -- 'YYYY-MM-DD'
  count      INTEGER NOT NULL DEFAULT 1,
  status     TEXT NOT NULL DEFAULT 'done',           -- 'done' | 'rest' [Mở rộng]
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER                                 -- bỏ tick = đặt deleted_at
);
CREATE INDEX habit_log_by_habit_day ON habit_log(habit_id, day) WHERE deleted_at IS NULL;

-- ===== Nhật ký và tâm trạng =====
CREATE TABLE journal_entry (          -- một mục mỗi ngày; id = UUIDv5('journal_entry:<day>')
  id          TEXT PRIMARY KEY NOT NULL,
  day         TEXT NOT NULL,
  mood        INTEGER,                               -- 1..5 hoặc NULL
  energy      INTEGER,                               -- 1..5 hoặc NULL
  body_sealed BLOB,                                  -- nội dung đã mã hoá mức trường (SPEC-crypto §5); NULL = trống
  created_at  INTEGER NOT NULL,
  updated_at  INTEGER NOT NULL,
  deleted_at  INTEGER
);
CREATE INDEX journal_by_day ON journal_entry(day) WHERE deleted_at IS NULL;

CREATE TABLE journal_conflict (       -- bản thua khi hai máy cùng sửa (ADR-0012); id = UUIDv5('journal_conflict:<entry_id>:<loser_hlc>')
  id          TEXT PRIMARY KEY NOT NULL,
  entry_id    TEXT NOT NULL,
  body_sealed BLOB NOT NULL,
  loser_hlc   TEXT NOT NULL,
  created_at  INTEGER NOT NULL,
  updated_at  INTEGER NOT NULL,
  deleted_at  INTEGER                                -- "Bỏ bản này" = đặt deleted_at
);

-- ===== Thu chi =====
CREATE TABLE category (
  id          TEXT PRIMARY KEY NOT NULL,
  kind        TEXT NOT NULL,                         -- 'expense' | 'income'
  name        TEXT NOT NULL,
  icon        TEXT NOT NULL DEFAULT 'tag',
  color       TEXT NOT NULL DEFAULT 'dataSlate',
  keywords    TEXT NOT NULL DEFAULT '[]',            -- JSON mảng chuỗi, cho Ghi nhanh đoán danh mục
  is_fallback INTEGER NOT NULL DEFAULT 0,            -- 1 = "Khác" của loại đó
  sort_key    TEXT NOT NULL DEFAULT 'm',
  archived_at INTEGER,
  created_at  INTEGER NOT NULL,
  updated_at  INTEGER NOT NULL,
  deleted_at  INTEGER
);

CREATE TABLE txn (                    -- "transaction" là từ khoá SQL nên đặt tên txn
  id           TEXT PRIMARY KEY NOT NULL,
  kind         TEXT NOT NULL,                        -- 'expense' | 'income'
  amount       INTEGER NOT NULL,                     -- > 0, đơn vị nhỏ nhất (VND: đồng)
  currency     TEXT NOT NULL DEFAULT 'VND',
  category_id  TEXT,
  note         TEXT NOT NULL DEFAULT '',
  occurred_on  TEXT NOT NULL,                        -- 'YYYY-MM-DD'
  source       TEXT NOT NULL DEFAULT 'manual',
  recurring_id TEXT,                                 -- [Mở rộng] khoản định kỳ
  project_id   TEXT,
  goal_id      TEXT,
  created_at   INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL,
  deleted_at   INTEGER
);
CREATE INDEX txn_by_day ON txn(occurred_on) WHERE deleted_at IS NULL;
CREATE INDEX txn_by_cat ON txn(category_id, occurred_on) WHERE deleted_at IS NULL;

CREATE TABLE budget (                 -- id = UUIDv5('budget:<YYYY-MM>:<category_id|total>')
  id          TEXT PRIMARY KEY NOT NULL,
  month       TEXT NOT NULL,                         -- 'YYYY-MM'
  category_id TEXT,                                  -- NULL = tổng tháng
  amount      INTEGER NOT NULL,
  created_at  INTEGER NOT NULL,
  updated_at  INTEGER NOT NULL,
  deleted_at  INTEGER
);

-- ===== Review tuần =====
CREATE TABLE weekly_review (          -- id = UUIDv5('weekly_review:<week_start>')
  id           TEXT PRIMARY KEY NOT NULL,
  week_start   TEXT NOT NULL,                        -- thứ Hai 'YYYY-MM-DD'
  rating       INTEGER,                              -- 1..5
  answers      TEXT NOT NULL DEFAULT '{}',           -- JSON {went_well, hard, learned}
  focus        TEXT NOT NULL DEFAULT '[]',           -- JSON mảng tối đa 3 chuỗi
  completed_at INTEGER,
  created_at   INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL,
  deleted_at   INTEGER
);

-- ===== Cài đặt đồng bộ =====
CREATE TABLE setting (                -- id = UUIDv5('setting:<key>')
  id         TEXT PRIMARY KEY NOT NULL,
  key        TEXT NOT NULL,                          -- 'display_name', 'theme', 'today_cards', 'reminders'…
  value      TEXT NOT NULL,                          -- JSON
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER
);

-- ===== Nội bộ, KHÔNG đồng bộ =====
CREATE TABLE sync_field_clock (       -- HLC của từng trường (SPEC-sync §4)
  tbl    TEXT NOT NULL,
  row_id TEXT NOT NULL,
  col    TEXT NOT NULL,
  hlc    TEXT NOT NULL,
  base   TEXT,                                       -- chỉ cho trường keepBoth
  PRIMARY KEY (tbl, row_id, col)
) WITHOUT ROWID;

CREATE TABLE sync_outbox (            -- hàng cần gửi
  tbl         TEXT NOT NULL,
  row_id      TEXT NOT NULL,
  enqueued_at TEXT NOT NULL,                         -- HLC lúc xếp hàng; gửi xong chỉ xoá nếu không đổi
  PRIMARY KEY (tbl, row_id)
) WITHOUT ROWID;

CREATE TABLE sync_unknown (           -- bảng/cột từ phiên bản mới hơn: giữ nguyên, áp lại sau khi nâng cấp
  tbl            TEXT NOT NULL,
  row_id         TEXT NOT NULL,
  payload        TEXT NOT NULL,                      -- RowPayload JSON (đã giải mã)
  schema_version INTEGER NOT NULL,
  received_at    INTEGER NOT NULL,
  PRIMARY KEY (tbl, row_id)
) WITHOUT ROWID;

CREATE TABLE sync_state (             -- node_id, last_hlc, CKSyncEngine state serialization…
  key   TEXT PRIMARY KEY NOT NULL,
  value BLOB NOT NULL
) WITHOUT ROWID;

CREATE TABLE local_setting (          -- riêng từng máy: app_lock, primary_reminder_device, onboarding_step
  key   TEXT PRIMARY KEY NOT NULL,
  value TEXT NOT NULL
) WITHOUT ROWID;
