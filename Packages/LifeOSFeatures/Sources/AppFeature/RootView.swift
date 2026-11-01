import DesignSystem
import FeatureSupport
import SwiftUI

/// Gốc giao diện: TabView trên iPhone, NavigationSplitView trên iPad/Mac. Khung: LOS-035.
public struct RootView: View {
    public init() {}

    public var body: some View {
        Text("Life OS")
            .lifeOSText(.title1)
    }
}
