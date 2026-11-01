---
id: LOS-043
title: "Nhật ký và check-in tối"
milestone: "M2 MVP cục bộ"
labels: [type:feature, area:ui, mod:journal, agent-ok]
depends_on: [LOS-035, LOS-051]
size: M
---

## Mục tiêu
Check-in ≤ 30 giây; viết bài lưu tự động, mã hoá mức trường.

## Việc cần làm
- [ ] Viết docs/design/screens/journal.md
- [ ] CheckInSheet (MoodPicker, EnergyPicker, một dòng)
- [ ] JournalScreen, JournalEditor (TextEditor, debounce 800 ms)
- [ ] Giao diện giữ cả hai bản (dùng dữ liệu giả cho tới M4)

## Tiêu chí nghiệm thu
- [ ] TC-JRN-01..05 xanh

## Tham chiếu
- BR-JRN-*
- ADR-0012

## Phụ thuộc
LOS-035, LOS-051
