# ADR-0009: Token design một nguồn, sinh code lúc build

- Trạng thái: Chấp nhận
- Liên quan: design/README.md, ADR-0015

## Quyết định
`design/tokens/tokens.json` (v2) là nguồn duy nhất. `design/tokens/generate.py` sinh 30 colorset (Light/Dark/Increase Contrast), `Tokens.swift`, `tokens.css`. Không sửa tay file sinh ra. CI chạy `generate.py --check`. Component chỉ đọc hằng token (`static let`), không màu/khoảng cách viết cứng (trừ kích thước riêng đã ghi trong HANDOFF).

## Hệ quả
- Đổi màu = sửa tokens.json + chạy generate + commit cả file sinh ra trong một PR.
- Android/web sau này thêm bộ sinh cho Compose/CSS từ cùng file.
