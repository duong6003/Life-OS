---
id: LOS-021
title: "Spike: xác minh SQLiteData cho Life OS"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:spike, area:persistence, perf]
depends_on: [LOS-002]
size: M
---
## Mục tiêu
Xác nhận bằng tài liệu gốc và số đo rằng SQLiteData hợp với Life OS trước khi dựng lưu trữ trên nó (ADR-0016).

## Việc cần làm
- [ ] Đọc `CloudKit.md` và `CloudKitSharing.md` trong repo sqlite-data (bản đang ghim). Đối chiếu từng luật với header của `schema/0001_initial.sql`: khoá chính, UNIQUE, `NOT NULL ON CONFLICT REPLACE`, khoá ngoại, tên cột dành riêng, migration chỉ thêm. Có chỗ lệch thì sửa schema trong spike này, vì schema chưa phát hành
- [ ] Ghi lại cách hợp nhất thật sự (theo trường hay theo bản ghi, xử lý xoá) vào ADR-0016 §Hệ quả
- [ ] Kiểm phiên bản Swift tools mà sqlite-data yêu cầu so với Xcode đang dùng
- [ ] Dựng thử một màn danh sách việc: repository theo dõi bằng cơ chế của SQLiteData/GRDB, Store nhận snapshot
- [ ] Đo dung lượng binary tăng thêm (TC-PERF-08), thời gian mở DB, RAM

## Tiêu chí nghiệm thu
- [ ] Bảng đối chiếu luật ↔ schema trong issue; schema sửa xong nếu cần
- [ ] Binary tăng ≤ 3 MB; nếu vượt thì quay lại ADR-0016
- [ ] TC-SYNC-15 viết sẵn (có thể chưa chạy được SyncEngine thật)

## Tham chiếu
- ADR-0016
- docs/architecture/data-model.md

## Phụ thuộc
LOS-002
