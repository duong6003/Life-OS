---
id: LOS-004
title: "CI Linux cho lõi xanh"
milestone: "M0 Nền móng"
labels: [type:chore, area:ci, agent-ok]
depends_on: [LOS-002]
size: S
---

## Mục tiêu
Mỗi PR chạy job `checks` (ranh giới module, schema, token, vector, plan), `lint` (SwiftLint) và `core-swift` (swift test trên Linux).

## Việc cần làm
- [ ] Sửa `.github/workflows/core.yml` nếu cần (phiên bản Swift image)
- [ ] `brew install swiftlint periphery lefthook && lefthook install`; chạy `swiftlint lint --strict` và sửa hết lỗi ở code có sẵn (không hạ luật)
- [ ] Đảm bảo job < 5 phút

## Tiêu chí nghiệm thu
- [ ] PR mẫu cố ý `import CloudKit` trong Domain bị đỏ; PR mẫu có `AnyView` bị job `lint` chặn
- [ ] Badge CI trong README

## Tham chiếu
- ADR-0011
- docs/engineering/code-quality.md

## Phụ thuộc
LOS-002
