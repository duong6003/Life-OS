---
id: LOS-062
title: "Đối chiếu test case với test"
milestone: "M5 Hoàn thiện và beta"
labels: [type:chore, area:ci, agent-ok]
depends_on: [LOS-061]
size: S
---

## Mục tiêu
Biết TC nào chưa có test.

## Việc cần làm
- [ ] scripts/tc_coverage.py: grep `test_TC_` so với docs/test-cases
- [ ] Thêm vào CI (cảnh báo, không chặn)

## Tiêu chí nghiệm thu
- [ ] Danh sách TC thiếu = 0 với mức U/I/S

## Tham chiếu
- docs/test-cases/README.md

## Phụ thuộc
LOS-061
