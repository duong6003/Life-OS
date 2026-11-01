---
id: LOS-003
title: "Tạo App/LifeOS.xcodeproj đa nền tảng"
milestone: "M0 Nền móng"
labels: [type:chore, area:ci]
depends_on: [LOS-002]
size: S
---

## Mục tiêu
Một target app iOS + iPadOS + macOS mỏng, gắn 4 gói local.

## Việc cần làm
- [ ] Xcode → New Project → Multiplatform App, tên LifeOS, lưu vào App/
- [ ] Deployment iOS 26.0 / macOS 26.0 (ADR-0010)
- [ ] Thêm 4 local package, link AppFeature
- [ ] Capabilities: iCloud (CloudKit, container iCloud.<bundle-id>), App Groups (group.<bundle-id>), Keychain Sharing, Background Modes (remote notifications, processing)
- [ ] LifeOSApp.swift chỉ gọi AppEnvironment.live() + RootView
- [ ] Bật Swift 6 language mode, strict concurrency complete

## Tiêu chí nghiệm thu
- [ ] Chạy được trên iPhone simulator, iPad, Mac (màn trống)
- [ ] Không có code tính năng trong App/

## Tham chiếu
- docs/architecture/module-structure.md §1

## Phụ thuộc
LOS-002
