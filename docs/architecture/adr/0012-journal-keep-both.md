# ADR-0012: Nội dung nhật ký xung đột thì giữ cả hai bản

- Trạng thái: Chấp nhận (đã thể hiện trong design 31/10)
- Liên quan: SPEC-sync §6.3, BR-JRN-05

## Quyết định
Trường `journal_entry.body` dùng chính sách `keepBoth`. Khi hai thiết bị cùng sửa nội dung từ cùng một bản gốc (cùng `base`), bản thắng HLC nằm ở `body`, bản kia lưu vào bảng `journal_conflict`. UI hiện cả hai trong bài, không chặn màn; "Bỏ bản này" có Hoàn tác. Các trường khác của mục nhật ký (tâm trạng, năng lượng) vẫn LWW.

## Lựa chọn
| | Không mất chữ | Tài nguyên | Port | Ghi chú |
|---|---|---|---|---|
| **Giữ cả hai** | Có | ~0 | Dễ | Người dùng tự gộp |
| Automerge cho văn bản | Có, tự gộp | Thêm lõi Rust, chưa đo | Có binding | Xét lại khi có số đo |
| LWW | Mất một bên | 0 | Dễ | Không chấp nhận |
