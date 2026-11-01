---
id: LOS-043
title: "Nhật ký và check-in tối"
milestone: "M2 MVP cục bộ"
labels: [type:feature, area:ui, mod:journal, agent-ok]
depends_on: [LOS-035]
size: M
---
## Mục tiêu
Check-in ≤ 30 giây; viết bài lưu tự động.

## Việc cần làm
- [ ] Viết docs/design/screens/journal.md
- [ ] CheckInSheet (MoodPicker, EnergyPicker, một dòng)
- [ ] JournalScreen, JournalEditor (TextEditor, debounce 800 ms)
- [ ] Danh sách chỉ đọc ngày + tâm trạng, nội dung chỉ tải khi mở bài (BR-JRN-04)

## Tiêu chí nghiệm thu
- [ ] TC-JRN-01, 02, 05 xanh

## Tham chiếu
- BR-JRN-*
- ADR-0016 (giữ cả hai bản để sau MVP)

## Phụ thuộc
LOS-035
