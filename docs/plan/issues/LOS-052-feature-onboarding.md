---
id: LOS-052
title: "Bắt đầu: chào mừng, iCloud, máy mới"
milestone: "M3 Bắt đầu"
labels: [type:feature, area:ui, mod:onboarding, agent-ok]
depends_on: [LOS-035]
size: S
---
## Mục tiêu
Luồng lần đầu, máy mới, chưa bật iCloud, lỗi dữ liệu. Không có mã khôi phục trong MVP (ADR-0016).

## Việc cần làm
- [ ] Viết docs/design/screens/onboarding.md (bỏ các bước mã khôi phục của design cũ, giữ để sau MVP)
- [ ] Welcome: câu nói đúng mức bảo vệ (BR-ONB-10)
- [ ] Kiểm iCloud: bật → tạo dữ liệu mẫu ID v5; tắt → dùng trong máy với badge (BR-ONB-07)

## Tiêu chí nghiệm thu
- [ ] TC-ONB-05, 07 xanh

## Tham chiếu
- BR-ONB-*
- system-design.md §8

## Phụ thuộc
LOS-035
