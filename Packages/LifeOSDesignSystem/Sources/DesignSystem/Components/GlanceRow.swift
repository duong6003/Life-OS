import SwiftUI

public struct GlanceItem: Identifiable, Sendable {
    public let id: String
    public let value: String
    public let label: String
    public let isAlert: Bool

    public init(id: String, value: String, label: String, isAlert: Bool = false) {
        self.id = id
        self.value = value
        self.label = label
        self.isAlert = isAlert
    }
}

/// Dải tóm tắt 3 ô dưới lời chào trên Hôm nay. Chạm một ô để cuộn tới thẻ tương ứng.
public struct GlanceRow: View {
    let items: [GlanceItem]
    let onSelect: (GlanceItem.ID) -> Void

    public init(items: [GlanceItem], onSelect: @escaping (GlanceItem.ID) -> Void) {
        self.items = items
        self.onSelect = onSelect
    }

    public var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Space.s2) { cells }
            VStack(spacing: Space.s2) { cells }
        }
    }

    private var cells: some View {
        ForEach(items) { item in
            Button {
                onSelect(item.id)
            } label: {
                VStack(alignment: .leading, spacing: Space.s0_5) {
                    Text(item.value)
                        .lifeOSText(.bodyStrong)
                        .foregroundStyle(LifeOSColor.text)
                        .contentTransition(.numericText())
                    Text(item.label)
                        .lifeOSText(.footnote)
                        .foregroundStyle(item.isAlert ? LifeOSColor.danger : LifeOSColor.text2)
                }
                .padding(.horizontal, Space.s3)
                .padding(.vertical, Space.s2)
                .frame(maxWidth: .infinity, minHeight: Layout.hit, alignment: .leading)
                .background(LifeOSColor.surface2, in: .rect(cornerRadius: Radius.md, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
        }
    }
}
