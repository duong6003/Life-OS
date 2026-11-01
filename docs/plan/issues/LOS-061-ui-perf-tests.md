---
id: LOS-061
title: "UI test và test hiệu năng tự động"
milestone: "M5 Hoàn thiện và beta"
labels: [type:feature, area:ci, perf]
depends_on: [LOS-048, LOS-060]
size: M
---

## Mục tiêu
Chặn hồi quy hiệu năng mà agent có thể đưa vào.

## Việc cần làm
- [ ] XCUITest luồng chính
- [ ] XCTApplicationLaunchMetric, XCTOSSignpostMetric cuộn với DB seed
- [ ] performAccessibilityAudit

## Tiêu chí nghiệm thu
- [ ] Chạy trên PR nhãn `perf` và hằng đêm

## Tham chiếu
- nonfunctional.md

## Phụ thuộc
LOS-048, LOS-060
