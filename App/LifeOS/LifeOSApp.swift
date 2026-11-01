import AppFeature
import SwiftUI

/// Chỉ ghép gốc. Không I/O mạng, không crypto trước khung hình đầu (performance-budget.md).
@main
struct LifeOSApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
