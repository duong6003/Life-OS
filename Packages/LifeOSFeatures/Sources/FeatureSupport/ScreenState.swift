import Domain

/// Trạng thái chung của một màn. Store giữ một giá trị này; View vẽ theo nó.
public enum ScreenState: Equatable, Sendable {
    case idle
    case loading
    case error(UserFacingError)
}

/// Ba loại lỗi duy nhất người dùng thấy (BR-GEN-08). Mọi lỗi khác: log + chỉ báo đồng bộ.
public enum UserFacingError: Equatable, Sendable {
    case iCloudSignedOut
    case missingKeyOnNewDevice  // sau MVP (LOS-075)
    case localDataCorrupted
}
