import SwiftUI

/// Heatmap thói quen vẽ bằng một Canvas thay vì hàng trăm view ô. Chạm được: tính ô theo tọa độ.
public struct HabitHeatmap: View {
    public struct Day: Identifiable, Sendable {
        public let id: Date
        /// 0 = không làm, 1–4 = mức hoàn thành tăng dần.
        public let level: Int

        public init(date: Date, level: Int) {
            id = date
            self.level = min(max(level, 0), 4)
        }
    }

    let days: [Day]
    let tint: Color
    let summary: String
    let onSelect: ((Day) -> Void)?

    private let cell: CGFloat = 12
    private let gap: CGFloat = 3

    /// `days` xếp từ cũ tới mới, mỗi cột là một tuần (7 ô). `summary` là câu VoiceOver đọc,
    /// ví dụ "Đi bộ: 21 trên 30 ngày gần nhất, chuỗi hiện tại 5 ngày".
    public init(days: [Day], tint: Color, summary: String, onSelect: ((Day) -> Void)? = nil) {
        self.days = days
        self.tint = tint
        self.summary = summary
        self.onSelect = onSelect
    }

    public var body: some View {
        let step = cell + gap
        let columns = (days.count + 6) / 7
        Canvas { context, _ in
            for (index, day) in days.enumerated() {
                let rect = CGRect(x: CGFloat(index / 7) * step, y: CGFloat(index % 7) * step, width: cell, height: cell)
                let style: GraphicsContext.Shading =
                    day.level == 0
                    ? .color(LifeOSColor.surface2)
                    : .color(tint.opacity(0.25 + 0.1875 * Double(day.level)))
                context.fill(Path(roundedRect: rect, cornerRadius: Radius.xs / 2, style: .continuous), with: style)
            }
        }
        .frame(width: max(CGFloat(columns) * step - gap, 0), height: 7 * step - gap)
        .onTapGesture { location in
            let index = Int(location.x / step) * 7 + Int(location.y / step)
            if days.indices.contains(index) { onSelect?(days[index]) }
        }
        .accessibilityElement()
        .accessibilityLabel(summary)
    }
}
