# Threat model (v1)

> **MVP (ADR-0016):** chưa có mã hoá tự làm. Với kẻ tấn công đọc được iCloud (không bật Advanced Data Protection), dữ liệu MVP **không** được che. Các biện pháp crypto bên dưới áp dụng từ LOS-075. Biện pháp vẫn áp dụng trong MVP: không log nội dung, Data Protection trên máy, khoá app bằng Face ID.

Tài sản: nội dung nhật ký, tâm trạng, thu chi, việc; khoá chủ MK; mã khôi phục RC.

| # | Mối đe doạ | Có bảo vệ? | Bằng cách |
|---|---|---|---|
| T1 | Ai đó đọc được iCloud (lộ, trát, nhân viên) | Có | Payload mã hoá bằng K_row; recordName là HMAC; Apple chỉ thấy kích thước, thời điểm, số bản ghi |
| T2 | Kẻ trộm máy đã khoá | Có | Data Protection class C + mã máy; MK trong Keychain `AfterFirstUnlock` |
| T3 | Rò khoá qua log, crash report, bộ nhớ tạm | Có | Không log nội dung/khoá (conventions §8); chép mã chỉ `localOnly` + hết hạn 2 phút; RC không selectable |
| T4 | Sửa/tráo payload trên cloud | Có | AEAD + AAD gắn recordName và header; payload sai → `Tampered`, bỏ qua, không ghi |
| T5 | Phát lại bản ghi cũ (rollback) | Một phần | HLC trong payload: bản cũ thua LWW. Không chống được xoá bản ghi trên cloud (chỉ mất đồng bộ, không mất dữ liệu cục bộ) |
| T6 | Người dùng mất cả máy lẫn mã | **Không** (theo thiết kế) | Nói rõ (BR-ONB-04); khuyến khích in mã |
| T7 | Người cầm máy đang mở khoá | Một phần | Face ID gate [Mở rộng]; không chống được người đã có mã máy |
| T8 | Mã độc trên máy đã jailbreak | Không | Ngoài phạm vi |
| T9 | Dò mã khôi phục offline từ KeyBundle | Có | ≈126 bit entropy: không khả thi; không cần KDF chậm |
| T10 | Lỗi lập trình làm lộ bản rõ lên cloud | Có (kiểm) | Transport chỉ nhận `Envelope` (kiểu riêng, không phải `Data`); TC-CRY-03 |

Ngoài phạm vi v1: kênh bên (side channel), tấn công vào chuỗi cung ứng Apple, ép buộc người dùng.
