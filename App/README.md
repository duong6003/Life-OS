# App/

Xcode project **mỏng** (ADR-0008). Tạo trong issue LOS-003:

1. Xcode → File → New → Project → **Multiplatform → App**. Product Name `LifeOS`, Interface SwiftUI, Storage **None**, tick "Include Tests". Lưu vào thư mục `App/` này (Xcode tạo `App/LifeOS.xcodeproj`).
2. Xoá `ContentView.swift` và file `LifeOSApp.swift` Xcode tạo; dùng file `LifeOS/LifeOSApp.swift` có sẵn ở đây.
3. Target → General: iOS 26.0, macOS 26.0. Build Settings: Swift Language Version 6, Strict Concurrency Complete.
4. File → Add Package Dependencies → Add Local… chọn `Packages/LifeOSFeatures` (kéo theo 3 gói kia). Link product `AppFeature`.
5. Signing & Capabilities: iCloud (CloudKit, container `iCloud.<bundle-id>`), App Groups (`group.<bundle-id>`), Keychain Sharing, Background Modes (Remote notifications, Background processing).
6. Không thêm code tính năng vào target này. Mọi thứ khác nằm trong `Packages/`.
