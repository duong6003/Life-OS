# ADR-0006: Mã hoá bằng CryptoKit, envelope có version, khoá chủ + mã khôi phục

- Trạng thái: Chấp nhận
- Liên quan: SPEC-crypto, threat-model.md, BR-ONB-*

## Bối cảnh
Mã hoá sẵn có của CloudKit chỉ E2EE khi người dùng bật Advanced Data Protection. Life OS hứa E2EE mặc định. Không có máy chủ nên không có mô hình PIN + HSM. Không muốn thêm binary (libsodium, SQLCipher) và thủ tục xuất khẩu.

## Quyết định
- Thuật toán: ChaCha20-Poly1305 (nonce 12 byte), HKDF-SHA256, tất cả qua **CryptoKit**; lõi chỉ thấy protocol `CryptoProvider`.
- Khoá chủ (MK) 256 bit ngẫu nhiên, sinh một lần cho cả "kho" dữ liệu, có `keyId`.
- MK được giữ theo hai đường: (a) iCloud Keychain item `synchronizable` (thiết bị Apple mới tự mở được), (b) **mã khôi phục** 28 ký tự (bảng 23 ký tự, ≈126 bit) bọc MK; bản MK đã bọc nằm trong cloud.
- Bản ghi nhỏ dùng envelope `LOS1` (SPEC-crypto §4). File xuất/snapshot dùng định dạng **age v1** (sau MVP).
- Cục bộ: Data Protection class C cho DB; nội dung nhật ký mã hoá thêm ở mức trường bằng khoá con của MK.
- Không mật khẩu, không đăng nhập. Face ID chỉ là cổng UI ([Mở rộng]).

## Lựa chọn đã cân nhắc
| Lựa chọn | Dung lượng | Port Android | Xuất khẩu | Ghi chú |
|---|---|---|---|---|
| **CryptoKit + chuẩn IETF** | 0 | Primitive chuẩn (Tink/JCA/BouncyCastle) | Nhóm "chỉ dùng mã hoá của OS" | Không có Argon2 → không dùng mật khẩu |
| libsodium | +vài trăm KB | Byte-tương thích | Phải khai | Ente dùng |
| SQLCipher | ~6,5 MB, tốn CPU | Có | Phải khai | Không cần |

## Hệ quả
- Phải chặn "hai thiết bị cùng sinh hai MK" (SPEC-crypto §6.3).
- Mất cả iCloud Keychain lẫn mã khôi phục = mất dữ liệu cloud. UI nói rõ (BR-ONB-04).
- Đổi thuật toán về sau = version envelope mới; bản cũ vẫn đọc được.
