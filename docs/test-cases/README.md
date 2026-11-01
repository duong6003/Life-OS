# Test case

| File | Phạm vi |
|---|---|
| `functional.md` | GEN, CAP, TSK, HAB, JRN, SPD, TDY, REV |
| `sync-crypto-onboarding.md` | SYNC, CRY, ONB |
| `nonfunctional.md` | PERF (hiệu năng), A11Y (trợ năng), DEV (thiết bị) |

**Mức**: `U` unit (Swift thuần, chạy Linux) · `I` integration (GRDB thật, DB tạm) · `S` store (store + repository giả) · `UI` XCUITest · `M` thủ công trên máy thật · `V` test vector · `CI` script kiểm trong CI.

Quy ước tên test Swift: `func test_TC_TSK_03_tickShowsUndoFor4Seconds()`. Một test có thể phủ nhiều TC; TC phải có ít nhất một test (trừ `M`). `scripts/tc_coverage.py` (LOS-062) liệt kê TC chưa có test.

Ngày giả mặc định trong test: **Thứ Sáu 30/10/2026 10:00 giờ Việt Nam**, người dùng "An" (giống dữ liệu demo của design).
