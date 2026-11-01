# System design: đồng bộ mã hoá tự làm (sau MVP)

Bản thiết kế gốc ngày 01/11/2026, trước ADR-0016. Áp dụng khi làm LOS-075: thay `CloudSync` (SQLiteData SyncEngine) bằng lớp tự làm theo SPEC-sync và SPEC-crypto. Đọc cùng `system-design.md`.

## P1. Bối cảnh (C4 mức 1)

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

## P2. Container và lớp (C4 mức 2)

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

## P5. Luồng: ghi một thay đổi (mọi tính năng)

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

## P7. Luồng: đồng bộ (gửi và nhận)

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

## P8. Luồng: lần đầu dùng và máy mới

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

