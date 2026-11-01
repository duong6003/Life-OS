---
id: LOS-024
title: "Repository và Query cho MVP"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:feature, area:persistence, agent-ok]
depends_on: [LOS-023, LOS-011]
size: L
---

## Mục tiêu
API dữ liệu cho mọi màn MVP, trả snapshot đã định hình.

## Việc cần làm
- [ ] Task, Area, Habit, HabitLog, JournalEntry, Category, Txn, Budget, WeeklyReview, Setting
- [ ] Query: Today, TaskGroups, HabitList+Heatmap, MonthSpending (gộp bằng SQL), WeekSummary
- [ ] observe*() bằng ValueObservation (.immediate)
- [ ] EXPLAIN QUERY PLAN test (TC-PERF-10)

## Tiêu chí nghiệm thu
- [ ] TC-TSK-02/06, TC-HAB-02/05, TC-SPD-06, TC-REV-02, TC-JRN-01 xanh

## Tham chiếu
- docs/architecture/system-design.md §5

## Phụ thuộc
LOS-023, LOS-011
