---
id: LOS-030
title: "Spike: SyncEngine trên 2 thiết bị thật"
milestone: "M4 Đồng bộ iCloud"
labels: [type:spike, area:sync, perf]
depends_on: [LOS-003, LOS-021]
size: M
---
## Mục tiêu
Biết SyncEngine của SQLiteData chạy thế nào với dữ liệu và thiết bị thật trước khi nối vào app.

## Việc cần làm
- [ ] Container iCloud, entitlements, schema CloudKit ở môi trường Development
- [ ] 5.000 hàng seed: đo pin (Energy), RAM, dung lượng iCloud, độ trễ trên 2 thiết bị (TC-PERF-09)
- [ ] Hành vi: máy lệch giờ (BR-SYNC-06), cột mới từ phiên bản app mới hơn (TC-SYNC-06), giết app giữa lô (TC-SYNC-13)
- [ ] SyncEngine có cho biết số thay đổi đang chờ không (cho badge BR-SYNC-01)?

## Tiêu chí nghiệm thu
- [ ] Kết quả ghi trong issue và perf-log.md; cập nhật ADR-0016 nếu có rủi ro mới

## Tham chiếu
- ADR-0016

## Phụ thuộc
LOS-003, LOS-021
