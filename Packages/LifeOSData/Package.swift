// swift-tools-version: 6.2
// LifeOSData: lưu trữ và đồng bộ cho MVP, dựng trên SQLiteData (Point-Free) + GRDB. Chỉ Apple. ADR-0016.
// Persistence: DB, migration, repository, query. KHÔNG nhắc tới SyncEngine.
// CloudSync:   nơi DUY NHẤT tạo và cấu hình SyncEngine (CloudKit). Sau MVP thay target này bằng lớp tự làm (LOS-075).
import PackageDescription

let package = Package(
    name: "LifeOSData",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "Persistence", targets: ["Persistence"]),
        .library(name: "CloudSync", targets: ["CloudSync"]),
    ],
    dependencies: [
        .package(path: "../LifeOSCore"),
        // Ghim bản chính xác qua Package.resolved (commit vào git). Thêm phụ thuộc mới cần ADR.
        .package(url: "https://github.com/pointfreeco/sqlite-data", from: "1.12.0"),
        .package(url: "https://github.com/groue/GRDB.swift", from: "7.6.0"),
    ],
    targets: [
        .target(
            name: "Persistence",
            dependencies: [
                .product(name: "Domain", package: "LifeOSCore"),
                .product(name: "SQLiteData", package: "sqlite-data"),
                .product(name: "GRDB", package: "GRDB.swift"),
            ],
            resources: [.copy("Migrations/sql")]
        ),
        .target(
            name: "CloudSync",
            dependencies: [
                "Persistence",
                .product(name: "SQLiteData", package: "sqlite-data"),
            ]
        ),
        .testTarget(name: "PersistenceTests", dependencies: [
            "Persistence",
            .product(name: "TestSupport", package: "LifeOSCore"),
            .product(name: "SQLiteDataTestSupport", package: "sqlite-data"),
        ]),
    ],
    swiftLanguageModes: [.v6]
)
