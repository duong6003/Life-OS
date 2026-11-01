# Plan dạng graph

Nguồn: mỗi file trong [`issues/`](issues) là một issue (frontmatter: milestone, nhãn, `depends_on`). Graph dưới đây **sinh tự động** bằng `python3 scripts/plan_graph.py`; CI kiểm nó không cũ và không có vòng phụ thuộc. Đổi plan = sửa file issue, chạy script, commit cả hai.

Lên GitHub: `scripts/bootstrap_github.py` tạo milestone, nhãn, issue và quan hệ **blocked by** từ cùng các file này.

Cách đọc: mũi tên A → B nghĩa là B cần A xong trước. Ô vàng là **cổng** (gate) có số đo. Viền đỏ là đường găng (chuỗi dài nhất, quyết định tiến độ). Song song được: các màn M2 với nhau, và luồng Bắt đầu (M3) sau khi KeyVault xong; spike CloudKit (LOS-030) chạy được ngay khi có Xcode project và CryptoApple.

<!-- graph:begin -->
```mermaid
flowchart LR
  subgraph M0["M0 Nền móng"]
    LOS001["LOS-001<br/>Đưa bộ khung lên GitHub và tạo issue"]
    LOS002["LOS-002<br/>Build lần đầu các gói Swift và sửa lỗi biên dịch"]
    LOS003["LOS-003<br/>Tạo App/LifeOS.xcodeproj đa nền tảng"]
    LOS004["LOS-004<br/>CI Linux cho lõi xanh"]
    LOS005["LOS-005<br/>Dựng artifact Design System Life OS trong Claude"]
    LOS006["LOS-006<br/>Chuyển bảng ký tự mã khôi phục sang CryptoCore"]
  end
  subgraph M1["M1 Lõi dữ liệu cục bộ"]
    LOS010["LOS-010<br/>Domain: LocalDate, LocalMonth, Money, EntityID, UUIDv7/v5"]
    LOS011["LOS-011<br/>Domain: entity và business rule thuần"]
    LOS012["LOS-012<br/>SyncCore: Hybrid Logical Clock"]
    LOS013["LOS-013<br/>CryptoCore: envelope, dẫn khoá, mã khôi phục"]
    LOS014["LOS-014<br/>SyncCore: Merger thuần"]
    LOS015["LOS-015<br/>Capture: port bộ hiểu Ghi nhanh v1 sang Swift"]
    LOS016["LOS-016<br/>Ghi nhanh v1.1: sửa 4 lỗi đã biết"]
    LOS020["LOS-020<br/>Persistence: AppDatabase và migration đầu"]
    LOS021["LOS-021<br/>Spike: SQLiteData @FetchAll không cần SyncEngine"]
    LOS022["LOS-022<br/>Sinh DB seed 3 năm để đo hiệu năng"]
    LOS023["LOS-023<br/>SyncWriter, field clock, outbox, schema registry"]
    LOS024["LOS-024<br/>Repository và Query cho MVP"]
    LOS025["LOS-025<br/>Cổng M1: lõi dữ liệu cục bộ"]
    LOS050["LOS-050<br/>CryptoApple: CryptoKitProvider và Keychain"]
    LOS051["LOS-051<br/>KeyVault: tạo kho, giữ MK, mã hoá trường"]
  end
  subgraph M2["M2 MVP cục bộ"]
    LOS035["LOS-035<br/>Khung app: AppEnvironment, điều hướng, FeatureSupport"]
    LOS040["LOS-040<br/>Ghi nhanh: thanh, sheet, xem trước, toast"]
    LOS041["LOS-041<br/>Màn Việc"]
    LOS042["LOS-042<br/>Màn Thói quen"]
    LOS043["LOS-043<br/>Nhật ký và check-in tối"]
    LOS044["LOS-044<br/>Màn Thu chi"]
    LOS045["LOS-045<br/>Review tuần"]
    LOS046["LOS-046<br/>Cài đặt (MVP)"]
    LOS047["LOS-047<br/>Màn Hôm nay"]
    LOS048["LOS-048<br/>Cổng M2: MVP cục bộ trên máy thật"]
  end
  subgraph M3["M3 Bắt đầu và khôi phục"]
    LOS052["LOS-052<br/>Bắt đầu và khôi phục"]
    LOS053["LOS-053<br/>Bảo mật và khôi phục trong Cài đặt"]
  end
  subgraph M4["M4 Đồng bộ iCloud"]
    LOS030["LOS-030<br/>Spike: CKSyncEngine với payload mã hoá"]
    LOS031["LOS-031<br/>SyncCoordinator, RowPayloadCodec, FakeTransport"]
    LOS032["LOS-032<br/>CloudKitSyncTransport và KeyBundle"]
    LOS033["LOS-033<br/>Harness đồng bộ tất định nhiều máy"]
    LOS034["LOS-034<br/>Trạng thái đồng bộ thật trên UI"]
    LOS036["LOS-036<br/>Cổng M4: đồng bộ trên 2 thiết bị thật"]
  end
  subgraph M5["M5 Hoàn thiện và beta"]
    LOS060["LOS-060<br/>Xcode Cloud: build, test, TestFlight"]
    LOS061["LOS-061<br/>UI test và test hiệu năng tự động"]
    LOS062["LOS-062<br/>Đối chiếu test case với test"]
    LOS063["LOS-063<br/>MetricKit, Organizer và nhật ký số đo"]
    LOS064["LOS-064<br/>Dùng thật 2 tuần trên ≥ 2 thiết bị"]
    LOS065["LOS-065<br/>Cổng MVP: TestFlight beta"]
  end
  subgraph M6["M6 Sau MVP"]
    LOS070["LOS-070<br/>Widget tương tác (thói quen, top 3 việc)"]
    LOS071["LOS-071<br/>Nhắc nhở cục bộ và máy nhắc chính"]
    LOS072["LOS-072<br/>Sao lưu và xuất mã hoá định dạng age v1"]
    LOS073["LOS-073<br/>Android: đo lại và chọn đường"]
    LOS074["LOS-074<br/>Thiết kế GĐ2: Mục tiêu và Dự án"]
  end
  LOS001 --> LOS002
  LOS002 --> LOS003
  LOS002 --> LOS004
  LOS001 --> LOS005
  LOS002 --> LOS006
  LOS002 --> LOS010
  LOS010 --> LOS011
  LOS010 --> LOS012
  LOS010 --> LOS013
  LOS006 --> LOS013
  LOS012 --> LOS014
  LOS010 --> LOS015
  LOS015 --> LOS016
  LOS011 --> LOS020
  LOS012 --> LOS020
  LOS020 --> LOS021
  LOS020 --> LOS022
  LOS020 --> LOS023
  LOS014 --> LOS023
  LOS023 --> LOS024
  LOS011 --> LOS024
  LOS022 --> LOS025
  LOS024 --> LOS025
  LOS015 --> LOS025
  LOS013 --> LOS025
  LOS003 --> LOS030
  LOS050 --> LOS030
  LOS023 --> LOS031
  LOS013 --> LOS031
  LOS030 --> LOS032
  LOS031 --> LOS032
  LOS051 --> LOS032
  LOS031 --> LOS033
  LOS032 --> LOS034
  LOS047 --> LOS034
  LOS003 --> LOS035
  LOS024 --> LOS035
  LOS032 --> LOS036
  LOS033 --> LOS036
  LOS034 --> LOS036
  LOS053 --> LOS036
  LOS035 --> LOS040
  LOS015 --> LOS040
  LOS035 --> LOS041
  LOS035 --> LOS042
  LOS035 --> LOS043
  LOS051 --> LOS043
  LOS035 --> LOS044
  LOS041 --> LOS045
  LOS042 --> LOS045
  LOS043 --> LOS045
  LOS044 --> LOS045
  LOS035 --> LOS046
  LOS041 --> LOS047
  LOS042 --> LOS047
  LOS043 --> LOS047
  LOS044 --> LOS047
  LOS040 --> LOS048
  LOS045 --> LOS048
  LOS046 --> LOS048
  LOS047 --> LOS048
  LOS022 --> LOS048
  LOS013 --> LOS050
  LOS003 --> LOS050
  LOS050 --> LOS051
  LOS020 --> LOS051
  LOS051 --> LOS052
  LOS035 --> LOS052
  LOS052 --> LOS053
  LOS046 --> LOS053
  LOS003 --> LOS060
  LOS048 --> LOS061
  LOS060 --> LOS061
  LOS061 --> LOS062
  LOS060 --> LOS063
  LOS036 --> LOS064
  LOS061 --> LOS064
  LOS063 --> LOS064
  LOS064 --> LOS065
  LOS062 --> LOS065
  LOS065 --> LOS070
  LOS065 --> LOS071
  LOS065 --> LOS072
  LOS065 --> LOS073
  LOS005 --> LOS074
  LOS065 --> LOS074
  class LOS025 gate
  class LOS036 gate
  class LOS048 gate
  class LOS064 gate
  class LOS065 gate
  class LOS001,LOS002,LOS010,LOS011,LOS020,LOS023,LOS024,LOS035,LOS041,LOS045,LOS048,LOS061,LOS064,LOS065 crit
  classDef gate fill:#fde68a,stroke:#b45309
  classDef crit stroke:#dc2626,stroke-width:3px
```

| Milestone | Số issue | Issue |
|---|---|---|
| M0 Nền móng | 6 | LOS-001, LOS-002, LOS-003, LOS-004, LOS-005, LOS-006 |
| M1 Lõi dữ liệu cục bộ | 15 | LOS-010, LOS-011, LOS-012, LOS-013, LOS-014, LOS-015, LOS-016, LOS-020, LOS-021, LOS-022, LOS-023, LOS-024, LOS-025, LOS-050, LOS-051 |
| M2 MVP cục bộ | 10 | LOS-035, LOS-040, LOS-041, LOS-042, LOS-043, LOS-044, LOS-045, LOS-046, LOS-047, LOS-048 |
| M3 Bắt đầu và khôi phục | 2 | LOS-052, LOS-053 |
| M4 Đồng bộ iCloud | 6 | LOS-030, LOS-031, LOS-032, LOS-033, LOS-034, LOS-036 |
| M5 Hoàn thiện và beta | 6 | LOS-060, LOS-061, LOS-062, LOS-063, LOS-064, LOS-065 |
| M6 Sau MVP | 5 | LOS-070, LOS-071, LOS-072, LOS-073, LOS-074 |

**Đường găng** (viền đỏ, ước lượng S=1, M=2, L=3): LOS-001 → LOS-002 → LOS-010 → LOS-011 → LOS-020 → LOS-023 → LOS-024 → LOS-035 → LOS-041 → LOS-045 → LOS-048 → LOS-061 → LOS-064 → LOS-065
<!-- graph:end -->

## Thứ tự gợi ý cho một người + agent
1. Tuần 1: LOS-001 → 002 → 003, 004, 006 (song song: 005 thiết kế).
2. Tuần 2–3: 010 → 011, 012, 013, 015 → 014 → 020 → 023 → 024, 022 → cổng 025.
3. Tuần 3–4 (song song với lõi): 050 → 051 (CryptoKit, KeyVault).
4. Tuần 4–7: 035 → 040–047 (agent làm song song từng màn); 052 → 053; cổng 048.
5. Tuần 6–9: spike 030 sớm nhất có thể; 031 → 033, 032 → 034; cổng 036.
6. Tuần 10–12: 060 → 061 → 062, 063 → dùng thật 064 → beta 065.

Ước lượng tuần là giả định cho một người làm toàn thời gian có agent hỗ trợ; chưa có số liệu thật.
