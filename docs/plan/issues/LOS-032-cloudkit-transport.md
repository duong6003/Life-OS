---
id: LOS-032
title: "CloudKitSyncTransport và KeyBundle"
milestone: "M6 Sau MVP"
labels: [type:feature, area:sync, area:crypto]
depends_on: [LOS-031, LOS-051]
size: L
---

## Mục tiêu
Đồng bộ thật qua iCloud, chặn hai khoá chủ.

## Việc cần làm
- [ ] CKSyncEngine delegate, zone LifeOS, recordName HMAC
- [ ] KeyBundle tải lên 'chỉ nếu chưa có', luồng máy thua
- [ ] Xử lý serverRecordChanged, quota, tài khoản đổi

## Tiêu chí nghiệm thu
- [ ] TC-CRY-05, TC-SYNC-12 xanh

## Tham chiếu
- SPEC-sync §7
- SPEC-crypto §6

## Phụ thuộc
LOS-031, LOS-051
