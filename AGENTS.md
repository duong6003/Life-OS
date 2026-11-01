# AGENTS.md — luật cho agent code trong repo Life OS

File gốc cho **mọi** agent (Codex, Claude Code, Cursor, Gemini CLI…), theo chuẩn mở [agents.md](https://agents.md/). `CLAUDE.md` chỉ import file này; muốn đổi luật thì sửa ở đây (docs/agents/README.md).

Đọc file này trước mọi việc. Sửa file trong `Packages/<Gói>/` thì đọc thêm `Packages/<Gói>/AGENTS.md` (luật riêng của gói; file gần hơn được ưu tiên). Trả lời người dùng bằng **tiếng Việt**; code, commit, tên nhánh bằng tiếng Anh.

## Sản phẩm trong 5 dòng
Life OS: app sống có chủ đích (Hôm nay, Việc, Thói quen, Nhật ký + tâm trạng, Thu chi, Review tuần, Ghi nhanh).
Local-first: SQLite trong máy là nguồn sự thật; đồng bộ qua iCloud của người dùng, không máy chủ. MVP dùng SQLiteData (GRDB + SyncEngine); đồng bộ mã hoá đầu-cuối tự làm để sau MVP (ADR-0016).
Apple trước (SwiftUI, iOS/iPadOS/macOS 26). Android sau, theo `docs/specs` + `TestVectors`.
**Ưu tiên: (1) mượt, tiết kiệm RAM/pin/dung lượng; (2) đẹp, hiệu ứng.** Khi hai thứ xung đột, (1) thắng.

## Trước khi code một issue
Quy trình đầy đủ từ issue tới PR: `docs/agents/workflows/implement-issue.md`. Prompt dán sẵn: `docs/agents/prompts.md`.

1. Đọc issue `docs/plan/issues/LOS-xxx-*.md` (hoặc trên GitHub), mọi BR/TC/SPEC/ADR nó nhắc tới.
2. Kiểm phụ thuộc đã xong. Chưa xong thì dừng và báo.
3. Có đụng schema? → sửa `schema/*.sql` + data-model.md trước, theo luật SyncEngine. Có đụng HLC, payload hay envelope (sau MVP)? → sửa **spec + code tham chiếu Python + test vector trước**, code Swift sau.
4. Làm màn hình? → phải có `docs/design/screens/<man>.md`; chưa có thì viết trước (mẫu `_template.md`), lấy hình từ `design/reference/screens.html`.
5. **Tìm trước khi viết**: đọc `docs/architecture/overview.md` (mẫu kiến trúc, bảng "Khi nào dùng gì"), tra `docs/architecture/inventory.md` và `rg` xem đã có type/component tương tự chưa. Có rồi thì mở rộng, không viết bản thứ hai.
6. Làm theo công thức trong `docs/architecture/recipes.md` (R1 màn, R4 repository, R5 query, R6 migration…). Thứ tự luôn từ trong ra: Domain → TestSupport → Persistence → Feature → AppFeature.

## Bản đồ repo (chi tiết: docs/architecture/module-structure.md)
- `Packages/LifeOSCore` — Swift thuần, chạy Linux: `Domain`, `Capture`, `TestSupport`; `SyncCore`, `CryptoCore` để sau MVP.
- `Packages/LifeOSData` — chỉ Apple, SQLiteData + GRDB: `Persistence` (adapter cài đặt port của Domain: DB, migration, repository, query), `CloudSync` (nơi duy nhất có SyncEngine).
- `Packages/LifeOSPlatform` — chỉ Apple: `PlatformServices`; `CryptoApple`, `CloudKitTransport` để sau MVP.
- `Packages/LifeOSDesignSystem` — token sinh tự động + component SwiftUI. Bảng ánh xạ component ở README của gói.
- `Packages/LifeOSFeatures` — `<X>Feature` mỗi màn (chỉ biết `Domain`, `FeatureSupport`, `DesignSystem`; **không** import Persistence), `FeatureSupport`, `AppFeature` (gốc ghép duy nhất, điều hướng). ADR-0017.
- `App/` — chỉ `@main`. `schema/` — SQL dùng chung. `TestVectors/` — hợp đồng. `reference/` — oracle Python.

## Luật cứng (vi phạm = PR bị trả)
1. `LifeOSCore` không import SwiftUI/UIKit/AppKit/CloudKit/CryptoKit/Security/os/Combine/GRDB/SQLiteData… (`scripts/check-core-imports.sh`).
2. Feature không import feature khác, không import `Persistence`, `LifeOSPlatform`, `CloudSync`, `SQLiteData`; đọc/ghi qua port trong `Domain/Ports`, không dùng `@FetchAll` trong View. Chỉ `AppFeature` biết cài đặt cụ thể (ADR-0017).
3. `SyncEngine` chỉ được nhắc trong `LifeOSData/Sources/CloudSync` và `AppFeature` (TC-SYNC-14). Bảng nghiệp vụ không có cột riêng của CloudKit.
4. Schema: khoá chính đơn TEXT UUID, không UNIQUE ngoài PK, cột `NOT NULL` có `ON CONFLICT REPLACE` + `DEFAULT`, xoá = `deleted_at`, migration **chỉ thêm** (không đổi tên/xoá cột), migration đã merge thì không sửa. Ngày lịch `TEXT YYYY-MM-DD`, mốc thời gian ms UTC, tiền Int64 (ADR-0003/0013/0014).
5. Không bao giờ log nội dung người dùng, khoá, mã khôi phục. Không hứa "mã hoá đầu-cuối" trong UI của MVP (BR-ONB-10).
6. Không sửa test vector cho test xanh. Vector đổi chỉ khi spec đổi, sinh lại bằng `python3 reference/run_all.py`.
7. Không sửa file sinh tự động (`Generated/`, `Tokens.xcassets`, `tokens.css`): sửa `design/tokens/tokens.json` rồi chạy `python3 design/tokens/generate.py`.
8. Không thêm phụ thuộc SPM mới khi chưa có ADR. Đang cho phép: GRDB.swift, sqlite-data (và các gói Point-Free nó kéo theo) — ADR-0016. Chỉ `defaultDatabase`/`defaultSyncEngine` đi qua `prepareDependencies`; còn lại tiêm qua init.
9. Không `!`, `try!`, `as!` ngoài test. Không `AnyView`. Không singleton toàn cục (trừ Logger).
10. Không tắt/bỏ qua test để CI xanh.
11. Không hạ luật SwiftLint/Periphery để code qua; tắt một chỗ phải dùng `// swiftlint:disable:next <luật>` kèm lý do (docs/engineering/code-quality.md).
12. Skill bên ngoài (mattpocock, swiftui-pro…) là gợi ý; khi nói khác file này hoặc ADR thì repo thắng.

## Hiệu năng (đọc docs/engineering/performance-budget.md)
- Store `@Observable @MainActor` giữ **snapshot giá trị**; View không truy vấn DB, không tạo formatter trong `body`.
- I/O và giải mã ngoài main. Không làm gì nặng trước khung hình đầu.
- `List` cho danh sách dài; heatmap là một `Canvas`; biểu đồ đọc số gộp sẵn bằng SQL; truy vấn phải có index.
- Kính (Liquid Glass) chỉ ở lớp điều hướng, tự thêm ≤ 5 phần tử/màn trong một `GlassEffectContainer`. Không `repeatForever`, `TimelineView(.animation)`, blur động. Dùng `.lifeOSAnimation` (tự xử lý Reduce Motion).

## Đặt tên và tạo file
**Luôn tạo file bằng `python3 scripts/new.py <loại> <Tên>`** (`--list` xem các loại, `--dry-run` xem trước). Không tự đặt thư mục mới: danh sách thư mục được phép nằm trong `scripts/check_structure.py`, thêm cần ADR.
Theo `docs/engineering/conventions.md` và module-structure §4. Tóm tắt: `<Name>Screen`, `<Name>Store`, `<Thing>RowView`, port `<Thing>Repository`/`<X>Reading` trong `Domain/Ports`, `Fake<Port>` trong `TestSupport/Fakes`, `SQLite<Thing>Repository`, `<X>Query`, migration `M<NNNN>_<Mô tả>.swift`. File một type mang tên type; extension `<Type>+<Mục đích>.swift`. Không `Utils/Helpers/Extensions.swift`.
Mỗi quy tắc kiến trúc có nguồn ở `docs/architecture/references.md`. Đề xuất quy tắc mới thì trích nguồn chính thức, không tự suy luận; không có nguồn thì ghi rõ [Dự án] và lý do.

## Lệnh
```sh
cd Packages/LifeOSCore && swift build && swift test         # lõi, chạy được cả Linux
cd Packages/LifeOSData && swift test                         # lưu trữ + đồng bộ (macOS)
swift format lint -r Packages                                # định dạng
swiftlint lint --strict                                      # luật code (.swiftlint.yml)
periphery scan                                               # code thừa (macOS, sau LOS-003)
bash scripts/check-core-imports.sh                              # ranh giới module
python3 design/tokens/generate.py --check                    # token
python3 -I reference/run_all.py --check                      # test vector
python3 -I scripts/plan_graph.py --check                     # plan
python3 -I scripts/check_structure.py                        # vị trí và tên file (ADR-0017)
python3 -I scripts/inventory.py                              # sinh lại danh mục sau khi thêm type công khai (CI: --check)
xcodebuild -project App/LifeOS.xcodeproj -scheme LifeOS -destination 'platform=iOS Simulator,name=iPhone 17' test   # app (sau LOS-003)
```

## Hoàn thành một issue (Definition of Done)
- Tiêu chí nghiệm thu trong issue đạt; test mới tên `test_TC_<MOD>_<NN>_…` cho mọi TC liên quan.
- Mọi lệnh ở trên xanh (lefthook chạy phần lớn trước mỗi commit). Không cảnh báo SwiftLint mới, Periphery không báo code thừa.
- Tài liệu cập nhật trong cùng PR: BR, TC, spec, sơ đồ system-design, data-model nếu đổi.
- UI: ảnh preview Light/Dark/AX5 trong PR.
- Commit `type(scope): mô tả (LOS-xxx)`; PR "Closes #n", theo `.github/pull_request_template.md`.

## Agent skills

### Issue tracker

Nguồn sự thật là `docs/plan/issues/LOS-*.md`, đẩy lên GitHub Issues bằng `scripts/bootstrap_github.py`. Xem `docs/agents/issue-tracker.md`.

### Triage labels

Ánh xạ sang nhãn sẵn có: `agent-ok`, `needs-decision`, `wontfix`, cùng `needs-triage` và `ready-for-human`. Xem `docs/agents/triage-labels.md`.

### Domain docs

Một ngữ cảnh: glossary ở `docs/product/glossary.md`, ADR ở `docs/architecture/adr/`. Xem `docs/agents/domain.md`.

## Khi không chắc
Hỏi người dùng thay vì đoán, nhất là về hành vi người dùng thấy, định dạng dữ liệu, và bất cứ gì không đảo ngược được (migration, định dạng trên dây). Lựa chọn còn mở ở `docs/decisions-open.md`.
