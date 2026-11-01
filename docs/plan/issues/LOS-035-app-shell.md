---
id: LOS-035
title: "Khung app: AppEnvironment, điều hướng, FeatureSupport"
milestone: "M2 MVP cục bộ"
labels: [type:feature, area:ui, agent-ok]
depends_on: [LOS-003, LOS-024]
size: M
---

## Mục tiêu
Vỏ app chạy trên iPhone/iPad/Mac với 5 tab / sidebar và dịch vụ dùng chung.

## Việc cần làm
- [ ] AppEnvironment.live()/.preview
- [ ] RootView: TabView (iPhone) / NavigationSplitView (iPad, Mac), menu Đi tới ⌘1–⌘6, ⌘N, ⌘,
- [ ] FormatterCache, UndoCoordinator + UndoToast, ScreenState
- [ ] Signpost today.firstFrame

## Tiêu chí nghiệm thu
- [ ] TC-DEV-01..03 (khung)
- [ ] Khởi động lạnh tới màn trống ≤ 300 ms

## Tham chiếu
- ADR-0007
- system-design.md §2–4

## Phụ thuộc
LOS-003, LOS-024
