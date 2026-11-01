# ADR-0004: Hợp nhất bằng HLC + LWW theo trường + tombstone

- Trạng thái: Hoãn tới sau MVP bởi ADR-0016 (MVP dùng SyncEngine của SQLiteData; LOS-075)
- Liên quan: SPEC-sync, ADR-0012, TestVectors/hlc, TestVectors/merge

## Bối cảnh
Dữ liệu Life OS phần lớn dạng bảng. Nhiều thiết bị sửa ngoại tuyến. Không có máy chủ làm trọng tài. Nghiên cứu (31/10) khuyên chép mô hình đã chạy thật của Actual Budget thay vì tự nghĩ.

## Quyết định
Mỗi trường của mỗi hàng đồng bộ mang một nhãn **HLC** (hybrid logical clock: ms vật lý + bộ đếm + node). Hợp nhất từng trường: nhãn lớn hơn thắng (LWW). Xoá là trường `deleted_at` cũng hợp nhất theo LWW. Chính sách riêng theo trường: `lww` (mặc định), `keepBoth` (nội dung nhật ký, ADR-0012), `max` (bộ đếm chỉ tăng nếu cần). Bảng/cột lạ (từ phiên bản mới hơn) được giữ nguyên dạng thô, không làm lỗi.

## Lựa chọn đã cân nhắc
| Chiến lược | Đúng cho Life OS | Tài nguyên | Port Android | Ghi chú |
|---|---|---|---|---|
| **LWW theo trường + HLC** | Tốt cho dữ liệu bảng | Thấp | Dễ | Actual, SQLiteData cùng hướng |
| CRDT toàn DB (cr-sqlite, Automerge) | Quá mức | Cao | Khó | Thư viện ngừng/nặng |
| LWW cả hàng | Mất sửa đổi | Thấp | Dễ | Hai máy sửa hai trường khác nhau → mất một |
| Trộn văn bản heuristic | Nhân đôi đoạn | — | — | Bài học Obsidian |

## Hệ quả
- Phải có harness kiểm thử tất định nhiều thiết bị (LOS-033) trước khi bật đồng bộ cho người dùng.
- Bất biến giữa các trường (ví dụ "đã xong thì phải có completed_at") không được giả định sau hợp nhất; code đọc phải chịu được tổ hợp lạ (BR-SYNC-05).
