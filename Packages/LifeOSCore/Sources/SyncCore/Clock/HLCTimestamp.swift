/// HLC theo SPEC-sync §2. Khung: LOS-012 cài tick/receive và qua TestVectors/hlc/*.
public struct HLCTimestamp: Hashable, Comparable, Sendable {
    /// Dạng chuỗi 46 ký tự; so sánh chuỗi = so sánh thời gian (SPEC-sync §2.1).
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}
