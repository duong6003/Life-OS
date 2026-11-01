# Quy trình: viết spec một màn từ design tham chiếu

Đầu vào: tên màn (ví dụ `tasks`). Đầu ra: `docs/design/screens/<màn>.md` theo `docs/design/screens/_template.md`.

1. Mở frame tương ứng trong `design/reference/screens.html` bằng trình duyệt hoặc Playwright. Xem mọi thiết bị (iPhone, iPad, Mac) và mọi trạng thái (rỗng, đang tải, lỗi).
2. Lấy hành vi từ `docs/product/business-rules.md`, câu chữ từ HTML, dữ liệu từ `docs/architecture/data-model.md`.
3. Chỉ dùng component có trong bảng ánh xạ của `Packages/LifeOSDesignSystem/README.md`. Thiếu component thì ghi vào mục câu hỏi.
4. Ghi snapshot màn cần (tên `<X>Snapshot`, các trường) để bước sau làm query theo `recipes.md` R5.
5. Liệt kê mọi câu hỏi chưa rõ ở cuối file, rồi hỏi người dùng trước khi code.
