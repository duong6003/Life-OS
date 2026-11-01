# ADR-0008: 4 gói SPM cục bộ, app target mỏng, lõi build được trên Linux

- Trạng thái: Chấp nhận
- Liên quan: module-structure.md, ADR-0002

## Bối cảnh
`Package.swift` dễ cho agent sửa hơn `.pbxproj`. Lõi phải build trên Linux (hàng rào CI) và Android. Build nhỏ, preview ổn định.

## Quyết định
Một Xcode project mỏng trong `App/` (chỉ `@main`, Info.plist, entitlements, icon) + 4 gói SwiftPM cục bộ:
`LifeOSCore` (Swift thuần) → `LifeOSPlatform` (adapter Apple) và `LifeOSDesignSystem` (UI token) → `LifeOSFeatures` (màn hình). Chiều phụ thuộc chỉ đi xuống; vi phạm là lỗi build hoặc lỗi script `check-core-imports.sh`. Phụ thuộc ngoài được ghim trong `Package.resolved` (commit vào git).

Phụ thuộc ngoài cho phép trong MVP: **GRDB.swift**. Thêm thư viện nào nữa cần ADR.

## Lựa chọn đã cân nhắc
| Cách | Công cụ thêm | Agent sửa dễ | Linux CI | Khi nào |
|---|---|---|---|---|
| **4 gói theo lớp** | Không | Dễ | `swift test` thẳng trong LifeOSCore | Mặc định |
| 1 gói nhiều target (LifeOSKit) | Không | Dễ | Phải build theo từng target | Gọn hơn, nhưng dễ lỡ kéo SwiftUI vào lõi |
| Tuist / XcodeGen | Có | Vừa | — | Khi build chậm hoặc xung đột project (decisions-open D6) |

## Hệ quả
- Mỗi tính năng là một target trong `LifeOSFeatures`; tính năng không import lẫn nhau, chỉ qua `FeatureSupport` và `Domain`.
