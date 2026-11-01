---
description: Làm một issue LOS từ đầu tới PR
argument-hint: <số issue GitHub hoặc LOS-xxx>
---
Làm issue $ARGUMENTS theo CLAUDE.md:
1. Đọc issue (GitHub hoặc docs/plan/issues), mọi BR/TC/SPEC/ADR nó nhắc. Kiểm phụ thuộc đã đóng; chưa thì dừng và báo.
2. `git pull`, tạo nhánh `los-<số>-<slug>`.
3. Nếu đụng định dạng trên dây: sửa spec + reference + vector trước. Nếu là màn: spec màn trước.
4. Viết test đỏ trước cho từng TC, rồi code cho xanh.
5. Chạy đủ lệnh ở mục "Lệnh" của CLAUDE.md.
6. Cập nhật tài liệu liên quan trong cùng nhánh.
7. Commit theo quy ước, push, mở PR theo mẫu với "Closes #<n>". Tóm tắt cho tôi bằng tiếng Việt: đã làm gì, số đo (nếu có), điều còn mở.
