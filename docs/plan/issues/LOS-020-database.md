---
id: LOS-020
title: "Persistence: AppDatabase và migration đầu"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:feature, area:persistence, agent-ok]
depends_on: [LOS-011, LOS-012]
size: M
---

## Mục tiêu
Mở DB nhanh, đúng ADR-0003, chạy schema/0001_initial.sql.

## Việc cần làm
- [ ] DatabaseFactory: DatabasePool, WAL, App Group, Data Protection class C, pragmas
- [ ] M0001 chạy file SQL dùng chung
- [ ] Dữ liệu mẫu ID v5 `seed:` (data-model §4)
- [ ] DB hỏng → lỗi có kiểu, không crash (BR-GEN-05)

## Tiêu chí nghiệm thu
- [ ] TC-GEN-03, TC-TSK-01 xanh
- [ ] Mở DB rỗng < 20 ms

## Tham chiếu
- ADR-0003
- docs/architecture/data-model.md

## Phụ thuộc
LOS-011, LOS-012
