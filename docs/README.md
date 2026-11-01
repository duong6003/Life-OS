# Bản đồ tài liệu

Mọi tài liệu viết tiếng Việt; tên trong code viết tiếng Anh. Tài liệu là **hợp đồng**: code mâu thuẫn với tài liệu thì sửa một trong hai trong cùng PR, không để lệch.

| Thư mục | Nội dung | Khi nào đổi |
|---|---|---|
| `product/` | Phạm vi MVP, thuật ngữ, **business rules** (BR-xxx) | Khi đổi hành vi người dùng thấy |
| `agents/` | Dùng repo với Codex, Claude Code…: AGENTS.md, quy trình, prompt dán sẵn | Khi đổi quy trình làm việc |
| `architecture/` | **overview** (mẫu kiến trúc, khi nào dùng gì; đọc trước khi code), **recipes** (từng bước cho mỗi loại thay đổi), **references** (nguồn best practice), **inventory** (tự sinh), system design, cấu trúc module, mô hình dữ liệu, **ADR** | Khi đổi cấu trúc; quyết định mới = ADR mới; inventory sinh bằng script |
| `specs/` | SPEC-sync, SPEC-crypto, SPEC-quick-capture: đủ chi tiết để viết lại bằng Kotlin | Đổi spec = tăng version + cập nhật test vector |
| `engineering/` | Quy ước code, chất lượng code (SwiftLint, Periphery, skill agent), testing, quy trình git/PR/CI, ngân sách hiệu năng, threat model | Khi đổi cách làm việc |
| `design/` | Quy trình thiết kế: design nằm ở đâu, lấy thế nào, khi nào dùng Claude | Khi đổi công cụ |
| `plan/` | Graph phụ thuộc + từng issue (nguồn để tạo GitHub Issues) | Khi thêm/bỏ hạng mục |
| `test-cases/` | Test case theo module (TC-xxx), ánh xạ tới BR-xxx | Cùng PR với tính năng |
| `decisions-open.md` | Các lựa chọn còn mở, dạng bảng so sánh, có gợi ý mặc định | Khi bạn chốt: chuyển thành ADR |

## Mã tham chiếu chéo

- `BR-TSK-03`: business rule (module Việc, số 3). Test case ghi `Covers: BR-TSK-03`.
- `TC-TSK-07`: test case. Test Swift đặt tên `test_TC_TSK_07_...` để tìm được bằng grep.
- `ADR-0004`: quyết định kiến trúc. Code có lựa chọn không hiển nhiên thì comment `// ADR-0004`.
- `LOS-012`: issue trong `plan/issues/`. Commit và PR ghi `LOS-012`.
- `SPEC-sync §4.2`: mục trong spec.
