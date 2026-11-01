---
id: LOS-021
title: "Spike: SQLiteData @FetchAll không cần SyncEngine"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:spike, area:persistence]
depends_on: [LOS-020]
size: S
---

## Mục tiêu
Trả lời decisions-open D2 bằng số đo.

## Việc cần làm
- [ ] Dựng một màn danh sách việc bằng @FetchAll và bằng ValueObservation
- [ ] Đo: body updates, thời gian khung đầu, dung lượng binary thêm

## Tiêu chí nghiệm thu
- [ ] Ghi kết quả + đề xuất vào D2; viết ADR nếu đổi

## Tham chiếu
- ADR-0003
- ADR-0007

## Phụ thuộc
LOS-020
