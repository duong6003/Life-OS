# System design

Tài liệu này mô tả hệ thống bằng sơ đồ (Mermaid, GitHub hiển thị trực tiếp). Mỗi luồng có: sơ đồ, quy tắc thread/actor, điểm lỗi, và test case kiểm nó. **Code một luồng = đi đúng các bước trong sơ đồ, đúng tên thành phần.** Đổi luồng thì sửa sơ đồ trong cùng PR.

## 1. Bối cảnh (C4 mức 1)

> MVP theo ADR-0016: đồng bộ bằng SyncEngine của SQLiteData. Bản có mã hoá đầu-cuối tự làm nằm ở [system-design-post-mvp.md](system-design-post-mvp.md).

```mermaid
flowchart LR
  U([Người dùng]) -->|chạm, gõ, ⌘N| APP[Life OS<br/>iPhone · iPad · Mac]
  APP <-->|bản ghi theo từng hàng<br/>SQLiteData SyncEngine · CKSyncEngine| CK[(iCloud private DB<br/>của người dùng)]
  APP -->|thông báo cục bộ| OS[iOS / macOS<br/>Notification Center]
  APP <-->|đọc chung DB| W["Widget · App Intents<br/>(sau MVP)"]
```

Không có máy chủ Life OS. Trong MVP, iCloud lưu dữ liệu dưới dạng bản ghi CloudKit với bảo vệ chuẩn của iCloud. Dữ liệu chỉ được mã hoá đầu-cuối khi người dùng bật Advanced Data Protection (BR-ONB-10).

## 2. Container và lớp (C4 mức 2)

```mermaid
flowchart TB
  subgraph App["App/ (target mỏng)"]
    MAIN["LifeOSApp @main<br/>prepareDependencies + AppEnvironment"]
  end
  subgraph Features["Packages/LifeOSFeatures"]
    AF[AppFeature<br/>điều hướng, ghép DI]
    TF[TodayFeature]:::f
    TK[TasksFeature]:::f
    HF[HabitsFeature]:::f
    JF[JournalFeature]:::f
    SF[SpendingFeature]:::f
    RF[ReviewFeature]:::f
    CF[CaptureFeature]:::f
    OF[OnboardingFeature]:::f
    STF[SettingsFeature]:::f
    FS[FeatureSupport<br/>store base, formatter cache]
  end
  subgraph DS["Packages/LifeOSDesignSystem"]
    DSY[DesignSystem<br/>token, component]
  end
  subgraph Data["Packages/LifeOSData (chỉ Apple)"]
    PER[Persistence<br/>SQLiteData + GRDB, migration, repository, query]
    CS[CloudSync<br/>SyncEngine, SyncTables, trạng thái]
  end
  subgraph Platform["Packages/LifeOSPlatform (chỉ Apple)"]
    PL[PlatformServices<br/>thông báo, BGTask, Face ID, MetricKit]
  end
  subgraph Core["Packages/LifeOSCore (Swift thuần, Linux)"]
    DOM[Domain<br/>entity, rule, LocalDate]
    CAP[Capture<br/>bộ hiểu Ghi nhanh]
    TS[TestSupport]
  end
  MAIN --> AF
  AF --> TF & TK & HF & JF & SF & RF & CF & OF & STF
  TF & TK & HF & JF & SF & RF & CF & OF & STF --> FS
  TF & TK & HF & JF & SF & RF & CF & OF & STF --> PER
  FS --> DSY
  FS --> DOM
  AF --> CS & PL & PER
  CS --> PER
  PER --> DOM
  CAP --> DOM
  CF --> CAP
  classDef f fill:#eef,stroke:#88a
```

Quy tắc mũi tên (bị kiểm bằng build + `scripts/check-core-imports.sh`):
- `LifeOSCore` không import `SwiftUI`, `UIKit`, `AppKit`, `CloudKit`, `CryptoKit`, `Security`, `os`, `Combine`, `WidgetKit`, `GRDB`, `SQLiteData`. Chỉ dùng `Foundation` (bản swift-corelibs).
- Feature không import feature khác. Feature không import `LifeOSPlatform`, `CloudSync`, `SQLiteData`; chỉ thấy protocol repository và snapshot trong `Persistence`.
- `SyncEngine` chỉ xuất hiện trong `CloudSync` và `AppFeature` (TC-SYNC-14).
- Chỉ `AppFeature` biết cài đặt cụ thể (ghép DI).
- `SyncCore`, `CryptoCore`, `CryptoApple`, `CloudKitTransport` vẫn nằm trong repo nhưng chưa được nối vào app (sau MVP, LOS-075).

## 3. Mô hình chạy (thread & actor)

| Thành phần | Chạy ở đâu | Ghi chú |
|---|---|---|
| View, Store | `@MainActor` | Store chỉ giữ snapshot giá trị; không I/O |
| Repository | `DatabasePool` của GRDB qua SQLiteData (hàng đợi riêng) | `async` API; ghi luôn trong `write { }` |
| `ValueObservation` | Đọc trên pool, giao kết quả `.immediate` lần đầu rồi về main | Lần đầu đồng bộ để không nháy "đang tải" |
| `SyncEngine` (SQLiteData) | Do thư viện quản lý, ngoài main | Ta chỉ đọc trạng thái qua `SyncStatusMonitor` |
| Định dạng số/ngày | `FormatterCache` tạo một lần | Không tạo formatter trong `body` |

## 4. Luồng: khởi động lạnh tới màn Hôm nay (mục tiêu ≤ 400 ms)

```mermaid
sequenceDiagram
  autonumber
  participant OS as iOS
  participant App as LifeOSApp
  participant Env as AppEnvironment
  participant DB as Database (SQLiteData/GRDB)
  participant TS as TodayStore
  participant V as TodayView
  OS->>App: launch
  App->>Env: init (không I/O mạng, không crypto)
  Env->>DB: mở DatabasePool + chạy migration (thường 0 bước)
  App->>V: dựng cây view
  V->>TS: task { start() }
  TS->>DB: ValueObservation(TodayQuery) .immediate
  DB-->>TS: TodaySnapshot (đã định hình)
  TS-->>V: vẽ khung hình đầu có dữ liệu
  Note over App,Env: Sau khung hình đầu
  App->>Env: CloudSync.makeEngine (SyncEngine), lên lịch thông báo
```

Điểm lỗi: migration lỗi → màn "File dữ liệu trong máy hỏng" (BR-GEN-05), không crash. Kiểm: TC-PERF-01, TC-GEN-03.

## 5. Luồng: ghi một thay đổi (mọi tính năng)

```mermaid
sequenceDiagram
  autonumber
  participant V as View
  participant S as Store (@MainActor)
  participant R as Repository (SQLite…)
  participant DB as SQLite
  participant O as Theo dõi (ValueObservation)
  participant SE as SyncEngine (CloudSync)
  V->>S: toggleTask(id)
  S->>S: cập nhật lạc quan snapshot (tuỳ chọn) + haptic
  S->>R: complete(taskId, at: now)
  R->>DB: write { UPDATE task SET status, completed_at, updated_at }
  DB-->>O: thay đổi trong transaction
  O-->>S: snapshot mới
  S-->>V: vẽ lại đúng hàng đổi
  DB-->>SE: trigger của SQLiteData ghi nhận hàng đổi
  SE->>SE: xếp gửi lên iCloud theo lịch hệ thống
```

Bất biến: **một thao tác người dùng = một transaction**. Repository không biết đồng bộ; SyncEngine tự thấy thay đổi qua trigger. Không có đường ghi nào bỏ qua repository cho bảng nghiệp vụ. Kiểm: TC-GEN-01, TC-SYNC-14.

## 6. Luồng: Ghi nhanh

```mermaid
flowchart LR
  IN["Người dùng gõ<br/>'cafe 45k'"] --> P["Capture.parse(text, today, categories)"]
  P -->|expense / income| TX[TransactionRepository.add]
  P -->|task có @ngày| TK[TaskRepository.add due]
  P -->|task không ngày| IB[TaskRepository.add inbox=1]
  P -->|nil: chuỗi rỗng| X[Không làm gì]
  P -.->|amountHint| H["Gợi ý: Chưa hiểu số tiền…"]
  TX & TK & IB --> T["Toast: Đã ghi · Hoàn tác (4 giây)"]
```

Bộ hiểu là hàm thuần trong `Capture` (SPEC-quick-capture), có test vector. Xem trước kết quả cập nhật theo từng phím gõ, nên phải < 1 ms với chuỗi 200 ký tự. Kiểm: TC-CAP-*.

## 7. Luồng: đồng bộ (gửi và nhận)

```mermaid
sequenceDiagram
  autonumber
  participant DB as SQLite (bảng nghiệp vụ)
  participant MD as Metadatabase SQLiteData
  participant SE as SyncEngine
  participant E as CKSyncEngine
  participant CK as iCloud
  participant M as SyncStatusMonitor (CloudSync)
  DB->>MD: trigger ghi hàng đổi
  SE->>E: xếp bản ghi cần gửi
  E->>CK: gửi theo lô (theo lịch hệ thống)
  CK-->>E: saved / serverRecordChanged
  E-->>SE: kết quả, xung đột thì hợp nhất theo từng trường (bản sửa sau thắng)
  SE->>DB: ghi kết quả hợp nhất
  Note over CK,E: Nhận (push im lặng / mở app)
  CK-->>E: fetchedRecordZoneChanges
  E-->>SE: bản ghi + xoá
  SE->>DB: ghi trong transaction, ValueObservation báo màn
  SE-->>M: sự kiện gửi/nhận/lỗi
  M-->>M: SyncStatus (đã đồng bộ, chờ, chưa đăng nhập iCloud, lỗi)
```

Mọi chi tiết gửi, nhận và hợp nhất do SQLiteData lo. Phần ta tự làm chỉ có: danh sách bảng (`SyncTables`), `SyncStatusMonitor` cho badge (BR-SYNC-01), và gọi sync khi mở app. LOS-030 đo hành vi thật: lệch giờ, cột lạ từ phiên bản mới hơn, giết app giữa lô. Kiểm: TC-SYNC-05..08, 12, 13, 15.

## 8. Luồng: lần đầu dùng và máy mới

```mermaid
stateDiagram-v2
  [*] --> Welcome
  Welcome --> CheckCloud: Bắt đầu
  CheckCloud --> Seed: iCloud bật, chưa có dữ liệu trên iCloud
  CheckCloud --> FirstSync: iCloud bật, đã có dữ liệu (máy mới)
  CheckCloud --> LocalOnly: iCloud tắt
  Seed --> Ready: tạo dữ liệu mẫu bằng ID v5
  LocalOnly --> Seed
  FirstSync --> Ready: skeleton "Đang tải dữ liệu từ iCloud" lần đầu
  Ready --> [*]
```

MVP không có khoá chủ hay mã khôi phục. Dữ liệu mẫu dùng ID v5, nên hai máy cùng tạo kho sẽ ghi vào cùng bản ghi, không sinh hai bộ danh mục. Màn Chào mừng nói đúng mức bảo vệ (BR-ONB-10). Kiểm: TC-ONB-03, 05, 07.

## 9. Luồng: tick việc và hoàn tác

```mermaid
sequenceDiagram
  participant V as TaskRow
  participant S as TasksStore
  participant R as TaskRepository
  V->>S: toggle(id)
  S->>R: complete(id, at)
  S->>V: UndoToast "Đã xong · Hoàn tác" (4 giây)
  alt bấm Hoàn tác / ⌘Z trong 4 giây
    V->>S: undo()
    S->>R: reopen(id) — một lần ghi mới (không "xoá" lịch sử)
  else hết giờ
    S->>S: bỏ token hoàn tác
  end
```

Hoàn tác là một thay đổi mới, không phải rollback, để hội tụ đúng khi máy khác đã nhận thay đổi trước. Kiểm: TC-TSK-04.

## 10. Luồng: nhắc nhở cục bộ (sau MVP)

```mermaid
flowchart LR
  E1[tick thói quen] --> RS[ReminderScheduler.reschedule]
  E2[đồng bộ xong] --> RS
  E3[đổi cài đặt nhắc] --> RS
  RS --> Q{Máy này là máy nhắc chính?}
  Q -->|không| Z[Huỷ hết thông báo đang chờ]
  Q -->|có| C[Tính tối đa 64 thông báo sắp tới]
  C --> N[UNUserNotificationCenter: thay toàn bộ]
```

## 11. Ánh xạ luồng → code

| Luồng | Thành phần chính | Target |
|---|---|---|
| Khởi động | `LifeOSApp`, `prepareDependencies`, `AppEnvironment.live()`, `AppDatabase`, `TodayStore` | App, AppFeature, Persistence, TodayFeature |
| Ghi thay đổi | `SQLite*Repository` | Persistence |
| Ghi nhanh | `QuickCaptureParser`, `CaptureStore` | Capture, CaptureFeature |
| Đồng bộ | `CloudSync.makeEngine`, `SyncTables`, `SyncStatusMonitor` | CloudSync |
| Khoá (sau MVP) | `KeyVault`, `RecoveryCode`, `EnvelopeCodec`, `CryptoKitProvider`, `KeychainStore` | CryptoCore, CryptoApple |
| Hoàn tác | `UndoCoordinator` (FeatureSupport), `UndoToast` | FeatureSupport, DesignSystem |
