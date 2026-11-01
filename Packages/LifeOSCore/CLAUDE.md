# LifeOSCore
Swift thuần, phải build và test trên Linux (`swift test`). Chỉ import `Foundation`; `Persistence` thêm `GRDB`.
- Đổi gì ở `SyncCore`/`CryptoCore`/`Capture` → chạy vector tương ứng; định dạng đổi thì sửa spec + `reference/` trước.
- `Migrations/sql/*.sql` phải giống hệt `schema/*.sql` ở gốc (CI kiểm).
- Test dùng swift-testing (`import Testing`), dữ liệu qua `TestSupport` (FixedClock, VectorLoader, Fixtures).
