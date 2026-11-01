import SwiftUI

/// Thông báo ngắn có nút Hoàn tác (iOS không có sẵn). Nền đục cấp 2, không kính.
/// Người gọi tự ẩn sau khoảng 5 giây và đọc `message` cho VoiceOver bằng AccessibilityNotification.
public struct UndoToast: View {
    let message: String
    let onUndo: (() -> Void)?

    public init(_ message: String, onUndo: (() -> Void)? = nil) {
        self.message = message
        self.onUndo = onUndo
    }

    public var body: some View {
        HStack(spacing: Space.s3) {
            Text(message)
                .lifeOSText(.callout)
                .foregroundStyle(LifeOSColor.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let onUndo {
                Button("Hoàn tác", action: onUndo)
                    .lifeOSText(.bodyStrong)
                    .foregroundStyle(LifeOSColor.accent)
                    .frame(minWidth: Layout.hit, minHeight: Layout.hit)
            }
        }
        .padding(.leading, Space.s4)
        .padding(.trailing, Space.s2)
        .padding(.vertical, Space.s1)
        .frame(minHeight: Layout.hit + Space.s2)
        // Toast nổi trên nội dung nên dùng Liquid Glass; hệ thống tự chuyển nền đặc khi bật Reduce Transparency.
        .glassEffect(.regular, in: .rect(cornerRadius: Radius.lg, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}
