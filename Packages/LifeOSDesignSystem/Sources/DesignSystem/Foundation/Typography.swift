import SwiftUI

extension View {
    /// Kiểu chữ token: cỡ theo Dynamic Type, độ đậm, chiều cao dòng tương đối.
    /// Không đặt chữ trong khung cao cố định: dấu chồng tiếng Việt (Ể, Ặ, Ỗ) sẽ bị cắt ở cỡ lớn.
    public func lifeOSText(_ token: TextToken) -> some View {
        modifier(TextTokenModifier(token: token))
    }
}

struct TextTokenModifier: ViewModifier {
    let token: TextToken
    @ScaledMetric private var scaledSize: CGFloat

    init(token: TextToken) {
        self.token = token
        _scaledSize = ScaledMetric(wrappedValue: token.customSize ?? 17, relativeTo: token.textStyle)
    }

    func body(content: Content) -> some View {
        content
            .font(font)
            .lineHeight(.multiple(factor: token.lineHeightMultiple))
    }

    private var font: Font {
        let base: Font =
            token.customSize == nil
            ? .system(token.textStyle, weight: token.weight)
            : .system(size: scaledSize, weight: token.weight)
        return token.monospacedDigit ? base.monospacedDigit() : base
    }
}
