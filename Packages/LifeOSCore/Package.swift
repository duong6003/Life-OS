// swift-tools-version: 6.2
// LifeOSCore: Swift thuần, build và test được trên Linux (ADR-0002, ADR-0008).
// KHÔNG thêm phụ thuộc vào framework chỉ có trên Apple. Kiểm bằng scripts/check-core-imports.sh.
import PackageDescription

let package = Package(
    name: "LifeOSCore",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Capture", targets: ["Capture"]),
        .library(name: "SyncCore", targets: ["SyncCore"]),
        .library(name: "CryptoCore", targets: ["CryptoCore"]),
        .library(name: "Persistence", targets: ["Persistence"]),
        .library(name: "TestSupport", targets: ["TestSupport"]),
    ],
    dependencies: [
        // Ghim bản chính xác qua Package.resolved (commit vào git). Thêm phụ thuộc mới cần ADR.
        .package(url: "https://github.com/groue/GRDB.swift", from: "7.10.0"),
    ],
    targets: [
        .target(name: "Domain"),
        .target(name: "Capture", dependencies: ["Domain"]),
        .target(name: "SyncCore", dependencies: ["Domain"]),
        .target(name: "CryptoCore", dependencies: ["Domain"]),
        .target(
            name: "Persistence",
            dependencies: ["Domain", "SyncCore", .product(name: "GRDB", package: "GRDB.swift")],
            resources: [.copy("Migrations/sql")]
        ),
        .target(name: "TestSupport", dependencies: ["Domain", "SyncCore", "CryptoCore"]),
        .testTarget(name: "DomainTests", dependencies: ["Domain", "TestSupport"]),
        .testTarget(name: "CaptureTests", dependencies: ["Capture", "TestSupport"]),
        .testTarget(name: "SyncCoreTests", dependencies: ["SyncCore", "TestSupport"]),
        .testTarget(name: "CryptoCoreTests", dependencies: ["CryptoCore", "TestSupport"]),
        .testTarget(name: "PersistenceTests", dependencies: ["Persistence", "TestSupport"]),
    ],
    swiftLanguageModes: [.v6]
)
