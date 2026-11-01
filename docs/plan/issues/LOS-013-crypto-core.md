---
id: LOS-013
title: "CryptoCore: envelope, dẫn khoá, mã khôi phục"
milestone: "M6 Sau MVP"
labels: [type:feature, area:crypto, agent-ok]
depends_on: [LOS-010, LOS-006]
size: M
---

## Mục tiêu
Định dạng LOS1 và cây khoá viết một lần, độc lập CryptoKit.

## Việc cần làm
- [ ] protocol CryptoProvider (aeadSeal/open, hkdf, hmac, random)
- [ ] EnvelopeCodec (parse header, AAD)
- [ ] KeyDerivation (kid, K_row, K_field, K_name, KEK, rkid)
- [ ] RecoveryCode.generate(from random bytes) — rejection sampling
- [ ] Kiểu `Envelope` riêng (không phải Data) để transport không nhận bản rõ (threat T10)

## Tiêu chí nghiệm thu
- [ ] Test định dạng với FakeProvider trên Linux
- [ ] Vector chạy thật ở LOS-050 (CryptoKit)

## Tham chiếu
- SPEC-crypto
- ADR-0006

## Phụ thuộc
LOS-010, LOS-006
