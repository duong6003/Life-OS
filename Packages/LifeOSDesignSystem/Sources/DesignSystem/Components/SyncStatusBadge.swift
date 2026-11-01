import SwiftUI

/// Trạng thái đồng bộ iCloud. Dữ liệu luôn được ghi trong máy trước, nên không trạng thái nào là "mất dữ liệu".
public enum SyncState: Equatable, Sendable {
    case synced
    case syncing
    /// Có thay đổi chưa gửi lên (đang ngoại tuyến hoặc đang chờ hệ thống).
    case pending(changes: Int)
    case iCloudSignedOut
    case iCloudFull
    /// Máy gặp dữ liệu mã hóa bằng khóa lạ: phải nhập mã khôi phục, không tự tạo khóa mới.
    case needsRecoveryKey
    case failed

    public var title: String {
        switch self {
        case .synced: "Đã đồng bộ"
        case .syncing: "Đang đồng bộ"
        case .pending(let n): "Chờ đồng bộ · \(n) thay đổi"
        case .iCloudSignedOut: "Chưa đăng nhập iCloud · vẫn lưu trong máy"
        case .iCloudFull: "iCloud đã đầy"
        case .needsRecoveryKey: "Cần mã khôi phục"
        case .failed: "Chưa đồng bộ được"
        }
    }

    /// Câu giải thích ngắn cho Cài đặt và cho thẻ Lỗi.
    public var detail: String {
        switch self {
        case .synced: "Mọi thay đổi đã có trên các thiết bị của bạn."
        case .syncing: "Đang gửi và nhận thay đổi."
        case .pending: "Đã lưu trong máy. Sẽ đồng bộ khi có mạng."
        case .iCloudSignedOut: "Dữ liệu vẫn lưu trong máy này. Đăng nhập iCloud trong Cài đặt để dùng trên thiết bị khác."
        case .iCloudFull: "Dữ liệu vẫn lưu trong máy này. Giải phóng dung lượng iCloud để đồng bộ tiếp."
        case .needsRecoveryKey: "Thiết bị này chưa có khóa để mở dữ liệu. Nhập mã khôi phục để tiếp tục."
        case .failed: "Dữ liệu vẫn lưu trong máy này. Life OS sẽ thử lại."
        }
    }

    public var symbol: String {
        switch self {
        case .synced: LifeOSIcon.synced
        case .syncing: LifeOSIcon.syncing
        case .pending: LifeOSIcon.syncPending
        case .iCloudSignedOut, .iCloudFull: LifeOSIcon.iCloudOff
        case .needsRecoveryKey: LifeOSIcon.recoveryKey
        case .failed: LifeOSIcon.syncFailed
        }
    }

    /// Chỉ hai trạng thái cần người dùng làm gì đó mới nổi màu (icon warning); không trạng thái nào dùng danger.
    public var needsAttention: Bool {
        self == .needsRecoveryKey || self == .iCloudFull
    }
}

/// Chỉ báo đồng bộ nhỏ: đặt ở cuối thanh tiêu đề hoặc đầu Cài đặt. Không chạy hiệu ứng lặp.
public struct SyncStatusBadge: View {
    let state: SyncState

    public init(_ state: SyncState) {
        self.state = state
    }

    public var body: some View {
        Label {
            Text(state.title)
                .foregroundStyle(state.needsAttention ? LifeOSColor.text : LifeOSColor.text2)
        } icon: {
            // warning chỉ tô icon: chữ nhỏ màu warning trên surface-2 chưa đạt 4,5:1.
            Image(systemName: state.symbol)
                .foregroundStyle(state.needsAttention ? LifeOSColor.warning : LifeOSColor.text2)
        }
        .lifeOSText(.footnote)
        .contentTransition(.opacity)
            .accessibilityLabel(state.title)
            .accessibilityHint(state.detail)
    }
}
