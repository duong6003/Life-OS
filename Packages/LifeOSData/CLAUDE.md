# LifeOSData
Lưu trữ và đồng bộ cho MVP trên SQLiteData + GRDB (ADR-0016). Chỉ Apple; không cần chạy Linux.
- `Persistence`: AppDatabase, migration chạy `Migrations/sql/*.sql` (giống hệt `schema/*.sql`, CI kiểm), bảng `@Table`, repository, query trả snapshot.
- `CloudSync`: nơi DUY NHẤT nhắc tới `SyncEngine`. Thêm bảng đồng bộ = sửa `SyncTables` + data-model.md + TC-SYNC-15.
- Feature đọc/ghi qua protocol repository, không dùng `@FetchAll` trong View (ADR-0016 ranh giới 3).
- Schema theo luật của SyncEngine (header của schema/0001_initial.sql). Migration chỉ thêm.
- Chỉ `defaultDatabase`/`defaultSyncEngine` đi qua `prepareDependencies`; còn lại tiêm qua init (ADR-0007).
