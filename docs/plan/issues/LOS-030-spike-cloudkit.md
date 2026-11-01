---
id: LOS-030
title: "Spike: CKSyncEngine với payload mã hoá"
milestone: "M4 Đồng bộ iCloud"
labels: [type:spike, area:sync, perf]
depends_on: [LOS-003, LOS-050]
size: M
---

## Mục tiêu
Chọn cách đóng gói bản ghi bằng số đo (ADR-0005).

## Việc cần làm
- [ ] Prototype row-state và changeset với 5.000 hàng
- [ ] Đo pin (Energy), RAM, dung lượng iCloud, độ trễ trên 2 thiết bị

## Tiêu chí nghiệm thu
- [ ] Kết quả trong issue + ADR thay thế nếu đổi; TC-PERF-09

## Tham chiếu
- ADR-0005
- SPEC-sync §7

## Phụ thuộc
LOS-003, LOS-050
