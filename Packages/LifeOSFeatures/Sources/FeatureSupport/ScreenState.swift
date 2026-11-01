import Domain

/// Ba loại lỗi duy nhất người dùng thấy (BR-GEN-08). Mọi lỗi khác: log + chỉ báo đồng bộ.
public enum UserFacingError: Equatable, Sendable {
    case iCloudSignedOut
    case missingKeyOnNewDevice
    case localDataCorrupted
}
