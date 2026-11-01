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
        let y = String(year), m = String(month), d = String(day)
        return String(repeating: "0", count: max(0, 4 - y.count)) + y + "-"
            + (m.count < 2 ? "0" + m : m) + "-" + (d.count < 2 ? "0" + d : d)
    }

    public static func < (lhs: LocalDate, rhs: LocalDate) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}
