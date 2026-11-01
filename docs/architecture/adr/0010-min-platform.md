# ADR-0010: Nền tảng tối thiểu iOS 26 / iPadOS 26 / macOS 26

- Trạng thái: Đề xuất (decisions-open D3)

## Bối cảnh
Design system dùng Liquid Glass, `lineHeight(.multiple)`, `.tabViewBottomAccessory` (iOS 26). Tháng 10/2026 iOS 27 đã ra (WWDC26).

## Quyết định (đề xuất)
Deployment target iOS 26.0 / macOS 26.0, build bằng SDK mới nhất. API riêng iOS 27 bọc trong `if #available`.

## Hệ quả
- Không hỗ trợ iOS 18 trở xuống. Thiết bị cũ nhất để đo hiệu năng: máy cũ nhất chạy được iOS 26 mà bạn có.
