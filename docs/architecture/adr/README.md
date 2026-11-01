# ADR (Architecture Decision Records)

Mỗi quyết định kiến trúc là một file đánh số, **không sửa nội dung sau khi Chấp nhận**: muốn đổi thì viết ADR mới và đánh dấu ADR cũ "Thay thế bởi". Mẫu ở `0000-template.md`.

| # | Quyết định | Trạng thái |
|---|---|---|
| 0001 | Local-first, không máy chủ riêng | Chấp nhận (31/10/2026) |
| 0002 | Swift thuần, Apple trước; Android sau theo spec | Chấp nhận (31/10/2026) |
| 0003 | SQLite qua GRDB 7, quy tắc schema đồng bộ được | Chấp nhận |
| 0004 | Hợp nhất: HLC + LWW theo trường + tombstone (mô hình Actual) | Chấp nhận |
| 0005 | Kênh: CKSyncEngine sau protocol `SyncTransport`, payload tự mã hoá | Chấp nhận; cách đóng gói bản ghi chờ spike LOS-030 |
| 0006 | Mã hoá: CryptoKit, envelope có version, khoá chủ + mã khôi phục | Chấp nhận |
| 0007 | Kiến trúc app: store `@Observable`, không TCA, tiêm phụ thuộc qua init | Chấp nhận |
| 0008 | Module: 4 gói SPM cục bộ, app target mỏng, lõi build được trên Linux | Chấp nhận |
| 0009 | Token design một nguồn, sinh code lúc build | Chấp nhận |
| 0010 | Nền tảng tối thiểu iOS 26 / iPadOS 26 / macOS 26 | Đề xuất (xem decisions-open D3) |
| 0011 | CI: GitHub Actions Linux cho lõi, Xcode Cloud cho app | Đề xuất (D5) |
| 0012 | Nội dung nhật ký xung đột: giữ cả hai bản | Chấp nhận |
| 0013 | Biểu diễn ngày giờ: ngày lịch là chuỗi, mốc thời gian là ms UTC | Chấp nhận |
| 0014 | ID: UUIDv7 cho bản ghi thường, UUIDv5 cho khoá tự nhiên | Chấp nhận |
| 0015 | Quy trình thiết kế: repo là nguồn sự thật, Claude dùng để khám phá | Đề xuất (D1) |
