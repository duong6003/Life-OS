---
id: LOS-015
title: "Capture: port bộ hiểu Ghi nhanh v1 sang Swift"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:feature, area:capture, agent-ok]
depends_on: [LOS-010]
size: S
---

## Mục tiêu
Bộ hiểu Swift cho kết quả y hệt bản TypeScript đã duyệt.

## Việc cần làm
- [ ] VietnameseText.fold (bỏ dấu)
- [ ] AmountParser, DateTokenParser, CategoryGuesser, QuickCaptureParser, amountHint
- [ ] Signpost `capture.parse`

## Tiêu chí nghiệm thu
- [ ] 100% TestVectors/quick-capture/cases.json (TC-CAP-00)
- [ ] < 1 ms cho chuỗi 200 ký tự

## Tham chiếu
- SPEC-quick-capture

## Phụ thuộc
LOS-010
