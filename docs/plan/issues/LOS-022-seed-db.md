---
id: LOS-022
title: "Sinh DB seed 3 năm để đo hiệu năng"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:chore, area:persistence, perf, agent-ok]
depends_on: [LOS-020]
size: S
---

## Mục tiêu
reference/seed.py sinh SQLite đúng schema với lượng dữ liệu thật.

## Việc cần làm
- [ ] 6 thói quen × 1.095 ngày, ~4.000 việc, ~3.600 giao dịch, 1.000 nhật ký (body giả đã mã hoá bằng khoá test)
- [ ] Seed cố định, chạy < 30 giây

## Tiêu chí nghiệm thu
- [ ] File seed/lifeos-3y.sqlite (không commit) dùng được cho TC-PERF-*

## Tham chiếu
- data-model.md §5

## Phụ thuộc
LOS-020
