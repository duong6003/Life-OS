import SwiftUI

/// Mức ưu tiên của việc. Danger không dùng ở đây: danger chỉ cho quá hạn, vượt ngân sách và xóa.
public enum TaskPriority: CaseIterable, Sendable {
    case none, low, medium, high

    public var color: Color {
        switch self {
        case .none: LifeOSColor.text3
        case .low: LifeOSColor.dataBlue
        case .medium: LifeOSColor.dataViolet
        case .high: LifeOSColor.warning
        }
    }

    public var label: String {
        switch self {
        case .none: "Không"
        case .low: "Thấp"
        case .medium: "Vừa"
        case .high: "Cao"
        }
    }
}

/// Vòng tròn tick việc: viền theo ưu tiên, đầy accent khi xong. Vùng chạm 44pt.
/// Dùng: `Toggle(isOn: $task.isDone) { TaskLabel(…) }.toggleStyle(TaskCheckboxStyle(priority: .high))`
public struct TaskCheckboxStyle: ToggleStyle {
    public var priority: TaskPriority

    public init(priority: TaskPriority = .none) {
        self.priority = priority
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: Space.s1) {
            Button {
                configuration.isOn.toggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(configuration.isOn ? LifeOSColor.accent : .clear)
                    Circle()
                        .strokeBorder(configuration.isOn ? LifeOSColor.accent : priority.color, lineWidth: 2)
                    if configuration.isOn {
                        Image(systemName: LifeOSIcon.check)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(LifeOSColor.onAccent)
                    }
                }
                .frame(width: 22, height: 22)
                .frame(width: Layout.hit, height: Layout.hit)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .lifeOSAnimation(.standard, value: configuration.isOn)
            .lifeOSHaptic(.success, trigger: configuration.isOn) { _, isOn in isOn }

            configuration.label
                .padding(.vertical, Space.s2)
                .opacity(configuration.isOn ? 0.55 : 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(configuration.isOn ? "Đã xong" : "Chưa xong")
        .accessibilityAction { configuration.isOn.toggle() }
    }
}
