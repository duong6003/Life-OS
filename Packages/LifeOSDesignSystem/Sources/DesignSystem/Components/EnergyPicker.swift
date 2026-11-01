import SwiftUI

/// Chọn năng lượng 1–5: năm cột cao dần.
public struct EnergyPicker: View {
    public static let labels = ["Kiệt sức", "Mệt", "Vừa", "Khỏe", "Tràn đầy"]
    @Binding var selection: Int?

    public init(selection: Binding<Int?>) {
        _selection = selection
    }

    public var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Space.s1) { options(vertical: false) }
            VStack(spacing: Space.s1) { options(vertical: true) }
        }
        .lifeOSAnimation(.standard, value: selection)
        .lifeOSHaptic(.selection, trigger: selection)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Năng lượng")
    }

    @ViewBuilder
    private func options(vertical: Bool) -> some View {
        ForEach(1...5, id: \.self) { level in
            let isOn = selection == level
            Button {
                selection = level
            } label: {
                let bars = levelBars(level: level, isOn: isOn)
                let label = Text(Self.labels[level - 1])
                    .lifeOSText(.caption)
                    .foregroundStyle(isOn ? LifeOSColor.text : LifeOSColor.text2)
                Group {
                    if vertical {
                        HStack(spacing: Space.s3) {
                            bars
                            label
                            Spacer(minLength: 0)
                        }
                    } else {
                        VStack(spacing: Space.s1) {
                            bars
                            label.lineLimit(2).multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(Space.s2)
                .frame(maxWidth: .infinity, minHeight: Layout.hit)
                .background(
                    isOn ? LifeOSColor.accentSoft : .clear, in: .rect(cornerRadius: Radius.md, style: .continuous)
                )
                .contentShape(.rect(cornerRadius: Radius.md, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Self.labels[level - 1])
            .accessibilityAddTraits(isOn ? .isSelected : [])
        }
    }

    private func levelBars(level: Int, isOn: Bool) -> some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Capsule()
                    .fill(i <= level ? (isOn ? LifeOSColor.accent : LifeOSColor.text3) : LifeOSColor.border)
                    .frame(width: 4, height: CGFloat(6 + i * 3))
            }
        }
        .frame(height: 24, alignment: .bottom)
        .accessibilityHidden(true)
    }
}
