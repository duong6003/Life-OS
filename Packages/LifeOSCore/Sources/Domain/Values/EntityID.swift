/// ID có kiểu của một entity (ADR-0014): `EntityID<TaskItem>` không lẫn được với `EntityID<Habit>`.
/// `raw` là UUID chữ thường (v7 cho bản ghi thường, v5 cho khoá tự nhiên). LOS-010 thêm hàm sinh v7/v5.
public struct EntityID<Entity>: Hashable, Sendable, CustomStringConvertible {
    public let raw: String

    public init(_ raw: String) {
        self.raw = raw
    }

    public var description: String { raw }
}
