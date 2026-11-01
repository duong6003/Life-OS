---
id: LOS-014
title: "SyncCore: Merger thuần"
milestone: "M6 Sau MVP"
labels: [type:feature, area:sync, agent-ok]
depends_on: [LOS-012]
size: M
---

## Mục tiêu
Hợp nhất một hàng đúng SPEC-sync §6, qua mọi vector.

## Việc cần làm
- [ ] FieldState, RowState, MergePolicy (lww, keepBoth)
- [ ] merge(local, remote, localDirty) → (fields, conflicts, changed)
- [ ] Tombstone, cột/bảng lạ

## Tiêu chí nghiệm thu
- [ ] TestVectors/merge/cases.json xanh (TC-SYNC-04)

## Tham chiếu
- SPEC-sync §6
- ADR-0012

## Phụ thuộc
LOS-012
