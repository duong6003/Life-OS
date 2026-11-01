---
id: LOS-033
title: "Harness đồng bộ tất định nhiều máy"
milestone: "M4 Đồng bộ iCloud"
labels: [type:feature, area:sync, agent-ok]
depends_on: [LOS-031]
size: M
---

## Mục tiêu
Bằng chứng hội tụ trước khi bật đồng bộ cho người dùng.

## Việc cần làm
- [ ] 3 Device ảo, FixedClock lệch ±10 phút, FakeTransport rớt/lặp/đảo thứ tự
- [ ] 10.000 vòng seed cố định trong CI Linux < 2 phút

## Tiêu chí nghiệm thu
- [ ] TC-SYNC-11 xanh

## Tham chiếu
- SPEC-sync §10

## Phụ thuộc
LOS-031
