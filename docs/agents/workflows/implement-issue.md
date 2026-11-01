# Quy trình: làm một issue LOS từ đầu tới PR

Dùng cho mọi agent. Đầu vào: số issue (`LOS-xxx` hoặc số trên GitHub). Luật nằm trong AGENTS.md; file này chỉ là thứ tự các bước.

1. **Đọc.** Mở `docs/plan/issues/LOS-xxx-*.md` (hoặc `gh issue view <n>`), đọc mọi BR, TC, SPEC, ADR nó nhắc tới. Kiểm các issue phụ thuộc đã đóng; chưa thì **dừng và báo**.
2. **Nhánh.** `git switch main && git pull`, rồi `git switch -c los-<số>-<slug>`.
3. **Tìm trước khi viết.** Đọc `docs/architecture/overview.md` §3 và §4, tra `docs/architecture/inventory.md`, chạy `rg` theo tên và mã BR. Đã có thứ gần giống thì mở rộng nó.
4. **Làm trước phần phải làm trước.** Đụng định dạng trên dây: sửa spec, `reference/` và vector trước. Làm màn: viết spec màn trước (`workflows/screen-spec.md`). Đụng schema: sửa `schema/*.sql` và `data-model.md` trước.
5. **Tạo file bằng `python3 scripts/new.py`**, theo công thức trong `docs/architecture/recipes.md`. Thứ tự từ trong ra: Domain → TestSupport → Persistence → Feature → AppFeature.
6. **Test đỏ trước** cho từng TC (tên `test_TC_<MOD>_<NN>_…`), rồi code cho xanh.
7. **Chạy đủ lệnh** ở mục "Lệnh" của AGENTS.md. Thêm type công khai thì chạy `python3 scripts/inventory.py`.
8. **Cập nhật tài liệu** liên quan trong cùng nhánh: BR, TC, spec, system-design, data-model.
9. **Commit** theo `type(scope): mô tả (LOS-xxx)`, push, mở PR theo `.github/pull_request_template.md` với "Closes #<n>" (`gh pr create`).
10. **Báo lại bằng tiếng Việt:** đã làm gì, số đo (nếu có), điều còn mở, và mọi chỗ đã chọn khác issue cùng lý do.

Không chắc về hành vi người dùng thấy, định dạng dữ liệu, hay bước không đảo ngược được thì hỏi, đừng đoán.
