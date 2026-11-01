# ADR-0002: Swift thuần, Apple trước; Android sau theo spec

- Trạng thái: Chấp nhận · 2026-10-31 (phương án A)
- Liên quan: ADR-0008, SPEC-sync, SPEC-crypto

## Bối cảnh
Ưu tiên số 1 là mượt và nhẹ. Native SwiftUI dùng framework hệ thống (0 byte thêm), có Liquid Glass, widget, App Intents. Android cần có về sau.

## Quyết định
App Apple viết hoàn toàn bằng Swift 6 + SwiftUI. Lõi (Domain, Capture, SyncCore, CryptoCore, Persistence) là gói SwiftPM không import framework chỉ có trên Apple, build và test được trên Linux. Hợp đồng cho Android là `docs/specs/*` + `TestVectors/`: bản Kotlin (port bằng agent) hoặc lõi Swift chạy trên Android (Swift SDK cho Android, Swift 6.3) đều phải qua hết test vector.

## Lựa chọn đã cân nhắc
| Lựa chọn | Hiệu năng iOS | Đường Android | Công | Trạng thái |
|---|---|---|---|---|
| **A. Swift thuần + spec** | Tốt nhất | Port theo spec hoặc lõi Swift | Vừa | **Chọn** |
| Rust core + UI native | Tốt | Dùng lại lõi | Cao (FFI, 2 UI) | Loại |
| SwiftData + CloudKit | Kém hơn (object nặng) | Không | Thấp | Loại: khoá chặt, không E2EE riêng |
| KMP / Compose Multiplatform | Thêm ~9 MB | Tốt | Vừa | Loại: đi ngược Swift thuần |

## Hệ quả
- CI Linux là hàng rào: lõi lỡ `import CloudKit` là đỏ (`scripts/check-core-imports.sh`).
- Mọi định dạng trên dây (HLC, payload, envelope) viết trong spec trước, code sau.
