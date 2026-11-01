// swift-tools-version: 6.2
// LifeOSPlatform: adapter chỉ có trên Apple (CryptoKit, Keychain, CloudKit, thông báo, tác vụ nền). ADR-0008.
import PackageDescription

let package = Package(
    name: "LifeOSPlatform",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "CryptoApple", targets: ["CryptoApple"]),
        .library(name: "CloudKitTransport", targets: ["CloudKitTransport"]),
        .library(name: "PlatformServices", targets: ["PlatformServices"]),
    ],
    dependencies: [.package(path: "../LifeOSCore")],
    targets: [
        .target(name: "CryptoApple", dependencies: [.product(name: "CryptoCore", package: "LifeOSCore")]),
        .target(
            name: "CloudKitTransport",
            dependencies: [
                .product(name: "SyncCore", package: "LifeOSCore"),
                .product(name: "CryptoCore", package: "LifeOSCore"),
            ]),
        .target(name: "PlatformServices", dependencies: [.product(name: "Domain", package: "LifeOSCore")]),
        .testTarget(
            name: "CryptoAppleTests",
            dependencies: [
                "CryptoApple", .product(name: "TestSupport", package: "LifeOSCore"),
            ]),
    ],
    swiftLanguageModes: [.v6]
)
