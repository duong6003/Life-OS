# Tài liệu miền (domain docs)

Repo một ngữ cảnh. Vị trí khác mặc định của skill:

- **Thuật ngữ**: `docs/product/glossary.md` (thay cho `GLOSSARY.md` ở gốc).
- **ADR**: `docs/architecture/adr/NNNN-<slug>.md` (thay cho `docs/adr/`); mục lục ở `docs/architecture/adr/README.md`. Lựa chọn còn mở: `docs/decisions-open.md`.
- Luật nghiệp vụ, spec, test case: `docs/product/`, `docs/specs/`, `docs/test-cases/`.

## Trước khi khám phá

Đọc glossary và các ADR liên quan tới vùng sắp làm. Thiếu thì làm tiếp, không đề xuất tạo trước; `/domain-modeling` bổ sung khi có thuật ngữ hoặc quyết định thật sự được chốt (ghi vào đúng các đường dẫn trên, không tạo `GLOSSARY.md` hay `docs/adr/`).

## Dùng đúng thuật ngữ

Khi đặt tên khái niệm miền (tiêu đề issue, đề xuất refactor, tên test), dùng đúng từ trong glossary, cả cột tiếng Việt lẫn cột "Trong code" (ví dụ `TaskItem`, không phải `Task`). Khái niệm chưa có trong glossary là dấu hiệu: hoặc đang tự đặt từ mới (cân nhắc lại), hoặc có lỗ hổng thật (ghi lại cho `/domain-modeling`).

## Báo xung đột ADR

Nếu kết quả trái một ADR, nói rõ thay vì lặng lẽ làm khác:

> _Trái ADR-0016 (SQLiteData cho MVP), nhưng đáng mở lại vì…_
