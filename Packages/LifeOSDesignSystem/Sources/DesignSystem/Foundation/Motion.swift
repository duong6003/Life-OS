import SwiftUI

extension View {
    /// Chuyển động token; tự đổi sang mờ dần ngắn khi bật Reduce Motion.
    public func lifeOSAnimation<V: Equatable>(_ token: MotionToken, value: V) -> some View {
        modifier(MotionModifier(token: token, value: value))
    }

    /// Rung khi `trigger` đổi. `condition` lọc bớt, ví dụ chỉ rung khi vừa bật.
    public func lifeOSHaptic<T: Equatable>(
        _ token: HapticToken, trigger: T, condition: @escaping (T, T) -> Bool = { _, _ in true }
    ) -> some View {
        sensoryFeedback(token.feedback, trigger: trigger, condition: condition)
    }
}

struct MotionModifier<V: Equatable>: ViewModifier {
    let token: MotionToken
    let value: V
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? MotionToken.reduced : token.animation, value: value)
    }
}

/// Dùng trong action: `withLifeOSAnimation(.standard, reduceMotion: reduceMotion) { … }`.
@MainActor
public func withLifeOSAnimation<Result>(
    _ token: MotionToken, reduceMotion: Bool, _ body: () throws -> Result
) rethrows -> Result {
    try withAnimation(reduceMotion ? MotionToken.reduced : token.animation, body)
}

extension AnyTransition {
    /// Vào và ra: mờ dần + thu nhẹ; chỉ mờ dần khi Reduce Motion.
    public static func lifeOS(reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.96))
    }
}

/// Khoảnh khắc ăn mừng (mốc chuỗi thói quen): tối đa một lần mỗi màn,
/// tắt khi Reduce Motion hoặc Low Power Mode.
public enum Celebration {
    public static func isAllowed(reduceMotion: Bool) -> Bool {
        !reduceMotion && !ProcessInfo.processInfo.isLowPowerModeEnabled
    }
}
