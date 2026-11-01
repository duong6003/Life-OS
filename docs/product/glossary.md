# Thuật ngữ

| Hiển thị (tiếng Việt) | Trong code | Nghĩa |
|---|---|---|
| Hôm nay | `Today` | Màn trung tâm |
| Việc | `TaskItem` (tránh trùng `Task` của Swift concurrency), bảng `task` | Việc cần làm |
| Danh mục (việc) | `Area` | Nhóm việc: Công việc, Sức khỏe… |
| Inbox | `inbox` | Việc chưa xếp, đến từ Ghi nhanh |
| Thói quen | `Habit` | |
| Check-in (thói quen) | `HabitLog` | Một lần đánh dấu trong ngày |
| Chuỗi | `streak` | Số ngày theo lịch liên tiếp đã làm |
| Nhật ký | `JournalEntry` | Một mục mỗi ngày |
| Tâm trạng | `mood` (1–5) | Tệ, Không ổn, Bình thường, Tốt, Tuyệt |
| Năng lượng | `energy` (1–5) | Kiệt sức, Mệt, Vừa, Khỏe, Tràn đầy |
| Check-in tối | `EveningCheckIn` | Tâm trạng + năng lượng + một dòng |
| Thu chi | `Spending` (module), `Transaction` (entity), bảng `txn` | |
| Khoản chi / khoản thu | `kind = expense / income` | |
| Ngân sách | `Budget` | Hạn mức chi theo tháng |
| Review tuần | `WeeklyReview` | Tuần bắt đầu thứ Hai |
| Ghi nhanh | `QuickCapture` | Ô nhập hiểu mọi loại |
| Mã khôi phục | `RecoveryCode` | 28 ký tự, mở kho trên máy mới (sau MVP, ADR-0016) |
| Khoá chủ | `MasterKey` (MK) | 32 byte, không bao giờ hiện cho người dùng |
| Kho | `Vault` | Toàn bộ dữ liệu dưới một MK |
| Chờ đồng bộ | `SyncStatus.pending` | Đã lưu trong máy, chưa gửi |
| Máy nhắc chính | `primaryReminderDevice` | Thiết bị duy nhất bắn thông báo nhắc |
| [Mở rộng] | `ext` | Thiết kế có nhưng không thuộc MVP |
