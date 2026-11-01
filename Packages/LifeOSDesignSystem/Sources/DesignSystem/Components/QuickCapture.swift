import SwiftUI

/// Kết quả xem trước của bộ hiểu cú pháp Ghi nhanh (nằm ở tầng Domain, truyền vào đây).
public struct CapturePreview: Equatable, Sendable {
    public enum Kind: Sendable { case task, expense, income }
    public let kind: Kind
    public let summary: String

    public init(kind: Kind, summary: String) {
        self.kind = kind
        self.summary = summary
    }
}

/// Ô Ghi nhanh: gõ một dòng, xem trước sẽ lưu thành gì, Enter để lưu.
public struct QuickCaptureField: View {
    @Binding var text: String
    let preview: CapturePreview?
    let hint: String?
    let onSubmit: () -> Void
    @FocusState private var isFocused: Bool

    public init(text: Binding<String>, preview: CapturePreview?, hint: String? = nil, onSubmit: @escaping () -> Void) {
        _text = text
        self.preview = preview
        self.hint = hint
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Space.s2) {
            TextField("Ghi nhanh", text: $text, prompt: Text("cafe 45k · nộp báo cáo @mai"))
                .lifeOSText(.body)
                .submitLabel(.done)
                .focused($isFocused)
                .onSubmit(onSubmit)
                .lifeOSField(isInvalid: hint != nil)
            if let preview {
                Label(preview.summary, systemImage: symbol(for: preview.kind))
                    .lifeOSText(.footnote)
                    .foregroundStyle(LifeOSColor.text)
                    .padding(.horizontal, Space.s3)
                    .padding(.vertical, Space.s1)
                    .background(LifeOSColor.surface2, in: .capsule)
                    .transition(.opacity)
            }
            if let hint {
                InlineError(hint)
            }
        }
        .lifeOSAnimation(.micro, value: preview)
        .onAppear { isFocused = true }
    }

    private func symbol(for kind: CapturePreview.Kind) -> String {
        switch kind {
        case .task: LifeOSIcon.tasks
        case .expense: "arrow.down.right"
        case .income: "arrow.up.right"
        }
    }
}

/// Thanh "Ghi nhanh…" trên iPhone, đặt trong `.tabViewBottomAccessory` của `TabView`.
/// Hệ thống vẽ kính và tự thu thanh vào tab bar khi cuộn xuống; ở đây chỉ vẽ nội dung.
///
///     TabView { … }
///         .tabViewBottomAccessory { QuickCaptureBar { showCapture = true } }
///         .tabBarMinimizeBehavior(.onScrollDown)
///
/// Chạm mở sheet Ghi nhanh (`QuickCaptureField` trong `.sheet` với detent `.medium`).
public struct QuickCaptureBar: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Space.s2) {
                Image(systemName: LifeOSIcon.add)
                    .fontWeight(.semibold)
                    .foregroundStyle(LifeOSColor.accent)
                Text("Ghi nhanh…")
                    .lifeOSText(.body)
                    .foregroundStyle(LifeOSColor.text2)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, Space.s4)
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .keyboardShortcut("n", modifiers: .command)
        .accessibilityLabel("Ghi nhanh")
    }
}

/// Nút Ghi nhanh trong toolbar trên iPad và Mac, phím tắt ⌘N. Toolbar tự có kính.
public struct QuickCaptureToolbarButton: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Label("Ghi nhanh", systemImage: LifeOSIcon.add)
        }
        .keyboardShortcut("n", modifiers: .command)
        .help("Ghi nhanh (⌘N)")
    }
}
