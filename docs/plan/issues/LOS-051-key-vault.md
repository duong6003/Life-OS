---
id: LOS-051
title: "KeyVault: tạo kho, giữ MK, mã hoá trường"
milestone: "M6 Sau MVP"
labels: [type:feature, area:crypto, agent-ok]
depends_on: [LOS-050]
size: M
---

## Mục tiêu
Một nơi duy nhất biết MK; feature chỉ thấy seal/open trường.

## Việc cần làm
- [ ] actor KeyVault: createVault() → RecoveryCode, unlock(code), currentKeys
- [ ] FieldCipher cho journal body
- [ ] Không log khoá (TC-CRY-03)

## Tiêu chí nghiệm thu
- [ ] TC-CRY-03, TC-JRN-03 xanh

## Tham chiếu
- SPEC-crypto §5–6

## Phụ thuộc
LOS-050
