# Test case: đồng bộ, mã hoá, bắt đầu

> **Phạm vi theo ADR-0016 (01/11/2026).** MVP dùng SyncEngine của SQLiteData, chưa có HLC, outbox, envelope hay mã khôi phục.
> - **Chạy trong MVP:** TC-SYNC-05, 06, 07, 08, 12, 13, 14, 15; TC-ONB-03, 05, 07. Với SYNC-06, 07, 08 và 13, kiểm hành vi của SyncEngine, không kiểm `sync_outbox` hay `sync_unknown`. Badge chờ chỉ hiện "Chờ đồng bộ" mà không đếm số thay đổi, trừ khi SyncEngine cho đếm (LOS-026 kiểm).
> - **Sau MVP (LOS-075):** TC-SYNC-00..04, 09, 10, 11; mọi TC-CRY; TC-ONB-01, 02, 04, 06.

## SYNC
| ID | Kiểm | Bước / dữ liệu | Mong đợi | Covers | Mức |
|---|---|---|---|---|---|
| TC-SYNC-00 | HLC = vector | `TestVectors/hlc/*.json` | 100% khớp: định dạng, thứ tự, chuỗi tick/receive, lỗi | SPEC-sync §2 | V |
| TC-SYNC-01 | Một transaction | Sửa 2 cột của việc, giết process giữa chừng (fault injection) | Hoặc cả dữ liệu + field clock + outbox, hoặc không gì | SPEC-sync §5 | I |
| TC-SYNC-02 | Field clock đúng cột | Sửa `title` | Chỉ `title` có HLC mới; `due_on` giữ HLC cũ | SPEC-sync §5 | I |
| TC-SYNC-03 | Không đường ghi tắt | Test duyệt mọi repository với DB "bẫy" (trigger đếm UPDATE không có outbox) | 0 vi phạm | SPEC-sync §5 | I |
| TC-SYNC-04 | Hợp nhất = vector | `TestVectors/merge/cases.json`, `ids.json` | 100% khớp | BR-SYNC-02/03, BR-HAB-03 | V |
| TC-SYNC-05 | Tổ hợp lạ sau merge | `status=open`, `completed_at≠null` | UI coi là chưa xong, không crash | BR-SYNC-05 | U |
| TC-SYNC-06 | Cột/bảng lạ | Nhận payload có cột `color2` và bảng `goal` | Cột bị bỏ qua, payload vào `sync_unknown`; sau migration giả lập thêm cột → áp lại đúng | BR-SYNC-07 | I |
| TC-SYNC-07 | Badge chờ | Ngoại tuyến, sửa 3 thứ | "Chờ đồng bộ · 3 thay đổi" (đếm hàng trong outbox) | BR-SYNC-01 | S |
| TC-SYNC-08 | Lỗi chỉ ở badge | FakeTransport trả lỗi mạng 10 lần | Không alert; badge "Chưa đồng bộ được"; tự thử lại | BR-GEN-08 | S |
| TC-SYNC-09 | Gửi xong khi có sửa mới | Sửa lúc lô đang gửi | Hàng vẫn ở outbox sau khi gửi xong (enqueued_at đổi) | SPEC-sync §7 | I |
| TC-SYNC-10 | Registry = schema vector | So `SyncSchemaRegistry` với `TestVectors/merge/schema.json` | Khớp hoàn toàn | data-model §3 | U |
| TC-SYNC-11 | Harness hội tụ | 3 máy ảo, 10.000 vòng ngẫu nhiên (seed cố định), lệch giờ ±10 phút, rớt mạng giữa lô | Mọi bảng giống hệt nhau; không mất bản nhật ký nào | SPEC-sync §10 | U |
| TC-SYNC-12 | CloudKit thật | 2 thiết bị thật, cùng Apple ID: sửa ngoại tuyến cả hai, bật mạng | Hội tụ trong < 1 phút khi app mở; đúng như harness | ADR-0005 | M |
| TC-SYNC-14 | Ranh giới đồng bộ | `bash scripts/check-core-imports.sh` | `SyncEngine` chỉ xuất hiện trong `LifeOSData/Sources/CloudSync` và `AppFeature` | ADR-0016 | CI |
| TC-SYNC-15 | Schema hợp lệ cho SyncEngine | Tạo SyncEngine với mọi bảng đồng bộ trên DB đã migrate (test trên macOS) | Khởi tạo không lỗi; thêm `UNIQUE` vào một bảng thử thì báo lỗi | ADR-0016 | I |
| TC-SYNC-13 | Change token sau khi lưu | Giết app ngay sau khi nhận lô | Lần mở sau nhận lại lô đó (không mất), áp lại không đổi kết quả | SPEC-sync §7 | I (FakeTransport) |

## CRY
| ID | Kiểm | Bước / dữ liệu | Mong đợi | Covers | Mức |
|---|---|---|---|---|---|
| TC-CRY-00 | Envelope = vector | `TestVectors/envelope/*.json` (CryptoKitProvider) | Seal với nonce cố định ra đúng byte; open đúng; 4 lỗi đúng loại | SPEC-crypto §4 | V |
| TC-CRY-01 | Dẫn khoá = vector | `keys.json`, `record-names.json` | Khớp hex | SPEC-crypto §2 | V |
| TC-CRY-02 | Mã khôi phục = vector | `recovery-code/cases.json` | generate, normalize, invalid, kek, rkid, keyBundle khớp | SPEC-crypto §3 | V |
| TC-CRY-03 | Không lộ khoá | Grep log, UserDefaults, file tạm sau toàn bộ luồng | Không có MK/RC | threat-model T3 | I, M |
| TC-CRY-04 | Nonce không lặp | 1 triệu lần seal | Không trùng nonce | SPEC-crypto §4 | U |
| TC-CRY-05 | Chặn hai MK | 2 máy cùng tạo kho mới với FakeTransport | Một KeyBundle; máy thua hỏi mã, sau khi nhập: dữ liệu cục bộ được mã hoá lại và gửi đi; không bản ghi nào lên cloud bằng MK thua | BR-ONB-08 | I |
| TC-CRY-06 | Đổi mã | Đổi mã, thử mở bằng mã cũ trên máy mới | Mã cũ: "Mã chưa đúng"; mã mới mở được | BR-ONB-09 | I |

## ONB
| ID | Kiểm | Bước / dữ liệu | Mong đợi | Covers | Mức |
|---|---|---|---|---|---|
| TC-ONB-01 | Luồng đầu | Chào mừng → Bắt đầu → Cất mã → "Tôi đã cất giữ" → nhập nhóm số k | Nhóm k ngẫu nhiên; đúng → vào app; sai → quay lại xem mã | BR-ONB-02 | UI |
| TC-ONB-02 | Bảo vệ mã | Thử chọn chữ; chép; đợi 2 phút | Không chọn được; bộ nhớ tạm có `localOnly`, hết hạn sau 2 phút | BR-ONB-03 | UI, M |
| TC-ONB-03 | Máy mới có Keychain | Cài trên iPad cùng Apple ID | Không hỏi mã; skeleton lần đầu; dữ liệu về | BR-ONB-05 | M |
| TC-ONB-04 | Nhập mã | "K7QO…" ; mã sai đủ 28 ký tự | "Có ký tự đọc nhầm: O" ngay khi gõ; "Mã chưa đúng" sau khi gửi | BR-ONB-06 | S |
| TC-ONB-05 | Không iCloud | Tắt iCloud, dùng app một tuần dữ liệu | Mọi tính năng chạy; bật iCloud → tải KeyBundle + toàn bộ dữ liệu lên | BR-ONB-07 | M, I |
| TC-ONB-07 | Nói đúng mức bảo vệ | Mở màn Bắt đầu và Cài đặt › Bảo mật | Có câu của BR-ONB-10; không có chữ "mã hoá đầu-cuối" như mặc định | BR-ONB-10 | UI |
| TC-ONB-06 | Khôi phục máy sạch | Xoá app trên mọi máy, xoá Keychain item; cài lại, nhập mã | Toàn bộ dữ liệu về, nhật ký đọc được | SPEC-crypto §6.2 | M (cổng GĐ3) |
