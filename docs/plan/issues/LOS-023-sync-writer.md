---
id: LOS-023
title: "SyncWriter, field clock, outbox, schema registry"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:feature, area:persistence, area:sync, agent-ok]
depends_on: [LOS-020, LOS-014]
size: M
---

## Mục tiêu
Mọi ghi bảng đồng bộ đi qua một đường, trong một transaction.

## Việc cần làm
- [ ] SyncWriter.write(table,id,changes) theo SPEC-sync §5 (kể cả base cho keepBoth)
- [ ] FieldClockStore, OutboxStore, sync_unknown
- [ ] SyncSchemaRegistry khớp TestVectors/merge/schema.json
- [ ] Trigger bẫy trong test để bắt đường ghi tắt

## Tiêu chí nghiệm thu
- [ ] TC-SYNC-01, 02, 03, 10 xanh

## Tham chiếu
- SPEC-sync §4–5

## Phụ thuộc
LOS-020, LOS-014
