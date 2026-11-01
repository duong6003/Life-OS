# AGENTS.md — LifeOSCore
Luật riêng của gói, bổ sung cho AGENTS.md ở gốc repo.
Swift thuần, phải build và test trên Linux (`swift test`). Chỉ import `Foundation`, không phụ thuộc ngoài. Lưu trữ nằm ở gói `LifeOSData` (ADR-0016).
- `SyncCore`/`CryptoCore` là phần đồng bộ mã hoá tự làm cho **sau MVP** (LOS-075); MVP không dùng.
- Đổi gì ở `SyncCore`/`CryptoCore`/`Capture` → chạy vector tương ứng; định dạng đổi thì sửa spec + `reference/` trước.
- `Domain` chỉ có thư mục `Model`, `Values`, `Rules`, `Errors`, `Ports` (protocol cho mọi thứ bên ngoài), `ReadModels` (snapshot cho màn). ADR-0017.
- Test dùng swift-testing (`import Testing`), dữ liệu qua `TestSupport` (`Fakes/` cho mọi port, `Fixtures/`, VectorLoader).
