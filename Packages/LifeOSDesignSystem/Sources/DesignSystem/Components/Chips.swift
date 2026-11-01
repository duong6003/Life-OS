import SwiftUI

/// Chip bật/tắt (lọc, chọn danh mục, ngày trong tuần). Cao 36pt, vùng chạm 44pt.
public struct ChipToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
                .lifeOSText(.callout)
                .foregroundStyle(configuration.isOn ? LifeOSColor.text : LifeOSColor.text2)
                .padding(.horizontal, Space.s3)
                .frame(minHeight: 36)
                .background(configuration.isOn ? LifeOSColor.accentSoft : LifeOSColor.surface2, in: .capsule)
                .overlay {
                    Capsule().strokeBorder(configuration.isOn ? LifeOSColor.accent : .clear, lineWidth: 1)
                }
                .frame(minHeight: Layout.hit)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .lifeOSAnimation(.micro, value: configuration.isOn)
        .accessibilityAddTraits(configuration.isOn ? [.isSelected, .isToggle] : .isToggle)
    }
}

/// Chọn ngày lặp trong tuần (T2 … CN).
public struct WeekdayPicker: View {
    public static let labels = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
    public static let spoken = ["Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"]
    /// 0 = Thứ Hai … 6 = Chủ Nhật.
    @Binding var selection: Set<Int>

    public init(selection: Binding<Set<Int>>) {
        _selection = selection
    }

    public var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: Layout.hit), spacing: Space.s2)], spacing: Space.s2) {
            ForEach(0..<7, id: \.self) { day in
                Toggle(Self.labels[day], isOn: Binding(
                    get: { selection.contains(day) },
                    set: { isOn in if isOn { selection.insert(day) } else { selection.remove(day) } }
                ))
                .toggleStyle(ChipToggleStyle())
                .accessibilityLabel(Self.spoken[day])
            }
        }
        .lifeOSHaptic(.selection, trigger: selection)
    }
}

/// Ô số liệu: số lớn và nhãn, dùng trong Rà soát và Thu chi.
public struct StatTile: View {
    let value: String
    let label: String

    public init(value: String, label: String) {
        self.value = value
        self.label = label
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Space.s1) {
            Text(value)
                .lifeOSText(.title2)
                .monospacedDigit()
                .foregroundStyle(LifeOSColor.text)
                .contentTransition(.numericText())
            Text(label)
                .lifeOSText(.footnote)
                .foregroundStyle(LifeOSColor.text2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .lifeOSCard()
        .accessibilityElement(children: .combine)
    }
}
