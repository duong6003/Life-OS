---
id: LOS-004
title: "CI Linux cho lõi xanh"
milestone: "M0 Nền móng"
labels: [type:chore, area:ci, agent-ok]
depends_on: [LOS-002]
size: S
---

## Mục tiêu
Mỗi PR chạy job `checks` (ranh giới module, schema, token, vector, plan) và `core-swift` (swift test trên Linux).

## Việc cần làm
- [ ] Sửa `.github/workflows/core.yml` nếu cần (phiên bản Swift image)
- [ ] Đảm bảo job < 5 phút

## Tiêu chí nghiệm thu
- [ ] PR mẫu cố ý `import CloudKit` trong Domain bị đỏ
- [ ] Badge CI trong README

## Tham chiếu
- ADR-0011

## Phụ thuộc
LOS-002
