# ADR-0017: Ports & Adapters (Clean Architecture rút gọn) cho lớp dữ liệu; Feature chỉ biết Domain

- Trạng thái: Chấp nhận (01/11/2026)
- Ngày: 2026-11-01
- Sửa đổi: ADR-0007, ADR-0008, ADR-0016 (ranh giới 3)
- Liên quan: docs/architecture/overview.md, module-structure.md, recipes.md, references.md (nguồn trích dẫn)

## Bối cảnh
Người dùng muốn kiến trúc theo mẫu phổ biến, đã được chứng minh, để agent biết rõ mỗi thứ đặt ở đâu và dùng lại thứ đã có.

Bản trước đặt protocol repository và kiểu snapshot trong `Persistence` (gói `LifeOSData`). Vì vậy mọi Feature phải import gói dữ liệu, và repository giả không thể nằm trong `TestSupport`, vì `TestSupport` thuộc lõi chạy Linux.

## Quyết định
Life OS ghép bốn mẫu đã được dùng rộng rãi. Mỗi mẫu lo một tầng:

| Tầng | Mẫu | Nguồn (references.md) | Ở Life OS |
|---|---|---|---|
| Phụ thuộc giữa lớp | **Ports & Adapters** (Hexagonal), "dependency rule" của **Clean Architecture** | [S-HEX] Cockburn 2005; [S-CLEAN] Martin 2012 | `Domain` định nghĩa port (protocol) và read model. `Persistence`, `CloudSync`, `PlatformServices` là adapter. Mũi tên phụ thuộc chỉ hướng vào `Domain`. |
| Chia module | **Module theo tính năng** trên SwiftPM (µFeatures) | [S-TMA] Tuist TMA; [S-ISO] isowords; [S-APPLE-PKG] | Mỗi tính năng là một target `<X>Feature`, không import nhau |
| Trạng thái UI | **Model `@Observable` do View sở hữu bằng `@State`** | [S-OBS] [S-MODEL] Apple | ADR-0007 giữ nguyên |
| Gốc ghép | **Composition Root** | [S-ROOT] Seemann 2011; [S-SQLD] cấu hình ở điểm vào app | Chỉ `AppFeature` tạo cài đặt cụ thể |

Quy tắc phụ thuộc, kiểm bằng build và `scripts/check_structure.py`:

```
Feature ──▶ FeatureSupport ──▶ Domain ◀── Persistence ◀── CloudSync
   │                                ▲            ▲
   └──▶ DesignSystem                │            │
AppFeature (gốc ghép) ──────────────┴────────────┴──▶ PlatformServices
```

- `Domain/Ports/`: `protocol TaskRepository`, `protocol TodayReading`, `AppClock`, `LogSink`…
- `Domain/ReadModels/`: các snapshot (`TodaySnapshot`, `TaskGroupsSnapshot`…) là struct `Sendable`, đã định hình cho UI.
- `Persistence` cài đặt port: `SQLiteTaskRepository: TaskRepository`.
- `TestSupport` chứa bản giả cho mọi port (`FakeTaskRepository`), chạy được trên Linux.
- Feature target chỉ phụ thuộc `FeatureSupport`, `Domain` và `DesignSystem`. **Không** phụ thuộc `Persistence`.

## Chỗ khác với mẫu gốc
- S-TMA cho mỗi tính năng một target Interface và một target Testing. Life OS gom port vào `Domain/Ports` và bản giả vào `TestSupport`, vì mọi tính năng đọc cùng một DB; 9 target Interface sẽ gấp đôi số target mà không tách thêm được gì. **[Dự án]**
- S-CLEAN có lớp Use Cases. Life OS dùng hàm thuần trong `Domain/Rules`. **[Dự án]**
- Đúng theo S-CLEAN, dữ liệu qua ranh giới là struct đơn giản (`…Snapshot`), không phải `@Table` row.

## Lựa chọn đã cân nhắc
| Lựa chọn | Feature bị khoá vào thư viện DB | Test store trên Linux | Số file thêm | Ghi chú |
|---|---|---|---|---|
| Port trong Persistence (bản trước) | Có | Không | 0 | Đơn giản hơn chút |
| **Port trong Domain** | Không | Có | Port + bản giả | **Chọn**. Thay SQLiteData hay lớp đồng bộ không chạm Feature |
| Clean Architecture đầy đủ (UseCase/Interactor cho mọi thao tác) | Không | Có | Nhiều | Thừa cho app một người; dùng hàm thuần trong `Domain/Rules` thay UseCase |

## Hệ quả
- Không có lớp UseCase riêng. Logic nghiệp vụ là hàm thuần trong `Domain/Rules`. Store gọi rule và port; repository chỉ đọc và ghi.
- Thêm một nguồn dữ liệu mới thì đi theo thứ tự: port ở Domain → bản giả ở TestSupport → adapter ở Persistence → nối trong AppFeature (recipes.md R4).
- Tín hiệu xem lại: Store phình quá 200 dòng vì logic điều phối. Khi đó tách "coordinator" thuần vào `Domain/Rules`, không thêm UseCase cho mọi thứ.
