---
id: LOS-025
title: "Cổng M1: lõi dữ liệu cục bộ"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:gate, perf]
depends_on: [LOS-022, LOS-024, LOS-015, LOS-013]
size: S
---

## Mục tiêu
Lõi đủ chắc để dựng UI.

## Việc cần làm
- [ ] Chạy mọi test core trên Linux + macOS
- [ ] Đo thời gian truy vấn mỗi màn trên DB seed

## Tiêu chí nghiệm thu
- [ ] Mọi truy vấn màn ≤ 10 ms trên Mac dev; ghi perf-log.md

## Tham chiếu
- performance-budget.md

## Phụ thuộc
LOS-022, LOS-024, LOS-015, LOS-013
