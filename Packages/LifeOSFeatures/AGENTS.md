# AGENTS.md — LifeOSFeatures
Luật riêng của gói, bổ sung cho AGENTS.md ở gốc repo.
Một target mỗi tính năng: `<Name>Screen` + `<Name>Store` + `Components/` + `Strings/Localizable.xcstrings` + `Previews/`.
- Có spec màn ở `docs/design/screens/` trước khi code. Chỉ dùng component/token của DesignSystem.
- Store phụ thuộc port trong `Domain/Ports`; test bằng `Fake…` từ `TestSupport/Fakes`; tên test `test_TC_…`.
- Feature **không** import `Persistence`, `CloudSync`, `LifeOSPlatform` (ADR-0017, check_structure.py kiểm). Chỉ `AppFeature` (gốc ghép) import chúng và tạo cài đặt cụ thể.
- Tạo màn: `python3 scripts/new.py screen <Feature> <Name>`; các bước ở docs/architecture/recipes.md R1.
