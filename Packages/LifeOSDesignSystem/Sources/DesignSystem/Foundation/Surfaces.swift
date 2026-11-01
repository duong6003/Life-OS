import SwiftUI

extension EnvironmentValues {
    /// Lớp bố cục hiện tại. Đặt một lần ở gốc app bằng `.lifeOSLayoutClassFromSystem()`.
    @Entry public var lifeOSLayoutClass: LayoutClass = .compact
}

extension View {
    /// Đọc size class (iOS) hoặc nền tảng (Mac) và ghi vào `lifeOSLayoutClass`.
    public func lifeOSLayoutClassFromSystem() -> some View {
        modifier(LayoutClassModifier())
    }

    /// Thẻ: nền đục, bo lg, viền tóc chỉ ở Light. Không bóng, không kính.
    public func lifeOSCard(fill: Color = LifeOSColor.surface, padding: CGFloat? = nil) -> some View {
        modifier(CardModifier(fill: fill, padding: padding))
    }

    /// Ô nhập: nền surface-2. Khi lỗi thêm viền 2pt màu chữ chính, không dùng đỏ.
    public func lifeOSField(isInvalid: Bool = false) -> some View {
        modifier(FieldModifier(isInvalid: isInvalid))
    }
}

struct LayoutClassModifier: ViewModifier {
    #if os(iOS)
        @Environment(\.horizontalSizeClass) private var sizeClass
        func body(content: Content) -> some View {
            content.environment(\.lifeOSLayoutClass, sizeClass == .regular ? .regular : .compact)
        }
    #else
        func body(content: Content) -> some View {
            content.environment(\.lifeOSLayoutClass, .mac)
        }
    #endif
}

struct CardModifier: ViewModifier {
    let fill: Color
    let padding: CGFloat?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.lifeOSLayoutClass) private var layoutClass

    func body(content: Content) -> some View {
        content
            .padding(padding ?? Layout.cardPadding(layoutClass))
            .background(fill, in: .rect(cornerRadius: Radius.lg, style: .continuous))
            .overlay {
                if scheme == .light {
                    RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                        .strokeBorder(LifeOSColor.border, lineWidth: 1)
                }
            }
    }
}

struct FieldModifier: ViewModifier {
    let isInvalid: Bool

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, Space.s3)
            .padding(.vertical, Space.s2)
            .frame(minHeight: Layout.hit)
            .background(LifeOSColor.surface2, in: .rect(cornerRadius: Radius.md, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .strokeBorder(isInvalid ? LifeOSColor.text : .clear, lineWidth: 2)
            }
    }
}

/// Ô icon có nền màu dữ liệu nhạt (36pt, icon 20pt).
public struct IconTile: View {
    let symbol: String
    let tint: Color
    @Environment(\.colorScheme) private var scheme

    public init(symbol: String, tint: Color) {
        self.symbol = symbol
        self.tint = tint
    }

    public var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(tint)
            .frame(width: 36, height: 36)
            .background(
                tint.opacity(LifeOSOpacity.dataTint(scheme)), in: .rect(cornerRadius: Radius.sm, style: .continuous)
            )
            .accessibilityHidden(true)
    }
}

/// Lỗi ngay dưới ô nhập: icon và câu hướng dẫn, màu chữ phụ.
public struct InlineError: View {
    let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var body: some View {
        Label(message, systemImage: LifeOSIcon.alert)
            .lifeOSText(.footnote)
            .foregroundStyle(LifeOSColor.text2)
    }
}
