---
id: LOS-012
title: "SyncCore: Hybrid Logical Clock"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:feature, area:sync, agent-ok]
depends_on: [LOS-010]
size: S
---

## Mục tiêu
HLC đúng SPEC-sync §2, qua mọi vector.

## Việc cần làm
- [ ] HLCTimestamp (parse/format 46 ký tự, so sánh chuỗi)
- [ ] HybridLogicalClock tick/receive, ClockDrift không chặn, DuplicateNode, CounterOverflow
- [ ] Lưu trạng thái qua protocol (Persistence cài)

## Tiêu chí nghiệm thu
- [ ] TestVectors/hlc/* xanh (TC-SYNC-00)

## Tham chiếu
- SPEC-sync §2
- ADR-0004

## Phụ thuộc
LOS-010
