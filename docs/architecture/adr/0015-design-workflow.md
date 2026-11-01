# ADR-0015: Repo là nguồn sự thật cho thiết kế; Claude dùng để khám phá

- Trạng thái: Đề xuất (decisions-open D1)
- Liên quan: docs/design/design-workflow.md, ADR-0009

## Bối cảnh
Thiết kế hiện nằm ở ba nơi: artifact Library + Screens trên claude.ai, gói Swift `LifeOSDesignSystem`, `tokens.json`. Claude Design bản riêng (claude.ai/design) đóng ngày 14/12/2026; tính năng thiết kế nay nằm trong Claude (loại artifact **Design** và **Design System**).

## Quyết định (đề xuất)
1. **Nguồn sự thật = repo**: `design/tokens/tokens.json` + `Packages/LifeOSDesignSystem` + `docs/product` (luồng, câu chữ).
2. **Bản tham chiếu nhìn được** (Screens, Library) xuất thành HTML trong `design/reference/`, có ngày; artifact trên claude.ai là bản để xem/bình luận, không phải nguồn.
3. **Màn mới** thiết kế trong Claude bằng artifact loại Design, dùng một artifact **Design System** dựng từ tokens.json làm hệ mặc định → duyệt → chép HTML vào `design/reference/` + ghi spec màn (trạng thái, dữ liệu, câu chữ) vào `docs/design/screens/<man>.md` → mới code.
4. Code SwiftUI không "chuyển từ HTML": agent đọc spec màn + ảnh/HTML tham chiếu + component có sẵn trong DesignSystem.
