# Issue tracker: markdown trong repo + GitHub

**Nguồn sự thật là `docs/plan/issues/LOS-xxx-<slug>.md`.** GitHub Issues (`duong6003/Life-OS`) là bản sao, sinh bằng `scripts/bootstrap_github.py`. Tiêu đề trên GitHub có dạng `[LOS-xxx] <title>`; ánh xạ LOS → số issue ở `scripts/.issue-map.json`.

## Thao tác

- **Tạo issue**: chép một file LOS gần giống làm mẫu, đặt số LOS kế tiếp còn trống, điền front matter (`id`, `title`, `milestone`, `labels`, `depends_on`, `size`) và các mục `Mục tiêu / Việc cần làm / Tiêu chí nghiệm thu / Tham chiếu / Phụ thuộc`. Kiểm bằng `python3 -I scripts/plan_graph.py --check`, rồi đẩy lên bằng `python3 scripts/bootstrap_github.py --repo duong6003/Life-OS --apply` (bỏ `--apply` để xem trước).
- **Đọc issue**: đọc file md. Comment chỉ có trên GitHub: `gh issue view <số> --json number,title,body,labels,comments`.
- **Liệt kê**: `ls docs/plan/issues/`, hoặc `gh issue list --state open --json number,title,labels` kèm `--label`.
- **Sửa nội dung, nhãn, phụ thuộc**: sửa front matter/thân file md, rồi chạy bootstrap. **Không** chỉ sửa trên GitHub: bootstrap ghi đè thân bài và gỡ mọi nhãn không có trong front matter.
- **Blocked by**: ghi vào `depends_on` trong front matter; bootstrap tạo quan hệ trên GitHub.
- **Comment**: `gh issue comment <số> --body "..."` (comment không lưu trong md).
- **Đóng**: PR ghi `Closes #<số>`, hoặc `gh issue close <số> --comment "..."`.

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Đổi thành `yes` nếu muốn `/triage` xét cả PR bên ngoài.)_

## Khi skill nói "publish to the issue tracker"

Tạo file `docs/plan/issues/LOS-xxx-*.md` như trên rồi chạy bootstrap.

## Khi skill nói "fetch the relevant ticket"

Đọc file md; cần comment thì đọc thêm trên GitHub.

## Wayfinding

`/wayfinder` chưa dùng trong repo này. Lộ trình và phụ thuộc nằm ở `docs/plan/roadmap-graph.md` (sinh bởi `scripts/plan_graph.py`).
