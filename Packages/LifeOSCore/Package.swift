// swift-tools-version: 6.2
// LifeOSCore: Swift thuần, build và test được trên Linux (ADR-0002, ADR-0008).
// Không có phụ thuộc ngoài. KHÔNG thêm phụ thuộc vào framework chỉ có trên Apple. Kiểm bằng scripts/check-core-imports.sh.
import PackageDescription

let package = Package(
    name: "LifeOSCore",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Capture", targets: ["Capture"]),
        .library(name: "SyncCore", targets: ["SyncCore"]),
        .library(name: "CryptoCore", targets: ["CryptoCore"]),
        .library(name: "TestSupport", targets: ["TestSupport"]),
    ],
    targets: [
        .target(name: "Domain"),
        .target(name: "Capture", dependencies: ["Domain"]),
        .target(name: "SyncCore", dependencies: ["Domain"]),  // sau MVP (ADR-0016, LOS-075)
        .target(name: "CryptoCore", dependencies: ["Domain"]),  // sau MVP (ADR-0016, LOS-075)
        .target(name: "TestSupport", dependencies: ["Domain", "SyncCore", "CryptoCore"]),
        .testTarget(name: "DomainTests", dependencies: ["Domain", "TestSupport"]),
        .testTarget(name: "CaptureTests", dependencies: ["Capture", "TestSupport"]),
        .testTarget(name: "SyncCoreTests", dependencies: ["SyncCore", "TestSupport"]),
        .testTarget(name: "CryptoCoreTests", dependencies: ["CryptoCore", "TestSupport"]),
    ],
    swiftLanguageModes: [.v6]
)
