/// Lỗi nghiệp vụ (vi phạm business rule). Store đổi thành lỗi hiển thị theo BR-GEN-08.
public enum DomainError: Error, Equatable, Sendable {
    case emptyTitle
    case titleTooLong(max: Int)
    case invalidAmount
}
