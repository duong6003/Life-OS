// swift-tools-version: 6.2
// LifeOSFeatures: màn hình theo tính năng + AppFeature ghép mọi thứ (ADR-0007, ADR-0008).
// Feature không import feature khác, không import LifeOSPlatform hay CloudSync; chỉ AppFeature được (ADR-0016).
import PackageDescription

let package = Package(
    name: "LifeOSFeatures",
    defaultLocalization: "vi",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
    ],
    dependencies: [
        .package(path: "../LifeOSCore"),
        .package(path: "../LifeOSData"),
        .package(path: "../LifeOSDesignSystem"),
        .package(path: "../LifeOSPlatform"),
    ],
    targets: [
        .target(name: "FeatureSupport", dependencies: [
            .product(name: "Domain", package: "LifeOSCore"),
            .product(name: "DesignSystem", package: "LifeOSDesignSystem"),
        ]),
        .target(name: "TodayFeature", dependencies: ["FeatureSupport", .product(name: "Persistence", package: "LifeOSData")]),
        .target(name: "TasksFeature", dependencies: ["FeatureSupport", .product(name: "Persistence", package: "LifeOSData")]),
        .target(name: "HabitsFeature", dependencies: ["FeatureSupport", .product(name: "Persistence", package: "LifeOSData")]),
        .target(name: "JournalFeature", dependencies: ["FeatureSupport", .product(name: "Persistence", package: "LifeOSData")]),
        .target(name: "SpendingFeature", dependencies: ["FeatureSupport", .product(name: "Persistence", package: "LifeOSData")]),
        .target(name: "ReviewFeature", dependencies: ["FeatureSupport", .product(name: "Persistence", package: "LifeOSData")]),
        .target(name: "CaptureFeature", dependencies: ["FeatureSupport", .product(name: "Persistence", package: "LifeOSData"), .product(name: "Capture", package: "LifeOSCore")]),
        .target(name: "OnboardingFeature", dependencies: ["FeatureSupport", .product(name: "Persistence", package: "LifeOSData")]),
        .target(name: "SettingsFeature", dependencies: ["FeatureSupport", .product(name: "Persistence", package: "LifeOSData")]),
        .target(name: "AppFeature", dependencies: ["TodayFeature", "TasksFeature", "HabitsFeature", "JournalFeature", "SpendingFeature", "ReviewFeature", "CaptureFeature", "OnboardingFeature", "SettingsFeature", "FeatureSupport", .product(name: "CloudSync", package: "LifeOSData"), .product(name: "PlatformServices", package: "LifeOSPlatform")]),
        .testTarget(name: "FeatureSupportTests", dependencies: ["FeatureSupport", .product(name: "TestSupport", package: "LifeOSCore")]),
    ],
    swiftLanguageModes: [.v6]
)
