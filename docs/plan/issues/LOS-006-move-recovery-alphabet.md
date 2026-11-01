---
id: LOS-006
title: "Chuyển bảng ký tự mã khôi phục sang CryptoCore"
milestone: "M6 Sau MVP"
labels: [type:chore, area:crypto, agent-ok]
depends_on: [LOS-065]
size: S
---

## Mục tiêu
DesignSystem không chứa logic mã khôi phục; RecoveryKeyView nhận dữ liệu đã chuẩn hoá.

## Việc cần làm
- [ ] Thêm `RecoveryCode` (alphabet, normalize, invalidCharacters, format) vào CryptoCore
- [ ] RecoveryKeyView nhận `[String]` nhóm và closure kiểm
- [ ] Xoá RecoveryKeyAlphabet khỏi DesignSystem

## Tiêu chí nghiệm thu
- [ ] Vector recovery-code/normalize xanh
- [ ] DesignSystem không còn biết bảng ký tự

## Tham chiếu
- SPEC-crypto §3

## Phụ thuộc
LOS-065
