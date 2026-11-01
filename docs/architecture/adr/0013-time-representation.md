# ADR-0013: Ngày lịch là chuỗi, mốc thời gian là ms UTC

- Trạng thái: Chấp nhận
- Liên quan: BR-GEN-02, data-model.md

## Quyết định
- **Ngày lịch** (hạn việc, ngày check-in thói quen, ngày nhật ký, ngày giao dịch): `TEXT 'YYYY-MM-DD'` theo lịch Gregory, là ngày **theo múi giờ của thiết bị lúc thao tác**. Không lưu kèm múi giờ. Đi du lịch không làm dời ngày đã ghi.
- **Mốc thời gian** (created_at, updated_at, completed_at, deleted_at): `INTEGER` mili-giây Unix UTC.
- **Giờ trong ngày** (giờ nhắc): `TEXT 'HH:mm'` giờ địa phương.
- **Tháng** (ngân sách): `TEXT 'YYYY-MM'`. **Tuần**: bắt đầu thứ Hai, khoá bằng ngày thứ Hai `'YYYY-MM-DD'`.
- Tiền: `INTEGER` đơn vị nhỏ nhất của tiền tệ (VND không có xu → số đồng) + `currency TEXT` mặc định `'VND'`.

## Hệ quả
- So sánh/sắp xếp ngày bằng so sánh chuỗi, có index, không cần hàm ngày của SQLite.
- Không có kiểu `Date` cho ngày lịch trong Domain: dùng `LocalDate` (struct năm-tháng-ngày) và `LocalMonth`.
