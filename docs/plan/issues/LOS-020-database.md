---
id: LOS-020
title: "Persistence: AppDatabase trên SQLiteData và migration đầu"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:feature, area:persistence, agent-ok]
depends_on: [LOS-011, LOS-021]
size: M
---
## Mục tiêu
Mở DB nhanh, đúng ADR-0003 và ADR-0016, chạy `schema/0001_initial.sql`.

## Việc cần làm
- [ ] AppDatabase: DatabasePool, WAL, App Group, Data Protection class C, pragmas; `attachMetadatabase()` trong `prepareDatabase` để SyncEngine dùng sau
- [ ] `prepareDependencies { $0.defaultDatabase = … }` gọi một lần ở composition root (AppFeature); các nơi khác nhận `AppDatabase` qua init
- [ ] M0001 chạy file SQL dùng chung trong `Migrations/sql`
- [ ] Bảng `@Table` cho mọi bảng MVP trong `Persistence/Tables`
- [ ] DB hỏng → lỗi có kiểu, không crash (BR-GEN-05)

## Tiêu chí nghiệm thu
- [ ] TC-GEN-03, TC-TSK-01 xanh
- [ ] Mở DB rỗng < 20 ms

## Tham chiếu
- ADR-0003
- ADR-0016
- docs/architecture/data-model.md

## Phụ thuộc
LOS-011, LOS-021
