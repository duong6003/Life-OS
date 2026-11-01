# design/

Nguồn sự thật về thiết kế nằm **trong repo** (ADR-0015). Artifact trên claude.ai là bản để xem, bình luận và khám phá.

| Đường dẫn | Là gì | Ai sửa |
|---|---|---|
| `tokens/tokens.json` | Token v2: 30 màu (Light/Dark/Increase Contrast), chữ, khoảng cách, bố cục, bo góc, chất liệu, chuyển động, rung, icon | Sửa tay, rồi `python3 design/tokens/generate.py` |
| `tokens/generate.py` | Sinh colorset + `Tokens.swift` vào `Packages/LifeOSDesignSystem`, `tokens/build/tokens.css` | — |
| `tokens/hc.py`, `migrate.py` | Tính màu Increase Contrast; chuyển token v1 → v2 (chỉ khi đổi bảng màu gốc) | — |
| `HANDOFF.md` | Bàn giao design system Apple: checklist nghiệm thu, ánh xạ 38 component, phụ lục token/tương phản/[Mở rộng] | Cập nhật khi đổi thiết kế |
| `reference/screens.html` | 8 màn × iPhone/iPad/Mac, mọi trạng thái (bản sao artifact Screens v8, 01/11/2026). Mở bằng trình duyệt | Thay khi có bản mới |
| `reference/component-library.html` | Thư viện component (bản sao artifact Library v8) | Thay khi có bản mới |
| `reference/code/` | Code TS đã duyệt dùng làm tham chiếu hành vi (bộ hiểu Ghi nhanh, định dạng) | Chỉ đổi cùng spec |

Artifact gốc: [Life OS Design System](https://claude.ai/artifact/9vcZ4fYJXbfKTGXoFgAfuM) · [Life OS Screens](https://claude.ai/artifact/U3Up5N6sL3U7WVyB2ZYjMD).

Cách làm việc đầy đủ: [`docs/design/design-workflow.md`](../docs/design/design-workflow.md).
