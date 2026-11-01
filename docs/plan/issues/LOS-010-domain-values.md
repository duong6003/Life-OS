---
id: LOS-010
title: "Domain: LocalDate, LocalMonth, Money, EntityID, UUIDv7/v5"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:feature, area:core, agent-ok]
depends_on: [LOS-002]
size: S
---

## Mục tiêu
Kiểu giá trị nền cho mọi module, đúng ADR-0013/0014.

## Việc cần làm
- [ ] LocalDate (YYYY-MM-DD, cộng ngày, thứ, đầu tuần thứ Hai)
- [ ] LocalMonth
- [ ] Money (Int64, VND)
- [ ] EntityID<T>
- [ ] UUIDv7 và UUIDv5(NS_LIFEOS)

## Tiêu chí nghiệm thu
- [ ] Vector merge/ids.json xanh
- [ ] TC-REV-01, TC-GEN-02 (phần ngày) xanh

## Tham chiếu
- ADR-0013
- ADR-0014
- SPEC-sync §3

## Phụ thuộc
LOS-002
