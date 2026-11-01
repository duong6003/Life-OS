# Phạm vi MVP (Giai đoạn 1)

Nguồn: [Bản đồ sản phẩm và lộ trình](https://claude.ai/artifact/H6CQuwxBGshJnk1ukMA7q1) (17 module, 4 giai đoạn), design system v8 (01/11/2026). MVP = 5 module + phần nền đã có thiết kế đầy đủ.

| Phần | Có trong MVP | Không có (để sau) |
|---|---|---|
| **Hôm nay** | Lời chào + ngày, thẻ Việc hôm nay/quá hạn, thẻ Thói quen, thẻ Chi tiêu tháng, thẻ Check-in, chip Inbox | Sắp xếp thẻ [Mở rộng] |
| **Ghi nhanh + Inbox** | Thanh "Ghi nhanh…" (iPhone), ⌘N (iPad/Mac), hiểu việc/chi/thu, Inbox | Cú pháp của module GĐ2 |
| **Việc** | Hôm nay, Quá hạn, Sắp tới, Inbox; thêm/sửa/xoá, ưu tiên, danh mục, hạn; tick + Hoàn tác | Kéo thả dời ngày, dự án, lặp lại |
| **Thói quen** | Danh sách, tick hôm nay, chuỗi hiện tại, heatmap, lịch theo thứ | Mục tiêu đếm, giờ nhắc, ngày nghỉ, chuỗi dài nhất [Mở rộng] |
| **Nhật ký + Tâm trạng** | Check-in tối: tâm trạng 1–5, năng lượng 1–5, một dòng; viết bài; giữ cả hai bản khi xung đột | Hoạt động, ảnh, lịch năm |
| **Thu chi** | Ghi khoản, danh mục, ngân sách tháng tổng, biểu đồ tháng, đổi tháng ở tiêu đề | Tìm kiếm, khoản định kỳ, ngân sách theo danh mục |
| **Review tuần** | Tổng hợp tuần, tự chấm, 3 câu suy ngẫm, chọn tối đa 3 trọng tâm | Xem tuần trước, tháng/quý/năm |
| **Bắt đầu & khôi phục** | Chào mừng, mã khôi phục + kiểm tra, máy mới, chưa bật iCloud, lỗi dữ liệu | Face ID, 3 bước "Lần đầu dùng" |
| **Cài đặt** | Tên hiển thị, Bảo mật và khôi phục (xem/đổi mã), trạng thái đồng bộ, xuất dữ liệu JSON | Giao diện, nhắc nhở, module |
| **Nền tảng** | iPhone, iPad, Mac (một target đa nền tảng) | Widget, Control Center, Android, web |

## "Mở đường ngay từ MVP" (roadmap, mặc định là làm)
1. Cột `project_id`, `goal_id` rỗng trong `task`, `habit`, `txn` (đã có trong schema).
2. Thẻ Hôm nay dùng chung một mẫu "thẻ module" (`TodayCard`).
3. Bộ hiểu Ghi nhanh trả kết quả có trường loại; thêm loại = thêm nhánh.
4. Review tuần: mỗi module góp một khối theo cùng mẫu.
5. Điều hướng: MVP 5 tab; quy tắc ">4 module" chỉ ghi trong spec, chưa code.
6. Cài đặt có chỗ cho mục "Module" (ẩn trong MVP).

## Tiêu chí "xong MVP"
- Mọi BR có trạng thái "MVP" trong `business-rules.md` có test xanh.
- Cổng hiệu năng TC-PERF-01..06 đạt trên thiết bị thật cũ nhất.
- Harness đồng bộ 10.000 vòng xanh; khôi phục trên máy sạch bằng mã khôi phục thành công.
- Dùng thật 2 tuần trên ≥ 2 thiết bị không mất dữ liệu.
