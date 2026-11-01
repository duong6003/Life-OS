# LifeOSFeatures
Một target mỗi tính năng: `<Name>Screen` + `<Name>Store` + `Components/` + `Strings/Localizable.xcstrings` + `Previews/`.
- Có spec màn ở `docs/design/screens/` trước khi code. Chỉ dùng component/token của DesignSystem.
- Store test bằng repository giả; tên test `test_TC_…`.
- Chỉ `AppFeature` import `LifeOSPlatform` và tạo cài đặt cụ thể.
