# System design

Tài liệu này mô tả hệ thống bằng sơ đồ (Mermaid, GitHub hiển thị trực tiếp). Mỗi luồng có: sơ đồ, quy tắc thread/actor, điểm lỗi, và test case kiểm nó. **Code một luồng = đi đúng các bước trong sơ đồ, đúng tên thành phần.** Đổi luồng thì sửa sơ đồ trong cùng PR.

## 1. Bối cảnh (C4 mức 1)

```mermaid
flowchart LR
  U([Người dùng]) -->|chạm, gõ, ⌘N| APP[Life OS<br/>iPhone · iPad · Mac]
  APP <-->|payload đã mã hoá<br/>CKSyncEngine| CK[(iCloud private DB<br/>của người dùng)]
  APP <-->|MK synchronizable| KC[(iCloud Keychain)]
  APP -->|thông báo cục bộ| OS[iOS / macOS<br/>Notification Center]
  APP <-->|đọc chung DB| W["Widget · App Intents<br/>(sau MVP)"]
  U -.->|giữ mã khôi phục<br/>trên giấy / nơi khác| RK[[Mã khôi phục]]
```

Không có máy chủ Life OS. iCloud chỉ thấy ciphertext + vài trường kỹ thuật (`v`, `kid`, recordName ngẫu nhiên).

## 2. Container và lớp (C4 mức 2)

```mermaid
flowchart TB
  subgraph App["App/ (target mỏng)"]
    MAIN["LifeOSApp @main<br/>tạo AppEnvironment"]
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
  subgraph Platform["Packages/LifeOSPlatform (chỉ Apple)"]
    CKT[CloudKitTransport<br/>CKSyncEngine]
    CA[CryptoApple<br/>CryptoKit + Keychain]
    PL[PlatformServices<br/>thông báo, BGTask, Face ID, MetricKit]
  end
  subgraph Core["Packages/LifeOSCore (Swift thuần, Linux)"]
    DOM[Domain<br/>entity, rule, LocalDate]
    CAP[Capture<br/>bộ hiểu Ghi nhanh]
    SYN[SyncCore<br/>HLC, merge, outbox, SyncTransport]
    CRY[CryptoCore<br/>envelope, key tree, CryptoProvider]
    PER[Persistence<br/>GRDB, migration, repository, SyncWriter]
    TS[TestSupport]
  end
  MAIN --> AF
  AF --> TF & TK & HF & JF & SF & RF & CF & OF & STF
  TF & TK & HF & JF & SF & RF & CF & OF & STF --> FS
  FS --> DSY
  FS --> DOM
  AF --> CKT & CA & PL & PER
  CKT --> SYN
  CKT --> CRY
  CA --> CRY
  PER --> SYN
  PER --> DOM
  SYN --> DOM
  CAP --> DOM
  CF --> CAP
  classDef f fill:#eef,stroke:#88a
```

Quy tắc mũi tên (bị kiểm bằng build + `scripts/check-core-imports.sh`):
- `LifeOSCore` không import `SwiftUI`, `UIKit`, `AppKit`, `CloudKit`, `CryptoKit`, `Security`, `os`, `Combine`, `WidgetKit`. Chỉ `Foundation` (bản swift-corelibs) và `GRDB` (chỉ trong `Persistence`).
- Feature không import feature khác. Feature không import `LifeOSPlatform` (chỉ thấy protocol trong Core/FeatureSupport).
- Chỉ `AppFeature` biết cài đặt cụ thể (ghép DI).

## 3. Mô hình chạy (thread & actor)

| Thành phần | Chạy ở đâu | Ghi chú |
|---|---|---|
| View, Store | `@MainActor` | Store chỉ giữ snapshot giá trị; không I/O |
| Repository, `SyncWriter` | `DatabasePool` của GRDB (hàng đợi riêng) | `async` API; ghi luôn trong `write { }` |
| `ValueObservation` | Đọc trên pool, giao kết quả `.immediate` lần đầu rồi về main | Lần đầu đồng bộ để không nháy "đang tải" |
| `SyncCoordinator` | `actor` riêng | Nhận sự kiện CKSyncEngine, gọi merge, ghi DB |
| Crypto | Gọi trong `SyncCoordinator` / repository, ngoài main | Giải mã nhật ký khi mở bài, không giải mã cả danh sách |
| Định dạng số/ngày | `FormatterCache` tạo một lần | Không tạo formatter trong `body` |

## 4. Luồng: khởi động lạnh tới màn Hôm nay (mục tiêu ≤ 400 ms)

```mermaid
sequenceDiagram
  autonumber
  participant OS as iOS
  participant App as LifeOSApp
  participant Env as AppEnvironment
  participant DB as Database (GRDB)
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
  App->>Env: start SyncCoordinator (CKSyncEngine), lên lịch thông báo
```

Điểm lỗi: migration lỗi → màn "File dữ liệu trong máy hỏng" (BR-GEN-05), không crash. Kiểm: TC-PERF-01, TC-GEN-03.

## 5. Luồng: ghi một thay đổi (mọi tính năng)

```mermaid
sequenceDiagram
  autonumber
  participant V as View
  participant S as Store (@MainActor)
  participant R as Repository
  participant W as SyncWriter
  participant DB as SQLite
  participant O as ValueObservation
  V->>S: toggleTask(id)
  S->>S: cập nhật lạc quan snapshot (tuỳ chọn) + haptic
  S->>R: complete(taskId, at: now)
  R->>W: write { db in ... }
  W->>W: hlc = clock.tick()
  W->>DB: UPDATE task SET status, completed_at, updated_at
  W->>DB: UPSERT sync_field_clock (task,id,col,hlc) cho từng cột đổi
  W->>DB: UPSERT sync_outbox (task,id)
  DB-->>O: thay đổi trong transaction
  O-->>S: snapshot mới
  S-->>V: vẽ lại đúng hàng đổi
  W-->>SyncCoordinator: notify outbox changed (nếu đồng bộ bật)
```

Bất biến: **một thay đổi người dùng = một transaction** gồm dữ liệu + đồng hồ trường + outbox. Không có đường ghi nào vòng qua `SyncWriter` cho bảng đồng bộ. Kiểm: TC-SYNC-01..03.

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
  participant W as SyncWriter
  participant C as SyncCoordinator (actor)
  participant E as CKSyncEngine
  participant K as CryptoProvider
  participant DB as SQLite
  participant CK as iCloud
  W->>C: outboxChanged
  C->>E: state.add(pendingRecordZoneChanges: .save(recordID))
  E->>C: nextRecordZoneChangeBatch (theo lịch hệ thống)
  C->>DB: đọc hàng + sync_field_clock
  C->>K: seal(RowPayload, aad)
  C-->>E: CKRecord{payload, v, kid}
  E->>CK: modify (≤250 bản ghi/lô)
  CK-->>E: saved / serverRecordChanged
  alt saved
    E->>C: sentRecordZoneChanges(saved)
    C->>DB: xoá khỏi sync_outbox nếu hlc không đổi
  else serverRecordChanged
    C->>K: open(server payload)
    C->>C: merge(local, server) theo trường
    C->>DB: ghi kết quả (transaction)
    C->>E: xếp gửi lại
  end
  Note over CK,E: Nhận (push im lặng / mở app)
  CK-->>E: fetchedRecordZoneChanges
  E->>C: records + deletions
  C->>K: open(payload) — lỗi kid lạ → trạng thái needsRecoveryKey
  C->>C: merge từng trường theo HLC, clock.receive(remote)
  C->>DB: ghi dữ liệu + field clock + state serialization (một transaction)
```

Điểm lỗi và cách xử lý: SPEC-sync §8. Kiểm: TC-SYNC-*, harness LOS-033.

## 8. Luồng: lần đầu dùng và máy mới

```mermaid
stateDiagram-v2
  [*] --> Welcome
  Welcome --> CheckCloud: Bắt đầu
  Welcome --> Restore: "Tôi đã dùng Life OS trên máy khác"
  CheckCloud --> FindKey: iCloud bật
  CheckCloud --> LocalOnly: iCloud tắt
  FindKey --> Ready: MK có trong iCloud Keychain
  FindKey --> Restore: Có KeyBundle trên cloud, Keychain trống
  FindKey --> CreateVault: Không có KeyBundle
  LocalOnly --> CreateVault
  CreateVault --> ShowCode: sinh MK + mã khôi phục
  ShowCode --> VerifyCode: "Tôi đã cất giữ"
  VerifyCode --> Ready: nhập đúng 1 nhóm 4 ký tự
  VerifyCode --> ShowCode: sai → xem lại
  Restore --> Ready: mở KeyBundle bằng mã
  Restore --> Restore: sai mã (báo ký tự lạ ngay)
  Ready --> [*]
```

Chi tiết và chặn "hai MK": SPEC-crypto §6. Kiểm: TC-ONB-*.

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
    S->>R: reopen(id) — ghi mới với HLC mới (không "xoá" lịch sử)
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
| Khởi động | `LifeOSApp`, `AppEnvironment.live()`, `DatabaseFactory`, `TodayStore` | App, AppFeature, Persistence, TodayFeature |
| Ghi thay đổi | `SyncWriter`, `HybridLogicalClock`, `*Repository` | Persistence, SyncCore |
| Ghi nhanh | `QuickCaptureParser`, `CaptureStore` | Capture, CaptureFeature |
| Đồng bộ | `SyncCoordinator`, `SyncTransport`, `CloudKitSyncTransport`, `RowPayloadCodec`, `Merger` | SyncCore, CloudKitTransport |
| Khoá | `KeyVault`, `RecoveryCode`, `EnvelopeCodec`, `CryptoKitProvider`, `KeychainStore` | CryptoCore, CryptoApple |
| Hoàn tác | `UndoCoordinator` (FeatureSupport), `UndoToast` | FeatureSupport, DesignSystem |
