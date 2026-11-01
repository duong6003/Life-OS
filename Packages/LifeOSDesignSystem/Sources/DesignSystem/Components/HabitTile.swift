import SwiftUI

/// Thẻ thói quen: chạm để tick. Vòng tiến độ cho thói quen đếm (ví dụ 2/3 cốc nước).
public struct HabitTile: View {
    let name: String
    let detail: String
    let symbol: String
    let tint: Color
    let progress: Double
    @Binding var isDone: Bool

    public init(name: String, detail: String, symbol: String, tint: Color, progress: Double = 0, isDone: Binding<Bool>)
    {
        self.name = name
        self.detail = detail
        self.symbol = symbol
        self.tint = tint
        self.progress = progress
        _isDone = isDone
    }

    public var body: some View {
        Button {
            isDone.toggle()
        } label: {
            VStack(alignment: .leading, spacing: Space.s3) {
                HStack {
                    IconTile(symbol: symbol, tint: tint)
                    Spacer(minLength: Space.s2)
                    ring
                }
                VStack(alignment: .leading, spacing: Space.s0_5) {
                    Text(name)
                        .lifeOSText(.bodyStrong)
                        .foregroundStyle(LifeOSColor.text)
                    Text(detail)
                        .lifeOSText(.footnote)
                        .foregroundStyle(LifeOSColor.text2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .lifeOSCard(fill: isDone ? LifeOSColor.accentSoft : LifeOSColor.surface)
            .contentShape(.rect(cornerRadius: Radius.lg, style: .continuous))
        }
        .buttonStyle(.plain)
        .lifeOSAnimation(.standard, value: isDone)
        .lifeOSHaptic(.success, trigger: isDone) { _, done in done }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(isDone ? "Đã xong hôm nay" : "Chưa xong")
    }

    private var ring: some View {
        ZStack {
            Circle().stroke(LifeOSColor.border, lineWidth: 3)
            Circle()
                .trim(from: 0, to: isDone ? 1 : min(max(progress, 0), 1))
                .stroke(LifeOSColor.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
            if isDone {
                Image(systemName: LifeOSIcon.check)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(LifeOSColor.accent)
            }
        }
        .frame(width: 22, height: 22)
        .accessibilityHidden(true)
    }
}
