---
id: LOS-031
title: "SyncCoordinator, RowPayloadCodec, FakeTransport"
milestone: "M4 Đồng bộ iCloud"
labels: [type:feature, area:sync, agent-ok]
depends_on: [LOS-023, LOS-013]
size: L
---

## Mục tiêu
Toàn bộ logic đồng bộ chạy được với transport giả.

## Việc cần làm
- [ ] SyncTransport protocol + TransportEvent
- [ ] RowPayloadCodec: JSON canonical (SPEC-sync §4.2)
- [ ] SyncCoordinator actor: gửi theo lô, nhận, merge, ghi cùng transaction với state
- [ ] SyncStatus

## Tiêu chí nghiệm thu
- [ ] TC-SYNC-05..09, 13 xanh

## Tham chiếu
- SPEC-sync §4, §7, §8

## Phụ thuộc
LOS-023, LOS-013
