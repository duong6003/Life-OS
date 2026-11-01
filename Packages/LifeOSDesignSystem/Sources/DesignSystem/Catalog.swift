import SwiftUI

/// Trang xem nhanh mọi component, dùng trong Xcode Preview để soát Light, Dark, chữ lớn và Increase Contrast.
public struct DesignSystemCatalog: View {
    @State private var taskDone = false
    @State private var habitDone = false
    @State private var mood: Int? = 4
    @State private var energy: Int? = 3
    @State private var days: Set<Int> = [0, 2, 4]
    @State private var capture = "cafe 45k"

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.blockGap) {
                Text("Hôm nay").lifeOSText(.title1).foregroundStyle(LifeOSColor.text)
                SyncStatusBadge(.pending(changes: 3))
                GlanceRow(items: [
                    GlanceItem(id: "tasks", value: "8 việc", label: "2 quá hạn", isAlert: true),
                    GlanceItem(id: "habits", value: "3/5", label: "thói quen"),
                    GlanceItem(id: "money", value: "185k", label: "đã chi"),
                ]) { _ in }
                Toggle(isOn: $taskDone) {
                    VStack(alignment: .leading) {
                        Text("Gửi hợp đồng cho anh Tuấn").lifeOSText(.bodyStrong)
                        Text("Hôm qua · Cao · Công việc").lifeOSText(.footnote).foregroundStyle(LifeOSColor.text2)
                    }
                }
                .toggleStyle(TaskCheckboxStyle(priority: .high))
                HabitTile(name: "Uống nước", detail: "2/3 cốc", symbol: "drop", tint: LifeOSColor.dataSky, progress: 2.0 / 3, isDone: $habitDone)
                MoodPicker(selection: $mood)
                EnergyPicker(selection: $energy)
                WeekdayPicker(selection: $days)
                QuickCaptureField(text: $capture, preview: CapturePreview(kind: .expense, summary: "Chi 45.000₫ · Ăn uống")) {}
                HabitHeatmap(
                    days: (0..<84).map { HabitHeatmap.Day(date: Date(timeIntervalSince1970: Double($0) * 86_400), level: $0 % 5) },
                    tint: LifeOSColor.dataGreen,
                    summary: "Đi bộ: mẫu 12 tuần"
                )
                StatTile(value: "1.250.000₫", label: "Đã chi tháng này")
                RecoveryKeyView("K7QP 3MXR 9RTA WC4H NE6D F4DW YE7K")
                RecoveryKeyCopyButton("K7QP 3MXR 9RTA WC4H NE6D F4DW YE7K")
                QuickCaptureBar {}
                UndoToast("Đã xong “Gửi hợp đồng”") {}
            }
            .padding(Layout.gutter(.compact))
        }
        .background(LifeOSColor.bg)
        .lifeOSLayoutClassFromSystem()
    }
}

#Preview("Light") { DesignSystemCatalog() }
#Preview("Dark") { DesignSystemCatalog().preferredColorScheme(.dark) }
#Preview("Chữ lớn") { DesignSystemCatalog().dynamicTypeSize(.accessibility3) }
