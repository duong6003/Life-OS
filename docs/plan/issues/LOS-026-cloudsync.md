---
id: LOS-026
title: "CloudSync: bật SyncEngine cho mọi bảng MVP"
milestone: "M4 Đồng bộ iCloud"
labels: [type:feature, area:sync]
depends_on: [LOS-030, LOS-024]
size: M
---
## Mục tiêu
Đồng bộ iCloud chạy thật, toàn bộ nằm trong target `CloudSync` (ADR-0016 ranh giới 2).

## Việc cần làm
- [ ] `CloudSync.makeEngine`: `SyncEngine(for:tables:)` với mọi bảng trong `SyncTables`
- [ ] AppFeature gọi một lần sau khung hình đầu (BR-SYNC-04); `prepareDependencies { $0.defaultSyncEngine = … }` nếu SQLiteData cần
- [ ] `SyncStatusMonitor` (actor): đã đồng bộ, đang chờ, chưa đăng nhập iCloud, lỗi
- [ ] Xử lý đổi hoặc đăng xuất tài khoản iCloud: không xoá dữ liệu khi chưa hỏi người dùng

## Tiêu chí nghiệm thu
- [ ] TC-SYNC-08, 14, 15 xanh; `bash scripts/check-core-imports.sh` xanh

## Tham chiếu
- ADR-0016
- system-design.md §7

## Phụ thuộc
LOS-030, LOS-024
