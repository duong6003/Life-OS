# Quy ước code

Swift 6.2+, **Swift 6 language mode, strict concurrency complete** ở mọi gói. Định dạng bằng `swift format` (có sẵn trong toolchain, cấu hình `.swift-format`). Luật chất lượng bằng SwiftLint và Periphery (docs/engineering/code-quality.md). Nguồn của các quy ước dưới: Swift API Design Guidelines, Google Swift Style Guide, Airbnb Swift Style Guide (docs/architecture/references.md: S-API, S-GOOG, S-AIRBNB).

## 1. Đặt tên
| Thứ | Quy ước | Ví dụ |
|---|---|---|
| Type | UpperCamel, danh từ | `TaskItem`, `HabitLog`, `TodaySnapshot` |
| Protocol | Danh từ hoặc `-ing`/`-able` | `TaskRepository`, `SyncTransport`, `CryptoProvider` |
| Cài đặt protocol | `<Tech><Protocol>` | `SQLiteTaskRepository`, `NotificationScheduler`; sau MVP `CloudKitSyncTransport`, `CryptoKitProvider` |
| Giả trong test | `Fake<Protocol>` / `Fixed<…>` | `FakeTransport`, `FixedClock` |
| View màn | `<Name>Screen` | `TodayScreen` |
| View con | `<Thing>View` / `<Thing>Row` | `TaskRowView` |
| Store | `<Name>Store` | `TodayStore` |
| Hàm | lowerCamel, động từ | `complete(_:at:)`, `observeToday(_:)` |
| Bool | `is/has/should` | `isOverdue` |
| Hằng token | qua DesignSystem | `Space.s4`, `LifeOSColor.text2` |
| Bảng/cột SQL | snake_case số ít | `habit_log.habit_id` |
| Chuỗi hiển thị | khoá = tiếng Việt gốc trong `.xcstrings` | `Text("Đã ghi")` |

Tên trong code tiếng Anh; comment được viết tiếng Việt, ngắn, giải thích **vì sao** (không nhắc lại code làm gì). Có mã tham chiếu thì ghi: `// BR-HAB-04`, `// SPEC-sync §6.3`.

## 2. File
- Một type public chính mỗi file; tên file = tên type. Extension: `<Type>+<Mục đích>.swift` [S-GOOG]. `scripts/check_structure.py` kiểm luật này.
- Thứ tự trong file: thuộc tính → init → API public → private. Dùng `// MARK: -` khi file > 150 dòng.
- File > 300 dòng là dấu hiệu tách. View `body` > 60 dòng → tách view con.
- Không file `Utils/Helpers/Common`.

## 3. Kiểu và giá trị
- Entity, snapshot, payload: `struct`, `Sendable`, `Hashable`. Chỉ Store và actor là `class`/`actor`.
- ID: `struct EntityID<T>: Hashable, Sendable { let raw: String }` (ADR-0014). Không dùng `String` trần cho ID ở API.
- Ngày lịch: `LocalDate`; tháng: `LocalMonth`; tiền: `Money(amount: Int64, currency: .vnd)` (ADR-0013). Không `Double` cho tiền.
- Không `!` (force unwrap), `try!`, `as!` ngoài test. `fatalError` chỉ cho trạng thái lập trình sai không thể xảy ra, kèm lý do.

## 4. Concurrency
- View, Store: `@MainActor`. Repository: `Sendable`, API `async`, thực thi trên pool GRDB (qua SQLiteData).
- Không `DispatchQueue` mới; dùng structured concurrency. `Task { }` chỉ trong Store (`start()`), giữ handle để huỷ.
- `actor` cho thành phần có trạng thái dùng chung: `SyncStatusMonitor`; sau MVP thêm `SyncCoordinator`, `KeyVault`.
- Không `@unchecked Sendable` trừ adapter bọc API Apple chưa Sendable, có comment lý do.

## 5. SwiftUI (ưu tiên hiệu năng)
- View đọc **snapshot giá trị**; không truy vấn DB, không định dạng số/ngày trong `body` (dùng chuỗi đã định dạng trong snapshot hoặc `FormatterCache`).
- Hàng danh sách nhận struct nhỏ + closure; không truyền cả Store xuống hàng.
- `List` cho danh sách dài; `LazyVStack` chỉ khi cần layout List không làm được.
- Không `AnyView`. Không `GeometryReader` trong hàng danh sách.
- Hiệu ứng: theo README DesignSystem (kính ≤5/màn trong một `GlassEffectContainer`, không `repeatForever`, `TimelineView(.animation)`, blur động; `.lifeOSAnimation` tự xử lý Reduce Motion).
- Mỗi Screen có `#Preview` Light, Dark, AX5 với dữ liệu mẫu từ `TestSupport`/Previews.
- Mọi control tự vẽ có `accessibilityLabel`, `accessibilityValue`, trait đúng.

## 6. Dữ liệu
- Mọi ghi bảng nghiệp vụ qua repository; `SyncEngine` chỉ ở `CloudSync` (ADR-0016). Mọi truy vấn có index cho điều kiện lọc/sắp xếp (TC-PERF-10).
- Dùng cursor/`fetchCursor` cho tập lớn; không `fetchAll` không giới hạn trên bảng lớn trong đường nóng.
- Không SQL ghép chuỗi với dữ liệu người dùng; luôn tham số hoá.
- Migration mới = file mới; không sửa migration đã merge vào `main`.

## 7. Lỗi
- Mỗi lớp có enum lỗi riêng: `DomainError`, `PersistenceError`, `CloudSyncError`; sau MVP `SyncError`, `CryptoError`.
- Store đổi lỗi thành `ScreenState.error(UserFacingError)` chỉ thuộc 3 loại ở BR-GEN-08; còn lại log + badge đồng bộ.
- Không nuốt lỗi im lặng: `catch` phải log (category theo module) hoặc chuyển tiếp.

## 8. Log và đo
- Apple: `os.Logger(subsystem: "life.os", category: "<Module>")`. Lõi: protocol `LogSink` tiêm vào (lõi không import `os`).
- **Không log** nội dung người dùng (tiêu đề việc, nhật ký, số tiền), khoá, mã khôi phục. Log ID và loại thao tác thôi.
- Đường nóng có `os_signpost`: `today.firstFrame`, `capture.parse`, `sync.applyBatch`, `spending.monthSwitch`.

## 9. Phụ thuộc
- Cho phép: GRDB.swift, sqlite-data và các gói Point-Free nó kéo theo (ADR-0016; ghim `Package.resolved`). Thêm gói mới cần ADR (lý do, dung lượng, giấy phép, bảo trì).
- Không thư viện UI bên thứ ba. Không analytics/crash SDK (dùng MetricKit + Organizer).

## 10. Chuỗi và ngôn ngữ
- Ngôn ngữ gốc `vi`. Mọi chuỗi qua String Catalog của gói chứa nó (`Bundle.module`).
- Câu chữ theo BR-GEN-07 và bảng thuật ngữ `docs/product/glossary.md`.
