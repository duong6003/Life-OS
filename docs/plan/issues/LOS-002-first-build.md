---
id: LOS-002
title: "Build lần đầu các gói Swift và sửa lỗi biên dịch"
milestone: "M0 Nền móng"
labels: [type:chore, area:core, area:design, agent-ok]
depends_on: [LOS-001]
size: M
---

## Mục tiêu
Mọi gói trong Packages/ build được bằng Xcode 26.x; LifeOSCore `swift test` xanh (kể cả trên Linux).

## Việc cần làm
- [ ] `cd Packages/LifeOSCore && swift build && swift test`
- [ ] Mở Packages/LifeOSDesignSystem trong Xcode, build iOS + macOS, sửa API lệch (lineHeight(.multiple), glassEffect, tabViewBottomAccessory, tabBarMinimizeBehavior, @Entry)
- [ ] Ghim GRDB trong Package.resolved, commit
- [ ] Ghi các API phải sửa vào HANDOFF.md §5c

## Tiêu chí nghiệm thu
- [ ] 0 lỗi, 0 cảnh báo mới
- [ ] Catalog.swift preview chạy Light/Dark
- [ ] Package.resolved có trong git

## Tham chiếu
- ADR-0008
- design/HANDOFF.md

## Phụ thuộc
LOS-001
