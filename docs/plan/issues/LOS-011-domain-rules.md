---
id: LOS-011
title: "Domain: entity và business rule thuần"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:feature, area:core, agent-ok]
depends_on: [LOS-010]
size: M
---

## Mục tiêu
Mọi quy tắc tính toán thuần nằm trong Domain/Rules, có test theo BR.

## Việc cần làm
- [ ] Entity struct cho mọi bảng MVP
- [ ] Streak (BR-HAB-01, 04)
- [ ] TaskGrouping (BR-TSK-02, 06, 08)
- [ ] BudgetStatus (BR-SPD-04, 05)
- [ ] WeekSummary (BR-REV-02)
- [ ] Định dạng BR-GEN-04 (port format.ts)

## Tiêu chí nghiệm thu
- [ ] TC-HAB-01, 03; TC-TSK-02, 06; TC-SPD-04, 05; TC-GEN-04 xanh

## Tham chiếu
- docs/product/business-rules.md
- design/reference/code/format.ts

## Phụ thuộc
LOS-010
