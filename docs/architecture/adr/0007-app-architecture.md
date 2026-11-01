# ADR-0007: Store @Observable, không TCA, tiêm phụ thuộc qua init

- Trạng thái: Chấp nhận; sửa đổi bởi ADR-0016 (defaultDatabase/defaultSyncEngine qua prepareDependencies)
- Liên quan: module-structure.md, conventions.md §4

## Bối cảnh
`@Observable` chỉ vẽ lại view đọc đúng thuộc tính đổi. TCA có chi phí mỗi action và reducer trên main; TCA 2.0 còn beta. Bề mặt API nhỏ thì agent ít sai hơn.

## Quyết định
- Mỗi màn có một **Store** `@Observable @MainActor final class`, giữ **snapshot giá trị** (struct `Sendable`) đã định hình sẵn cho UI. View không truy vấn DB, không định dạng số/ngày trong `body`.
- Store nhận phụ thuộc qua `init` (protocol repository, clock, …). Gốc ghép là `AppEnvironment` trong `AppFeature`, truyền xuống bằng SwiftUI `Environment` (một giá trị, không đổi trong vòng đời app).
- Dữ liệu chảy một chiều: `ValueObservation` (GRDB, ngoài main) → snapshot → Store → View. Ghi: View gọi phương thức Store → repository (async, ngoài main) → DB → observation đẩy snapshot mới.
- Không dùng TCA, không Combine mới, không singleton toàn cục (trừ `Logger`).

## Lựa chọn đã cân nhắc
| Kiến trúc | Chi phí runtime | Bề mặt API cho agent | Ổn định 2026 |
|---|---|---|---|
| **MV + @Observable + init injection** | Thấp nhất | Nhỏ | Ổn định |
| + swift-dependencies (Point-Free) | Thấp | Vừa | Ổn định |
| TCA 1.x / 2.0 | Action + reducer trên main | Lớn | Đang chuyển đổi |

Thêm `swift-dependencies` là lựa chọn còn mở (decisions-open D4), mặc định không thêm.

## Hệ quả
- Test store bằng repository giả trong `TestSupport`, không cần simulator.
- Mỗi hàng danh sách nhận struct giá trị nhỏ, không nhận cả Store.
