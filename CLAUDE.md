# CLAUDE.md — luật cho agent code trong repo Life OS

Đọc file này trước mọi việc. Trả lời người dùng bằng **tiếng Việt**; code, commit, tên nhánh bằng tiếng Anh.

## Sản phẩm trong 5 dòng
Life OS: app sống có chủ đích (Hôm nay, Việc, Thói quen, Nhật ký + tâm trạng, Thu chi, Review tuần, Ghi nhanh).
Local-first: SQLite trong máy là nguồn sự thật; đồng bộ qua iCloud của người dùng (CKSyncEngine), mã hoá đầu-cuối, không máy chủ.
Apple trước (SwiftUI, iOS/iPadOS/macOS 26). Android sau, theo `docs/specs` + `TestVectors`.
**Ưu tiên: (1) mượt, tiết kiệm RAM/pin/dung lượng; (2) đẹp, hiệu ứng.** Khi hai thứ xung đột, (1) thắng.

## Trước khi code một issue
1. Đọc issue `docs/plan/issues/LOS-xxx-*.md` (hoặc trên GitHub), mọi BR/TC/SPEC/ADR nó nhắc tới.
2. Kiểm phụ thuộc đã xong. Chưa xong thì dừng và báo.
3. Có đụng định dạng trên dây (HLC, payload, envelope, schema)? → sửa **spec + code tham chiếu Python + test vector trước**, code Swift sau.
4. Làm màn hình? → phải có `docs/design/screens/<man>.md`; chưa có thì viết trước (mẫu `_template.md`), lấy hình từ `design/reference/screens.html`.

## Bản đồ repo (chi tiết: docs/architecture/module-structure.md)
- `Packages/LifeOSCore` — Swift thuần, chạy Linux: `Domain`, `Capture`, `SyncCore`, `CryptoCore`, `Persistence` (GRDB), `TestSupport`.
- `Packages/LifeOSPlatform` — chỉ Apple: `CryptoApple`, `CloudKitTransport`, `PlatformServices`.
- `Packages/LifeOSDesignSystem` — token sinh tự động + component SwiftUI. Bảng ánh xạ component ở README của gói.
- `Packages/LifeOSFeatures` — `<X>Feature` mỗi màn, `FeatureSupport`, `AppFeature` (ghép DI, điều hướng).
- `App/` — chỉ `@main`. `schema/` — SQL dùng chung. `TestVectors/` — hợp đồng. `reference/` — oracle Python.

## Luật cứng (vi phạm = PR bị trả)
1. `LifeOSCore` không import SwiftUI/UIKit/AppKit/CloudKit/CryptoKit/Security/os/Combine… (`scripts/check-core-imports.sh`). Chỉ `Persistence` import GRDB.
2. Feature không import feature khác, không import `LifeOSPlatform`. Chỉ `AppFeature` biết cài đặt cụ thể.
3. Mọi ghi vào bảng đồng bộ đi qua `SyncWriter` (SPEC-sync §5): dữ liệu + field clock + outbox trong **một** transaction.
4. Schema: khoá chính TEXT UUID, không UNIQUE ngoài PK, không CASCADE, xoá = `deleted_at`, migration **chỉ thêm**, migration đã merge thì không sửa. Ngày lịch `TEXT YYYY-MM-DD`, mốc thời gian ms UTC, tiền Int64 (ADR-0003/0013/0014).
5. Không bao giờ log nội dung người dùng, khoá, mã khôi phục. Transport chỉ nhận `OpaqueRecord` đã mã hoá.
6. Không sửa test vector cho test xanh. Vector đổi chỉ khi spec đổi, sinh lại bằng `python3 reference/run_all.py`.
7. Không sửa file sinh tự động (`Generated/`, `Tokens.xcassets`, `tokens.css`): sửa `design/tokens/tokens.json` rồi chạy `python3 design/tokens/generate.py`.
8. Không thêm phụ thuộc SPM mới khi chưa có ADR. Đang cho phép: GRDB.swift.
9. Không `!`, `try!`, `as!` ngoài test. Không `AnyView`. Không singleton toàn cục (trừ Logger).
10. Không tắt/bỏ qua test để CI xanh.

## Hiệu năng (đọc docs/engineering/performance-budget.md)
- Store `@Observable @MainActor` giữ **snapshot giá trị**; View không truy vấn DB, không tạo formatter trong `body`.
- I/O và giải mã ngoài main. Không làm gì nặng trước khung hình đầu.
- `List` cho danh sách dài; heatmap là một `Canvas`; biểu đồ đọc số gộp sẵn bằng SQL; truy vấn phải có index.
- Kính (Liquid Glass) chỉ ở lớp điều hướng, tự thêm ≤ 5 phần tử/màn trong một `GlassEffectContainer`. Không `repeatForever`, `TimelineView(.animation)`, blur động. Dùng `.lifeOSAnimation` (tự xử lý Reduce Motion).

## Đặt tên và tạo file
Theo `docs/engineering/conventions.md` và bảng "Quy tắc tạo file" ở module-structure §4. Tóm tắt: `<Name>Screen`, `<Name>Store`, `<Thing>RowView`, `GRDB<Thing>Repository`, `<Screen><Thing>Query`, migration `M<NNNN>_<Mô tả>.swift`. Không `Utils/Helpers/Extensions.swift`.

## Lệnh
```sh
cd Packages/LifeOSCore && swift build && swift test         # lõi, chạy được cả Linux
swift format lint -r Packages                                # định dạng
bash scripts/check-core-imports.sh                              # ranh giới module
python3 design/tokens/generate.py --check                    # token
python3 -I reference/run_all.py --check                      # test vector
python3 -I scripts/plan_graph.py --check                     # plan
xcodebuild -project App/LifeOS.xcodeproj -scheme LifeOS -destination 'platform=iOS Simulator,name=iPhone 17' test   # app (sau LOS-003)
```

## Hoàn thành một issue (Definition of Done)
- Tiêu chí nghiệm thu trong issue đạt; test mới tên `test_TC_<MOD>_<NN>_…` cho mọi TC liên quan.
- Mọi lệnh ở trên xanh. Không cảnh báo mới.
- Tài liệu cập nhật trong cùng PR: BR, TC, spec, sơ đồ system-design, data-model nếu đổi.
- UI: ảnh preview Light/Dark/AX5 trong PR.
- Commit `type(scope): mô tả (LOS-xxx)`; PR "Closes #n", theo `.github/pull_request_template.md`.

## Khi không chắc
Hỏi người dùng thay vì đoán, nhất là về hành vi người dùng thấy, định dạng dữ liệu, và bất cứ gì không đảo ngược được (migration, định dạng trên dây). Lựa chọn còn mở ở `docs/decisions-open.md`.
