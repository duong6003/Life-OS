---
id: LOS-024
title: "Repository và Query cho MVP"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:feature, area:persistence, agent-ok]
depends_on: [LOS-020, LOS-011]
size: L
---
## Mục tiêu
API dữ liệu cho mọi màn MVP, trả snapshot đã định hình. Feature chỉ thấy protocol (ADR-0016 ranh giới 3).

## Việc cần làm
- [ ] `protocol <Thing>Repository` + `SQLite<Thing>Repository`: Task, Area, Habit, HabitLog, JournalEntry, Category, Txn, Budget, WeeklyReview, Setting
- [ ] Ghi `updated_at`; xoá = đặt `deleted_at` (để Hoàn tác); ID v5 cho khoá tự nhiên (ADR-0014)
- [ ] Query: Today, TaskGroups, HabitList+Heatmap, MonthSpending (gộp bằng SQL), WeekSummary
- [ ] `observe*()` trả AsyncSequence snapshot, phát lần đầu ngay lập tức
- [ ] Repository giả trong TestSupport cho test store
- [ ] EXPLAIN QUERY PLAN test (TC-PERF-10)

## Tiêu chí nghiệm thu
- [ ] TC-TSK-02/06, TC-HAB-02/05, TC-SPD-06, TC-REV-02, TC-JRN-01 xanh

## Tham chiếu
- docs/architecture/system-design.md §5

## Phụ thuộc
LOS-020, LOS-011
