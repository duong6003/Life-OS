# Ngân sách hiệu năng (ưu tiên số 1)

| Chỉ số | Bắt buộc | Mục tiêu | Đo |
|---|---|---|---|
| Khởi động lạnh tới Hôm nay có dữ liệu | p50 ≤ 400 ms | ≤ 300 ms | TC-PERF-01 |
| Hitch khi cuộn | ≤ 10 ms/s | ≤ 5 ms/s | TC-PERF-02/03 |
| Hang | 0 lần > 250 ms | — | Organizer, Instruments |
| Tương tác (tick, lưu, đổi tab) | < 100 ms | < 50 ms | signpost |
| Việc của app mỗi khung (120 Hz) | ≤ 4 ms trong 8,3 ms | — | SwiftUI instrument |
| Truy vấn SQL cho một màn | ≤ 10 ms trên DB seed | ≤ 3 ms | TC-PERF-04/10 |
| Dung lượng tải về | ghi lại; PR tăng > 500 KB bị chặn (ngoại lệ một lần: thêm sqlite-data, ≤ 3 MB, ADR-0016) | giả thuyết 5–10 MB | TC-PERF-08 |
| RAM rảnh | ghi lại; tăng > 10% phải giải thích | giả thuyết 20–40 MB | TC-PERF-07 |
| Widget (sau MVP) | < 30 MB | < 15 MB | Instruments |

Việc **không** được làm khi khởi động: mạng, giải mã hàng loạt, CKSyncEngine, lên lịch thông báo, `VACUUM`. Tất cả để sau khung hình đầu. `VACUUM`/`ANALYZE` chạy trong một `BGProcessingTask` khi cắm sạc.
