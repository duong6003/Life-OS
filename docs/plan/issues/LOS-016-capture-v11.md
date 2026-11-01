---
id: LOS-016
title: "Ghi nhanh v1.1: sửa 4 lỗi đã biết"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:bug, area:capture, needs-decision]
depends_on: [LOS-015]
size: S
---

## Mục tiêu
Sửa các lỗi ở SPEC-quick-capture §7 (cần bạn đồng ý, decisions-open D10).

## Việc cần làm
- [ ] Sửa design/reference/code/quick-capture.ts
- [ ] Cập nhật SPEC lên 1.1, chạy `python3 reference/run_all.py` để sinh lại vector
- [ ] Sửa Swift cho khớp

## Tiêu chí nghiệm thu
- [ ] Vector mới xanh ở cả TS và Swift

## Tham chiếu
- SPEC-quick-capture §7

## Phụ thuộc
LOS-015
