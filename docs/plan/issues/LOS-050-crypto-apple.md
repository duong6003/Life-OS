---
id: LOS-050
title: "CryptoApple: CryptoKitProvider và Keychain"
milestone: "M1 Lõi dữ liệu cục bộ"
labels: [type:feature, area:crypto, agent-ok]
depends_on: [LOS-013, LOS-003]
size: S
---

## Mục tiêu
Cài CryptoProvider bằng CryptoKit, qua vector byte-chính-xác.

## Việc cần làm
- [ ] CryptoKitProvider (ChaChaPoly với nonce cho trước trong test)
- [ ] KeychainStore (synchronizable, AfterFirstUnlock)

## Tiêu chí nghiệm thu
- [ ] TC-CRY-00, 01, 02, 04 xanh trên macOS

## Tham chiếu
- SPEC-crypto §1–5

## Phụ thuộc
LOS-013, LOS-003
