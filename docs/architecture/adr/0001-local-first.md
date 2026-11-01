# ADR-0001: Local-first, không máy chủ riêng

- Trạng thái: Chấp nhận · 2026-10-31 (người dùng chốt)
- Liên quan: ADR-0004, ADR-0005, ADR-0006

## Bối cảnh
Life OS chứa dữ liệu rất riêng tư (nhật ký, tâm trạng, thu chi). Mục tiêu là không có hạ tầng phải vận hành, không chi phí theo người dùng, mở app là có dữ liệu ngay.

## Quyết định
Nguồn sự thật là SQLite trong máy. Mọi đọc/ghi diễn ra cục bộ, không chờ mạng. Đồng bộ là việc nền, chạy qua cloud của chính người dùng (bắt đầu với iCloud). Không có tài khoản, đăng nhập hay máy chủ của Life OS. Cloud chỉ thấy dữ liệu đã mã hoá.

## Lựa chọn đã cân nhắc
| Lựa chọn | Hiệu năng | Chi phí vận hành | Riêng tư | Ghi chú |
|---|---|---|---|---|
| **Local-first + cloud người dùng** | Tốt nhất (0 chờ mạng) | 0 | E2EE | Đồng bộ phải tự làm cẩn thận |
| Server riêng + client cache | Phụ thuộc mạng | Có, tăng theo người dùng | Phụ thuộc mình | Không hợp mục tiêu |
| Chỉ lưu trong máy | Tốt | 0 | Tốt | Không dùng được nhiều thiết bị |

## Hệ quả
- Ngoại tuyến không phải lỗi; UI không có trạng thái "đang tải" khi đã có dữ liệu.
- Mất thiết bị + mất mã khôi phục = mất dữ liệu đã mã hoá. Phải nói rõ với người dùng (BR-ONB-04).
- Nhắc nhở dùng thông báo cục bộ (không có push server).
- Tính năng cần máy chủ (chia sẻ với người khác, AI trên cloud) phải có ADR riêng.
