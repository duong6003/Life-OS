# AGENTS.md — LifeOSData
Luật riêng của gói, bổ sung cho AGENTS.md ở gốc repo.
Lưu trữ và đồng bộ cho MVP trên SQLiteData + GRDB (ADR-0016). Chỉ Apple; không cần chạy Linux.
- `Persistence`: AppDatabase, migration chạy `Migrations/sql/*.sql` (giống hệt `schema/*.sql`, CI kiểm), bảng `@Table`, repository, query trả snapshot.
- `CloudSync`: nơi DUY NHẤT nhắc tới `SyncEngine`. Thêm bảng đồng bộ = sửa `SyncTables` + data-model.md + TC-SYNC-15.
- Đây là **adapter**: cài đặt port của `Domain/Ports` (ADR-0017). Protocol và snapshot không đặt ở đây. Feature không import gói này; không dùng `@FetchAll` trong View (ADR-0016 ranh giới 3).
- Một `DatabasePool` duy nhất (AppDatabase); migration không sửa sau khi phát hành (references.md S-GRDB-CONC, S-GRDB-MIG). Công thức: recipes.md R4–R6.
- Schema theo luật của SyncEngine (header của schema/0001_initial.sql). Migration chỉ thêm.
- Chỉ `defaultDatabase`/`defaultSyncEngine` đi qua `prepareDependencies`; còn lại tiêm qua init (ADR-0007).
