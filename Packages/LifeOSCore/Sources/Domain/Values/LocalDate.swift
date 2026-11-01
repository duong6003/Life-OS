/// Ngày lịch không có múi giờ, dạng `YYYY-MM-DD` (ADR-0013). Khung: LOS-010 hoàn thiện phép tính ngày.
public struct LocalDate: Hashable, Comparable, Sendable, CustomStringConvertible {
    public let year: Int
    public let month: Int
    public let day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// Chuỗi lưu trong SQLite và trong RowPayload.
    public var description: String {
        let yearText = String(year), monthText = String(month), dayText = String(day)
        return String(repeating: "0", count: max(0, 4 - yearText.count)) + yearText + "-"
            + (monthText.count < 2 ? "0" + monthText : monthText) + "-" + (dayText.count < 2 ? "0" + dayText : dayText)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}
