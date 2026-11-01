# Sổ công thức: mỗi loại thay đổi thì làm gì, theo thứ tự nào

Mỗi công thức ghi: tạo file nào (bằng `scripts/new.py`), thứ tự làm, test gì, cập nhật tài liệu nào, và nguồn `[S-…]` ở [references.md](references.md). Thứ tự luôn là **từ trong ra ngoài**: Domain → TestSupport → Persistence → Feature → AppFeature. Lý do: phụ thuộc chỉ hướng vào trong, nên lớp trong phải có trước [S-CLEAN].

Trước mọi công thức: làm bước "Tìm trước khi viết" ở [overview.md §4](overview.md#4-tìm-trước-khi-viết-bắt-buộc-với-agent). Sau mọi công thức: `python3 -I scripts/check_structure.py`, `python3 scripts/inventory.py`, `swift test` ở gói đã sửa.

| Mã | Khi bạn cần | Lệnh bắt đầu |
|---|---|---|
| R1 | Màn mới | `new.py screen <Feature> <Name>` |
| R2 | Entity mới | `new.py entity <Name>` |
| R3 | Quy tắc nghiệp vụ | `new.py rule <Name>` |
| R4 | Nguồn dữ liệu ghi được (repository) | `new.py repository <Name>` |
| R5 | Dữ liệu đọc cho một màn (query) | `new.py query <Name>` |
| R6 | Bảng hoặc cột mới | `new.py migration <slug>` + `new.py table <Name>` |
| R7 | Component UI | `new.py component <Name>` hoặc `<X>Feature/Components/` |
| R8 | Dịch vụ hệ thống (thông báo, Face ID…) | tay, theo R4 |
| R9 | Kiểu giá trị | `new.py value <Name>` |
| R10 | Chuỗi hiển thị, lỗi người dùng | tay |
| R11 | Cài đặt người dùng | tay, theo R4 |
| R12 | Quyết định kiến trúc | `new.py adr <slug>` |

## R1. Màn mới

1. Viết spec màn `docs/design/screens/<màn>.md` từ `_template.md` (trạng thái rỗng, đang tải, lỗi; VoiceOver). **[Dự án]**
2. Dữ liệu màn cần đã có query chưa? Tìm trong inventory. Chưa có thì làm R5 trước.
3. `python3 scripts/new.py screen Tasks Inbox` tạo:
   - `TasksFeature/InboxScreen.swift`: giữ Store bằng `@State private var store` [S-OBS]; chỉ bố cục.
   - `TasksFeature/InboxStore.swift`: `@Observable @MainActor final class` [S-OBS], phụ thuộc **port** trong Domain, không phụ thuộc Persistence [S-TMA] [S-CLEAN].
   - `TasksFeature/InboxSnapshot.swift`: chỉ khi màn cần trạng thái dẫn xuất riêng; dữ liệu từ DB dùng `…Snapshot` của Domain.
   - `Previews/InboxScreen+Previews.swift`: preview với `Fake…` từ TestSupport [S-PREV] [S-TMA].
   - `Tests/TasksFeatureTests/InboxStoreTests.swift`: test Store bằng bản giả [S-HEX] [S-TEST].
4. View con chỉ một màn dùng: `Components/<Thing>View.swift`, nhận đúng struct của nó [S-PERF23] [S-PERF25].
5. Nối Store trong `AppFeature` (`AppEnvironment.live()`), không nơi nào khác tạo cài đặt thật [S-ROOT].
6. Kiểm hiệu năng: không formatter trong `body` [S-PERF25]; danh sách dài thì đo trên máy thật rồi mới chọn Lazy [S-LAZY].
7. PR kèm ảnh Light, Dark, cỡ chữ AX5.

## R2. Entity mới

1. `new.py entity Goal` → `Domain/Model/Goal.swift` (struct `Sendable, Hashable, Identifiable`) + `DomainTests/GoalTests.swift`. Entity không import framework nào [S-CLEAN].
2. ID dùng `EntityID<Goal>`, ngày `LocalDate`, tiền `Money` [Dự án ADR-0013/0014].
3. Cập nhật `docs/architecture/data-model.md`.
4. Cần lưu thì tiếp R6 → R4.

## R3. Quy tắc nghiệp vụ

1. Ghi BR trong `docs/product/business-rules.md` trước (mã `BR-XXX-NN`).
2. `new.py rule GoalProgress` → `Domain/Rules/GoalProgress.swift` (`enum` không case với hàm `static` thuần) [S-AIRBNB namespace] + test.
3. Test nêu mã BR trong tên; dùng test tham số hoá cho các trường hợp biên [S-TEST].
4. Store gọi rule; repository không chứa luật [S-CLEAN: luật test được không cần DB]. [Dự án: không lớp UseCase]

## R4. Nguồn dữ liệu ghi được (repository)

Thứ tự này là cốt lõi của Ports & Adapters [S-HEX] [S-CLEAN]:
1. **Port** `Domain/Ports/GoalRepository.swift`: protocol `Sendable`, API `async`, nhận và trả struct Domain. Tên là danh từ [S-API].
2. **Bản giả** `TestSupport/Fakes/FakeGoalRepository.swift`: lưu trong bộ nhớ [S-HEX: mock DB trong bộ nhớ] [S-TMA: target Testing].
3. **Adapter** `Persistence/Repositories/SQLiteGoalRepository.swift`: mọi lần ghi trong một transaction [S-GRDB-CONC]; ghi `updated_at`; xoá = đặt `deleted_at`.
4. **Test adapter** `PersistenceTests/SQLiteGoalRepositoryTests.swift` với DB tạm thật.
5. **Nối** trong `AppFeature`, dùng chung `AppDatabase` duy nhất [S-GRDB-CONC: một pool cho mỗi file] [S-ROOT].

`new.py repository Goal` tạo đủ bốn file đầu.

## R5. Dữ liệu đọc cho một màn (query)

1. `new.py query GoalList` tạo:
   - `Domain/ReadModels/GoalListSnapshot.swift`: struct đã định hình cho UI, không phải dòng DB [S-CLEAN].
   - `Domain/Ports/GoalListReading.swift`: port đọc, đuôi `-ing` vì mô tả khả năng [S-API].
   - `Persistence/Queries/GoalListQuery.swift`: một truy vấn SQL, theo dõi bằng `ValueObservation` để luôn có bản mới [S-GRDB-CONC].
   - Test với DB đã seed.
2. Lọc hoặc sắp xếp theo cột nào thì thêm index trong migration (R6).
3. Màn chính: đo trên DB seed, ghi `docs/engineering/perf-log.md`.

## R6. Bảng hoặc cột mới

1. `new.py migration add_goal` tạo `schema/NNNN_add_goal.sql`, bản sao trong `Persistence/Migrations/sql/` và `MNNNN_AddGoal.swift`.
2. Viết SQL bằng chuỗi; không dựa vào type Swift [S-GRDB-MIG]. Thiết kế schema chắc trước khi viết record [S-GRDB-REC].
3. **Không bao giờ sửa migration đã phát hành**; đổi gì cũng là migration mới [S-GRDB-MIG].
4. Bảng đồng bộ theo luật ở header `schema/0001_initial.sql` [S-SQLD-CK, **chưa đối chiếu bài gốc, LOS-021**]; thêm vào `CloudSync.SyncTables`.
5. `new.py table Goal` → `Persistence/Tables/GoalRow.swift`: một `@Table` struct cho một bảng, cột không NULL thì thuộc tính không optional [S-GRDB-REC]. Ánh xạ hai chiều với entity Domain.
6. Test migration từ DB phiên bản trước. `eraseDatabaseOnSchemaChange` chỉ trong `#if DEBUG` [S-GRDB-MIG].
7. Cập nhật `data-model.md`; nếu bảng đồng bộ thì thêm TC-SYNC-15.

## R7. Component UI

1. Tra bảng ánh xạ trong `Packages/LifeOSDesignSystem/README.md`. Có rồi thì dùng hoặc thêm tham số.
2. Dùng ở ≥ 2 màn hoặc có trong design: `new.py component GoalRing` → `DesignSystem/Components/GoalRing.swift`, thêm vào `Catalog.swift` và README. **[Dự án ADR-0009]**
3. Chỉ một màn dùng: `<X>Feature/Components/GoalRingView.swift`.
4. Chỉ dùng token; không `AnyView` [S-PERF23]; có nhãn VoiceOver.

## R8. Dịch vụ hệ thống

Như R4, đổi adapter: port ở `Domain/Ports/` (ví dụ `ReminderScheduling`), bản giả ở `TestSupport/Fakes/`, cài đặt ở `LifeOSPlatform/Sources/PlatformServices/` (ví dụ `UserNotificationReminderScheduler`), nối ở AppFeature. Mỗi thiết bị ngoài có một adapter [S-HEX]. Feature không import framework Apple của dịch vụ đó.

## R9. Kiểu giá trị

`new.py value Duration` → `Domain/Values/`. Dùng thay cho kiểu trần ở mọi API. Bất biến (`let`), `Sendable, Hashable`. **[Dự án ADR-0013/0014]**

## R10. Chuỗi hiển thị và lỗi người dùng

- Chuỗi: khoá là câu tiếng Việt gốc trong `<X>Feature/Strings/Localizable.xcstrings`. **[Dự án]**
- Lỗi: Store đặt `state = .error(UserFacingError…)`, chọn một trong ba loại của BR-GEN-08; không `alert` tự do. **[Dự án]**

## R11. Cài đặt người dùng

- Cài đặt đồng bộ giữa máy: cột trong bảng `setting` (R6) + port (R4).
- Cài đặt chỉ máy này: bảng `local_setting`. Không lưu dữ liệu vào `UserDefaults` (luật SwiftLint `no_user_defaults_for_data`). **[Dự án]**

## R12. Quyết định kiến trúc

`new.py adr <slug>`, điền Bối cảnh, Quyết định, Lựa chọn đã cân nhắc (bảng so sánh), Hệ quả; trích nguồn `[S-…]` nếu dựa vào chuẩn chung, thêm nguồn mới vào references.md. Thêm dòng vào `adr/README.md`. Thêm gói SPM, target hoặc thư mục cho phép mới đều cần ADR.
