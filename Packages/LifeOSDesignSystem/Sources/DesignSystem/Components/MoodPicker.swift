import SwiftUI

public enum Mood {
    public static let labels = ["Tệ", "Không ổn", "Bình thường", "Tốt", "Tuyệt"]
    public static let colors = [
        LifeOSColor.mood1, LifeOSColor.mood2, LifeOSColor.mood3, LifeOSColor.mood4, LifeOSColor.mood5,
    ]
}

/// Mặt tâm trạng vẽ bằng một Canvas: nền màu mood, hai mắt, miệng cong theo mức 1–5.
public struct MoodFace: View {
    let level: Int

    public init(level: Int) {
        self.level = min(max(level, 1), 5)
    }

    public var body: some View {
        Canvas { context, size in
            let radius = min(size.width, size.height) / 2
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            context.fill(
                Path(
                    ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
                ),
                with: .color(Mood.colors[level - 1]))
            let eyeR = radius * 0.09
            for dx in [-radius * 0.32, radius * 0.32] {
                context.fill(
                    Path(
                        ellipseIn: CGRect(
                            x: center.x + dx - eyeR, y: center.y - radius * 0.2 - eyeR, width: eyeR * 2,
                            height: eyeR * 2)),
                    with: .color(LifeOSColor.moodInk))
            }
            let mouthY = center.y + radius * 0.3
            let half = radius * 0.42
            let bend = CGFloat(level - 3) * radius * 0.14
            var mouth = Path()
            mouth.move(to: CGPoint(x: center.x - half, y: mouthY - bend / 2))
            mouth.addQuadCurve(
                to: CGPoint(x: center.x + half, y: mouthY - bend / 2), control: CGPoint(x: center.x, y: mouthY + bend))
            context.stroke(
                mouth, with: .color(LifeOSColor.moodInk),
                style: StrokeStyle(lineWidth: max(1.5, radius * 0.1), lineCap: .round))
        }
        .accessibilityHidden(true)
    }
}

/// Chọn tâm trạng 1–5. Khi chữ lớn không đủ chỗ thì tự chuyển thành danh sách dọc.
public struct MoodPicker: View {
    @Binding var selection: Int?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(selection: Binding<Int?>) {
        _selection = selection
    }

    public var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Space.s1) { options(vertical: false) }
            VStack(spacing: Space.s1) { options(vertical: true) }
        }
        .lifeOSAnimation(.spring, value: selection)
        .lifeOSHaptic(.selection, trigger: selection)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tâm trạng")
    }

    @ViewBuilder
    private func options(vertical: Bool) -> some View {
        ForEach(1...5, id: \.self) { level in
            let isOn = selection == level
            Button {
                selection = level
            } label: {
                let face = MoodFace(level: level)
                    .frame(width: 40, height: 40)
                    .scaleEffect(isOn && !reduceMotion ? 1.08 : 1)
                let label = Text(Mood.labels[level - 1])
                    .lifeOSText(.caption)
                    .foregroundStyle(isOn ? LifeOSColor.text : LifeOSColor.text2)
                Group {
                    if vertical {
                        HStack(spacing: Space.s3) {
                            face
                            label
                            Spacer(minLength: 0)
                        }
                    } else {
                        VStack(spacing: Space.s1) {
                            face
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
            .accessibilityLabel(Mood.labels[level - 1])
            .accessibilityAddTraits(isOn ? .isSelected : [])
        }
    }
}
