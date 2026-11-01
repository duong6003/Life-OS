// Sinh tự động từ design-tokens/tokens.json bởi design-tokens/generate.py. Đừng sửa tay.

import SwiftUI

/// Màu token. Mỗi màu là một colorset có biến thể Light, Dark và (nếu có) Increase Contrast,
/// nên hệ thống tự đổi theo giao diện mà không cần rẽ nhánh lúc chạy.
public enum LifeOSColor {
    /// Nền app
    public static let bg = Color("bg", bundle: .module)
    /// Card, list, sheet (Light)
    public static let surface = Color("surface", bundle: .module)
    /// Input, vùng lõm, chip, sheet (Dark)
    public static let surface2 = Color("surface2", bundle: .module)
    /// Viền card (Light), divider. Chỉ trang trí, không mang thông tin
    public static let border = Color("border", bundle: .module)
    /// Chữ chính
    public static let text = Color("text", bundle: .module)
    /// Chữ phụ, meta
    public static let text2 = Color("text2", bundle: .module)
    /// Placeholder, nhãn trục, tab chưa chọn
    public static let text3 = Color("text3", bundle: .module)
    /// Nút chính, đang chọn, hoàn thành. Accent duy nhất
    public static let accent = Color("accent", bundle: .module)
    /// Chữ, icon trên nền accent
    public static let onAccent = Color("onAccent", bundle: .module)
    /// Chip đã chọn, thói quen đã tick, mục nav hiện tại
    public static let accentSoft = Color("accentSoft", bundle: .module)
    /// Khoản thu, xu hướng tốt
    public static let positive = Color("positive", bundle: .module)
    /// Ngân sách 80–100%, ưu tiên Cao
    public static let warning = Color("warning", bundle: .module)
    /// Chỉ: quá hạn, vượt ngân sách, xóa
    public static let danger = Color("danger", bundle: .module)
    /// Nền mờ sau sheet, dialog
    public static let scrim = Color("scrim", bundle: .module)
    /// Viên trượt segmented control
    public static let segmentThumb = Color("segmentThumb", bundle: .module)
    /// Ô nhập đặt trong sheet
    public static let fieldOnSheet = Color("fieldOnSheet", bundle: .module)
    /// Màu danh mục, dự án, thói quen; biểu đồ
    public static let dataBlue = Color("dataBlue", bundle: .module)
    /// Màu danh mục, dự án, thói quen; biểu đồ
    public static let dataOrange = Color("dataOrange", bundle: .module)
    /// Màu danh mục, dự án, thói quen; biểu đồ
    public static let dataViolet = Color("dataViolet", bundle: .module)
    /// Màu danh mục, dự án, thói quen; biểu đồ
    public static let dataGreen = Color("dataGreen", bundle: .module)
    /// Màu danh mục, dự án, thói quen; biểu đồ
    public static let dataPink = Color("dataPink", bundle: .module)
    /// Màu danh mục, dự án, thói quen; biểu đồ
    public static let dataOchre = Color("dataOchre", bundle: .module)
    /// Màu danh mục, dự án, thói quen; biểu đồ
    public static let dataSky = Color("dataSky", bundle: .module)
    /// Màu danh mục, dự án, thói quen; biểu đồ
    public static let dataSlate = Color("dataSlate", bundle: .module)
    /// Mood 1: Tệ
    public static let mood1 = Color("mood1", bundle: .module)
    /// Mood 2: Không ổn
    public static let mood2 = Color("mood2", bundle: .module)
    /// Mood 3: Bình thường
    public static let mood3 = Color("mood3", bundle: .module)
    /// Mood 4: Tốt
    public static let mood4 = Color("mood4", bundle: .module)
    /// Mood 5: Tuyệt
    public static let mood5 = Color("mood5", bundle: .module)
    /// Nét mặt trên nền mood
    public static let moodInk = Color("moodInk", bundle: .module)
}

/// Độ đậm dùng chung (Light / Dark).
public enum LifeOSOpacity {
    /// Độ đậm màu dữ liệu làm nền ô icon
    public static func dataTint(_ scheme: ColorScheme) -> Double { scheme == .dark ? 0.16 : 0.12 }
    /// Lớp phủ khi rê chuột (Mac, iPad có con trỏ)
    public static func overlayHover(_ scheme: ColorScheme) -> Double { scheme == .dark ? 0.07 : 0.06 }
    /// Lớp phủ khi nhấn
    public static func overlayPress(_ scheme: ColorScheme) -> Double { scheme == .dark ? 0.13 : 0.12 }
}

/// Lưới 4pt.
public enum Space {
    public static let s0_5: CGFloat = 2
    public static let s1: CGFloat = 4
    public static let s2: CGFloat = 8
    public static let s3: CGFloat = 12
    public static let s4: CGFloat = 16
    public static let s5: CGFloat = 20
    public static let s6: CGFloat = 24
    public static let s8: CGFloat = 32
    public static let s10: CGFloat = 40
    public static let s12: CGFloat = 48
    public static let s16: CGFloat = 64
}

/// Lớp bố cục: iPhone (compact), iPad (regular), Mac.
public enum LayoutClass: Sendable { case compact, regular, mac }

/// Bố cục theo nền tảng.
public enum Layout {
    /// Lề trang: iPhone / iPad / Mac
    public static func gutter(_ c: LayoutClass) -> CGFloat { switch c { case .compact: 16; case .regular: 24; case .mac: 32 } }
    /// Padding card
    public static func cardPadding(_ c: LayoutClass) -> CGFloat { switch c { case .compact: 16; case .regular: 20; case .mac: 20 } }
    public static let blockGap: CGFloat = 24
    public static let hit: CGFloat = 44
    public static let sidebarWidth: CGFloat = 240
    public static let contentFocus: CGFloat = 720
    public static let contentWide: CGFloat = 1080
    public static let macWindowMin = CGSize(width: 760, height: 560)
}

/// Bo góc, luôn dùng kiểu .continuous.
public enum Radius {
    public static let xs: CGFloat = 6
    public static let sm: CGFloat = 10
    public static let md: CGFloat = 14
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 28
}

/// Thang chữ ánh xạ sang Dynamic Type. Chiều cao dòng là hệ số (≥ 1,35 cho chữ có dấu tiếng Việt).
public enum TextToken: CaseIterable, Sendable {
    case numeralXl, title1, title2, title3, body, bodyStrong, callout, footnote, caption, journal

    public var textStyle: Font.TextStyle {
        switch self {
        case .numeralXl: .largeTitle
        case .title1: .title
        case .title2: .title2
        case .title3: .title3
        case .body: .body
        case .bodyStrong: .body
        case .callout: .subheadline
        case .footnote: .footnote
        case .caption: .caption
        case .journal: .body
        }
    }

    public var weight: Font.Weight {
        switch self {
        case .numeralXl: .semibold
        case .title1: .bold
        case .title2: .semibold
        case .title3: .semibold
        case .body: .regular
        case .bodyStrong: .medium
        case .callout: .regular
        case .footnote: .regular
        case .caption: .medium
        case .journal: .regular
        }
    }

    /// Cỡ riêng (pt ở cỡ chữ mặc định), co giãn theo textStyle. nil = dùng cỡ của textStyle.
    public var customSize: CGFloat? {
        switch self {
        case .numeralXl: 40
        default: nil
        }
    }

    public var lineHeightMultiple: CGFloat {
        switch self {
        case .numeralXl: 1.1
        case .title1: 1.35
        case .title2: 1.35
        case .title3: 1.4
        case .body: 1.4
        case .bodyStrong: 1.4
        case .callout: 1.4
        case .footnote: 1.4
        case .caption: 1.35
        case .journal: 1.6
        }
    }

    public var monospacedDigit: Bool { self == .numeralXl }
}

/// Chuyển động. Dùng qua .lifeOSAnimation(_:value:) để tự đổi sang mờ dần khi bật Reduce Motion.
public enum MotionToken: Sendable {
    case micro, standard, emphasized, spring

    public var animation: Animation {
        switch self {
        case .micro: .snappy(duration: 0.12)
        case .standard: .smooth(duration: 0.2)
        case .emphasized: .smooth(duration: 0.32)
        case .spring: .spring(duration: 0.42, bounce: 0.2)
        }
    }

    /// Thay mọi chuyển động khi bật Reduce Motion: chỉ mờ dần, không trượt, không phóng to
    public static let reduced: Animation = .linear(duration: 0.09)
}

/// Rung phản hồi. Chỉ rung ở sự kiện có ý nghĩa; không rung khi cuộn hay gõ.
public enum HapticToken: Sendable {
    case success, selection, warning, light

    public var feedback: SensoryFeedback {
        switch self {
        case .success: .success
        case .selection: .selection
        case .warning: .warning
        case .light: .impact(weight: .light)
        }
    }
}
