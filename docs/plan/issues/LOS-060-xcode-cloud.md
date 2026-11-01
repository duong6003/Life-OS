---
id: LOS-060
title: "Xcode Cloud: build, test, TestFlight"
milestone: "M5 Hoàn thiện và beta"
labels: [type:chore, area:ci]
depends_on: [LOS-003]
size: S
---

## Mục tiêu
Mỗi PR build app + test; nhánh main đẩy TestFlight.

## Việc cần làm
- [ ] Workflow PR: build iOS/macOS + unit + store test
- [ ] Workflow main: archive → TestFlight nội bộ
- [ ] Bước post-build: `periphery scan` (strict) và `swiftlint analyze` (unused_import, unused_declaration)

## Tiêu chí nghiệm thu
- [ ] PR hiện check Xcode Cloud

## Tham chiếu
- ADR-0011

## Phụ thuộc
LOS-003
