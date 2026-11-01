# ADR-0003: SQLite qua GRDB 7, quy tắc schema đồng bộ được

- Trạng thái: Chấp nhận
- Liên quan: data-model.md, ADR-0004, ADR-0014

## Bối cảnh
Cần chi phí mỗi hàng thấp, khởi động nhanh, widget mở chung DB, chạy được trên Linux/Android, và chèn được logic đồng bộ + E2EE của mình.

## Quyết định
Dùng **GRDB.swift 7.x** (ghim bản chính xác trong `Package.resolved`) với `DatabasePool` (WAL), file DB trong App Group container, Data Protection class C (`completeUntilFirstUserAuthentication`). Mọi bảng đồng bộ tuân theo:
1. Khoá chính `id TEXT` (UUID dạng chữ thường). Không `AUTOINCREMENT`.
2. Không ràng buộc `UNIQUE` nào ngoài khoá chính. Khoá tự nhiên (thói quen + ngày) giải bằng ID tất định (ADR-0014).
3. Không `FOREIGN KEY ... ON DELETE CASCADE`; xoá là tombstone (`deleted_at`). Khoá ngoại khai báo không có ràng buộc thi hành (đồng bộ có thể đến lệch thứ tự).
4. Migration chỉ **thêm**: thêm bảng, thêm cột có mặc định. Không xoá/đổi tên cột đồng bộ. Cột bỏ thì để đó, ghi `-- deprecated` trong migration.
5. Mỗi migration là một file `Migrations/M0001_<ten>.swift`, đã phát hành thì không sửa.

## Lựa chọn đã cân nhắc
| Lựa chọn | Chi phí mỗi hàng / RAM | Linux/Android | Hợp sync tự viết + E2EE | Rủi ro |
|---|---|---|---|---|
| **GRDB 7** | Thấp | Có (từ 7.10) | Hoàn toàn | Thấp |
| SQLiteData (Point-Free) trên GRDB | Thấp | Chưa rõ | Phần query; sync chỉ CloudKit | Thấp–vừa |
| SwiftData | Cao | Không | Khó | Lỗi iOS 26.x |
| Core Data | Vừa | Không | Khó | Thấp |

## Hệ quả
- Không dùng `UPDATE` hàng loạt bằng SQL thô trên bảng đồng bộ: mọi ghi đi qua `SyncWriter` để sinh thay đổi (SPEC-sync §5).
- Truy vấn đọc vẫn là SQL thường trên bảng thường → nhanh.
- Có thể dùng thêm `@FetchAll` của SQLiteData ở UI nếu spike LOS-021 xác nhận chạy được khi không bật SyncEngine (decisions-open D2).
