import SwiftUI
#if canImport(UIKit)
import UIKit
import UniformTypeIdentifiers
#elseif canImport(AppKit)
import AppKit
#endif

/// Hiển thị mã khôi phục theo nhóm 4 ký tự, chữ đơn cách. VoiceOver đọc từng ký tự để người dùng chép tay không nhầm.
///
/// Mã dùng bảng 23 ký tự không dễ nhầm (`RecoveryKeyAlphabet.characters`); 28 ký tự ≈ 126 bit.
/// Không cho bôi đen chữ: chép chỉ qua `RecoveryKeyCopyButton`, để bộ nhớ tạm luôn chỉ trong máy và tự xóa.
public struct RecoveryKeyView: View {
    let key: String

    public init(_ key: String) {
        self.key = key
    }

    private var groups: [String] {
        let chars = Array(RecoveryKeyAlphabet.normalize(key))
        return stride(from: 0, to: chars.count, by: 4).map { String(chars[$0 ..< min($0 + 4, chars.count)]) }
    }

    public var body: some View {
        let lines = stride(from: 0, to: groups.count, by: 4).map { groups[$0 ..< min($0 + 4, groups.count)].joined(separator: "  ") }
        VStack(alignment: .leading, spacing: Space.s2) {
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.system(.title3, design: .monospaced, weight: .medium))
                    .foregroundStyle(LifeOSColor.text)
            }
        }
        .padding(Space.s4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LifeOSColor.surface2, in: .rect(cornerRadius: Radius.md, style: .continuous))
        .accessibilityElement()
        .accessibilityLabel("Mã khôi phục")
        .accessibilityValue(groups.map { $0.map(String.init).joined(separator: " ") }.joined(separator: ", "))
    }
}

/// Bảng ký tự của mã khôi phục: bỏ O, I, L, S, B, Z, U, V và 0, 1, 2, 5, 8 (dễ đọc nhầm khi chép tay).
public enum RecoveryKeyAlphabet {
    public static let characters = "ACDEFGHJKMNPQRTWXY34679"
    public static let length = 28

    /// Bỏ khoảng trắng, gạch nối; viết hoa. Dùng cho cả hiển thị lẫn ô nhập.
    public static func normalize(_ input: String) -> String {
        String(input.uppercased().filter { $0.isLetter || $0.isNumber })
    }

    /// Ký tự không thuộc bảng: thấy là biết người dùng đọc nhầm (vd. O thay cho Q), báo ngay trong ô nhập.
    public static func invalidCharacters(in input: String) -> Set<Character> {
        Set(normalize(input).filter { !characters.contains($0) })
    }
}

/// Nút Chép mã khôi phục: chỉ trong máy (không qua Universal Clipboard), tự xóa sau 2 phút.
public struct RecoveryKeyCopyButton: View {
    let key: String
    let onCopied: () -> Void

    /// `onCopied`: hiện toast "Đã chép, tự xóa khỏi bộ nhớ tạm sau 2 phút".
    public init(_ key: String, onCopied: @escaping () -> Void = {}) {
        self.key = key
        self.onCopied = onCopied
    }

    public var body: some View {
        Button {
            Self.copyLocally(RecoveryKeyAlphabet.normalize(key))
            onCopied()
        } label: {
            Label("Chép", systemImage: "doc.on.doc")
        }
        .buttonStyle(.bordered)
    }

    static let lifetime: TimeInterval = 120

    static func copyLocally(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.setItems(
            [[UTType.plainText.identifier: text]],
            options: [.localOnly: true, .expirationDate: Date().addingTimeInterval(lifetime)]
        )
        #elseif canImport(AppKit)
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
        // Quy ước của các trình quản lý clipboard: không lưu lịch sử mục này.
        pb.setString("", forType: NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType"))
        let count = pb.changeCount
        DispatchQueue.main.asyncAfter(deadline: .now() + lifetime) {
            if pb.changeCount == count { pb.clearContents() }
        }
        #endif
    }
}
