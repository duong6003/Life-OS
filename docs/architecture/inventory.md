# Danh mục thứ đã có (tự sinh)

<!-- File do scripts/inventory.py sinh. Không sửa tay; CI kiểm bằng --check. -->

66 khai báo công khai. **Tìm ở đây và bằng `rg` trước khi tạo type mới** (overview.md §4).
Component UI có sẵn của hệ thống (Button, List, DatePicker…) xem bảng ánh xạ trong `Packages/LifeOSDesignSystem/README.md`.

## LifeOSCore

### Capture

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `QuickCaptureParser` | enum | `QuickCaptureParser.swift` | Bộ hiểu Ghi nhanh (SPEC-quick-capture v1). |

### CryptoCore

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `CryptoProvider` | protocol | `CryptoProvider.swift` | Primitive mật mã (SPEC-crypto §1). |
| `CryptoError` | enum | `CryptoProvider.swift` |  |

### Domain

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `DomainError` | enum | `Errors/DomainError.swift` | Lỗi nghiệp vụ (vi phạm business rule). |
| `LogSink` | protocol | `Ports/LogSink.swift` | Lõi không import `os`; Apple tiêm cài đặt dùng `os.Logger` (conventions §8). |
| `LogLevel` | enum | `Ports/LogSink.swift` |  |
| `EntityID` | struct | `Values/EntityID.swift` | ID có kiểu của một entity (ADR-0014): `EntityID<TaskItem>` không lẫn được với `EntityID<Habit>`. API: `raw, description` |
| `LocalDate` | struct | `Values/LocalDate.swift` | Ngày lịch không có múi giờ, dạng `YYYY-MM-DD` (ADR-0013). API: `year, month, day, description` |

### SyncCore

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `HLCTimestamp` | struct | `Clock/HLCTimestamp.swift` | HLC theo SPEC-sync §2. API: `rawValue` |
| `SyncTransport` | protocol | `Transport/SyncTransport.swift` | Kênh chuyên chở trung lập (ADR-0005). |
| `SyncTransportDelegate` | protocol | `Transport/SyncTransport.swift` |  |
| `OpaqueRecord` | struct | `Transport/SyncTransport.swift` |  API: `name, keyID, payloadVersion, opaquePayload` |
| `PendingRecordChange` | enum | `Transport/SyncTransport.swift` |  |
| `TransportStatus` | enum | `Transport/SyncTransport.swift` |  |

### TestSupport

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `VectorLoader` | enum | `VectorLoader.swift` | Đọc TestVectors/ ở gốc repo. API: `root, data, decode` |

## LifeOSData

### CloudSync

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `CloudSync` | enum | `CloudSync.swift` | ADR-0016: target DUY NHẤT được nhắc tới `SyncEngine`. API: `makeEngine` |
| `SyncTables` | enum | `CloudSync.swift` | Bảng đồng bộ trong MVP (data-model §2). API: `names` |

### Persistence

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `AppDatabase` | class | `Database/AppDatabase.swift` | Điểm vào DB (ADR-0003, ADR-0016). API: `writer` |

## LifeOSDesignSystem

### DesignSystem

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `DesignSystemCatalog` | struct | `Catalog.swift` | Trang xem nhanh mọi component, dùng trong Xcode Preview để soát Light, Dark, chữ lớn và Increase Contrast. API: `body` |
| `ChipToggleStyle` | struct | `Components/Chips.swift` | Chip bật/tắt (lọc, chọn danh mục, ngày trong tuần). API: `makeBody` |
| `WeekdayPicker` | struct | `Components/Chips.swift` | Chọn ngày lặp trong tuần (T2 … CN). API: `labels, spoken, body` |
| `StatTile` | struct | `Components/Chips.swift` | Ô số liệu: số lớn và nhãn, dùng trong Rà soát và Thu chi. API: `body` |
| `EnergyPicker` | struct | `Components/EnergyPicker.swift` | Chọn năng lượng 1–5: năm cột cao dần. API: `labels, body` |
| `GlanceItem` | struct | `Components/GlanceRow.swift` |  API: `id, value, label, isAlert` |
| `GlanceRow` | struct | `Components/GlanceRow.swift` | Dải tóm tắt 3 ô dưới lời chào trên Hôm nay. API: `body` |
| `HabitHeatmap` | struct | `Components/HabitHeatmap.swift` | Heatmap thói quen vẽ bằng một Canvas thay vì hàng trăm view ô. API: `body` |
| `HabitTile` | struct | `Components/HabitTile.swift` | Thẻ thói quen: chạm để tick. API: `body` |
| `Mood` | enum | `Components/MoodPicker.swift` |  API: `labels, colors` |
| `MoodFace` | struct | `Components/MoodPicker.swift` | Mặt tâm trạng vẽ bằng một Canvas: nền màu mood, hai mắt, miệng cong theo mức 1–5. API: `body` |
| `MoodPicker` | struct | `Components/MoodPicker.swift` | Chọn tâm trạng 1–5. API: `body` |
| `CapturePreview` | struct | `Components/QuickCapture.swift` | Kết quả xem trước của bộ hiểu cú pháp Ghi nhanh (nằm ở tầng Domain, truyền vào đây). API: `kind, summary` |
| `QuickCaptureField` | struct | `Components/QuickCapture.swift` | Ô Ghi nhanh: gõ một dòng, xem trước sẽ lưu thành gì, Enter để lưu. API: `body` |
| `QuickCaptureBar` | struct | `Components/QuickCapture.swift` | Thanh "Ghi nhanh…" trên iPhone, đặt trong `.tabViewBottomAccessory` của `TabView`. API: `body` |
| `QuickCaptureToolbarButton` | struct | `Components/QuickCapture.swift` | Nút Ghi nhanh trong toolbar trên iPad và Mac, phím tắt ⌘N. API: `body` |
| `RecoveryKeyView` | struct | `Components/RecoveryKeyView.swift` | Hiển thị mã khôi phục theo nhóm 4 ký tự, chữ đơn cách. API: `body` |
| `RecoveryKeyAlphabet` | enum | `Components/RecoveryKeyView.swift` | Bảng ký tự của mã khôi phục: bỏ O, I, L, S, B, Z, U, V và 0, 1, 2, 5, 8 (dễ đọc nhầm khi chép tay). API: `characters, length, normalize, invalidCharacters` |
| `RecoveryKeyCopyButton` | struct | `Components/RecoveryKeyView.swift` | Nút Chép mã khôi phục: chỉ trong máy (không qua Universal Clipboard), tự xóa sau 2 phút. API: `body` |
| `SyncState` | enum | `Components/SyncStatusBadge.swift` | Trạng thái đồng bộ iCloud. API: `title, detail, symbol, needsAttention` |
| `SyncStatusBadge` | struct | `Components/SyncStatusBadge.swift` | Chỉ báo đồng bộ nhỏ: đặt ở cuối thanh tiêu đề hoặc đầu Cài đặt. API: `body` |
| `TaskPriority` | enum | `Components/TaskCheckbox.swift` | Mức ưu tiên của việc. API: `color, label` |
| `TaskCheckboxStyle` | struct | `Components/TaskCheckbox.swift` | Vòng tròn tick việc: viền theo ưu tiên, đầy accent khi xong. API: `priority, makeBody` |
| `UndoToast` | struct | `Components/UndoToast.swift` | Thông báo ngắn có nút Hoàn tác (iOS không có sẵn). API: `body` |
| `LifeOSIcon` | enum | `Foundation/Icons.swift` | Tên SF Symbols thay cho bộ Lucide của bản web. API: `today, tasks, habits, journal, money, review, settings, inbox, search, add, check, close, more, delete, undo, reschedule` |
| `View (ext)` | extension | `Foundation/Motion.swift` |  |
| `AnyTransition (ext)` | extension | `Foundation/Motion.swift` |  |
| `Celebration` | enum | `Foundation/Motion.swift` | Khoảnh khắc ăn mừng (mốc chuỗi thói quen): tối đa một lần mỗi màn, tắt khi Reduce Motion hoặc Low Power Mode. API: `isAllowed` |
| `EnvironmentValues (ext)` | extension | `Foundation/Surfaces.swift` |  |
| `View (ext)` | extension | `Foundation/Surfaces.swift` |  |
| `IconTile` | struct | `Foundation/Surfaces.swift` | Ô icon có nền màu dữ liệu nhạt (36pt, icon 20pt). API: `body` |
| `InlineError` | struct | `Foundation/Surfaces.swift` | Lỗi ngay dưới ô nhập: icon và câu hướng dẫn, màu chữ phụ. API: `body` |
| `View (ext)` | extension | `Foundation/Typography.swift` |  |

## LifeOSFeatures

### AppFeature

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `RootView` | struct | `RootView.swift` | Gốc giao diện: TabView trên iPhone, NavigationSplitView trên iPad/Mac. API: `body` |

### CaptureFeature

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `CaptureFeatureModule` | enum | `CaptureFeature.swift` | Khung. |

### FeatureSupport

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `ScreenState` | enum | `ScreenState.swift` | Trạng thái chung của một màn. |
| `UserFacingError` | enum | `ScreenState.swift` | Ba loại lỗi duy nhất người dùng thấy (BR-GEN-08). |

### HabitsFeature

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `HabitsFeatureModule` | enum | `HabitsFeature.swift` | Khung. |

### JournalFeature

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `JournalFeatureModule` | enum | `JournalFeature.swift` | Khung. |

### OnboardingFeature

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `OnboardingFeatureModule` | enum | `OnboardingFeature.swift` | Khung. |

### ReviewFeature

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `ReviewFeatureModule` | enum | `ReviewFeature.swift` | Khung. |

### SettingsFeature

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `SettingsFeatureModule` | enum | `SettingsFeature.swift` | Khung. |

### SpendingFeature

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `SpendingFeatureModule` | enum | `SpendingFeature.swift` | Khung. |

### TasksFeature

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `TasksFeatureModule` | enum | `TasksFeature.swift` | Khung. |

### TodayFeature

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `TodayFeatureModule` | enum | `TodayFeature.swift` | Khung. |

## LifeOSPlatform

### CloudKitTransport

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `CloudKitSyncTransportModule` | enum | `CloudKitSyncTransport.swift` | Cài SyncTransport bằng CKSyncEngine (ADR-0005, SPEC-sync §7). |

### CryptoApple

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `CryptoKitProvider` | struct | `CryptoKitProvider.swift` | CryptoProvider bằng CryptoKit (SPEC-crypto §1). API: `randomBytes, hkdfSHA256, hmacSHA256, chaChaPolySeal, chaChaPolyOpen` |

### PlatformServices

| Tên | Loại | File | Mô tả |
|---|---|---|---|
| `PlatformServicesModule` | enum | `PlatformServices.swift` | Thông báo cục bộ, BGProcessingTask, Face ID, MetricKit, LogSink bằng os.Logger. |
