// swift-tools-version: 6.2
// LifeOSFeatures: màn hình theo tính năng + AppFeature ghép mọi thứ (ADR-0007, ADR-0008).
// Feature không import feature khác, không import LifeOSData hay LifeOSPlatform: chỉ biết port trong Domain (ADR-0017).
// Chỉ AppFeature (gốc ghép) được import Persistence, CloudSync, PlatformServices.
import PackageDescription

let package = Package(
    name: "LifeOSFeatures",
    defaultLocalization: "vi",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"])
    ],
    dependencies: [
        .package(path: "../LifeOSCore"),
        .package(path: "../LifeOSData"),
        .package(path: "../LifeOSDesignSystem"),
        .package(path: "../LifeOSPlatform"),
    ],
    targets: [
        .target(
            name: "FeatureSupport",
            dependencies: [
                .product(name: "Domain", package: "LifeOSCore"),
                .product(name: "DesignSystem", package: "LifeOSDesignSystem"),
            ]),
        .target(name: "TodayFeature", dependencies: ["FeatureSupport"]),
        .target(name: "TasksFeature", dependencies: ["FeatureSupport"]),
        .target(name: "HabitsFeature", dependencies: ["FeatureSupport"]),
        .target(name: "JournalFeature", dependencies: ["FeatureSupport"]),
        .target(name: "SpendingFeature", dependencies: ["FeatureSupport"]),
        .target(name: "ReviewFeature", dependencies: ["FeatureSupport"]),
        .target(
            name: "CaptureFeature", dependencies: ["FeatureSupport", .product(name: "Capture", package: "LifeOSCore")]),
        .target(name: "OnboardingFeature", dependencies: ["FeatureSupport"]),
        .target(name: "SettingsFeature", dependencies: ["FeatureSupport"]),
        .target(
            name: "AppFeature",
            dependencies: [
                "TodayFeature", "TasksFeature", "HabitsFeature", "JournalFeature", "SpendingFeature", "ReviewFeature",
                "CaptureFeature", "OnboardingFeature", "SettingsFeature", "FeatureSupport",
                .product(name: "Persistence", package: "LifeOSData"),
                .product(name: "CloudSync", package: "LifeOSData"),
                .product(name: "PlatformServices", package: "LifeOSPlatform"),
            ]),
        .testTarget(
            name: "FeatureSupportTests",
            dependencies: ["FeatureSupport", .product(name: "TestSupport", package: "LifeOSCore")]),
    ],
    swiftLanguageModes: [.v6]
)
