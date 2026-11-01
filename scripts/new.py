#!/usr/bin/env python3
"""Tạo file mới đúng chỗ, đúng tên, kèm test, theo docs/architecture/recipes.md (ADR-0017).

  python3 scripts/new.py --list                          # các loại có thể tạo
  python3 scripts/new.py screen Tasks TaskDetail         # màn TaskDetail trong TasksFeature
  python3 scripts/new.py component StreakBadge           # component dùng chung (DesignSystem)
  python3 scripts/new.py entity Goal                     # entity Domain
  python3 scripts/new.py value Percent                   # kiểu giá trị Domain
  python3 scripts/new.py rule HabitStreak                # hàm nghiệp vụ thuần + test
  python3 scripts/new.py repository Habit                # port + bản giả + cài đặt SQLite + test
  python3 scripts/new.py query MonthSpending             # read model + query SQL + test
  python3 scripts/new.py table Goal                      # @Table row cho Persistence
  python3 scripts/new.py migration add_goal_table        # SQL mới trong schema/ + bản sao + Swift
  python3 scripts/new.py adr use-something               # ADR mới từ mẫu

Không ghi đè file đã có. Thêm --dry-run để chỉ in danh sách file. Sau khi tạo, script in các bước còn phải làm tay.
"""
from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CORE = "Packages/LifeOSCore"
DATA = "Packages/LifeOSData"
FEAT = "Packages/LifeOSFeatures"
DS = "Packages/LifeOSDesignSystem/Sources/DesignSystem"


def camel_ok(name: str) -> str:
    if not re.fullmatch(r"[A-Z][A-Za-z0-9]+", name):
        raise SystemExit(f"Tên '{name}' phải UpperCamelCase, chỉ chữ và số (conventions §1).")
    if re.search(r"(Utils?|Helpers?|Common|Misc|Manager|Stuff|Extensions?)$", name):
        raise SystemExit(f"Tên '{name}' bị cấm: đặt tên theo việc nó làm (conventions §2).")
    return name


def lower_first(s: str) -> str:
    return s[0].lower() + s[1:]


def snake(s: str) -> str:
    return re.sub(r"(?<!^)(?=[A-Z])", "_", s).lower()


# ---------- mẫu ----------

def t_screen(feature: str, name: str) -> dict[str, str]:
    f = f"{feature}Feature"
    return {
        f"{FEAT}/Sources/{f}/{name}Screen.swift": f'''import DesignSystem
import Domain
import FeatureSupport
import SwiftUI

/// Màn {name}. Spec: docs/design/screens/{snake(name)}.md. Chỉ bố cục; mọi hành động gọi Store.
public struct {name}Screen: View {{
    @State private var store: {name}Store

    public init(store: {name}Store) {{
        _store = State(initialValue: store)
    }}

    public var body: some View {{
        content
            .task {{ store.start() }}
            .onDisappear {{ store.stop() }}
    }}

    @ViewBuilder private var content: some View {{
        // Vẽ từ store.snapshot; không truy vấn, không tạo formatter ở đây (AGENTS.md, Hiệu năng).
        Text("{name}")
            .lifeOSText(.title1)
    }}
}}
''',
        f"{FEAT}/Sources/{f}/{name}Store.swift": f'''import Domain
import FeatureSupport
import Observation

/// Trạng thái + hành động của màn {name} (ADR-0007). Phụ thuộc là port trong Domain, tiêm qua init (ADR-0017).
@Observable @MainActor
public final class {name}Store {{
    public private(set) var snapshot: {name}Snapshot = .empty
    public private(set) var state: ScreenState = .idle

    @ObservationIgnored private var observation: Task<Void, Never>?

    public init() {{}} // thêm port cần dùng: init(tasks: any TaskRepository, clock: any AppClock)

    public func start() {{
        // observation = Task {{ [port] in for await next in port.observe…() {{ self.snapshot = next }} }}
    }}

    public func stop() {{
        observation?.cancel()
        observation = nil
    }}
}}
''',
        f"{FEAT}/Sources/{f}/{name}Snapshot.swift": f'''/// Dữ liệu đã định hình cho màn {name}. Nếu dữ liệu đọc thẳng từ DB, chuyển type này sang
/// Domain/ReadModels bằng `scripts/new.py query {name}` và xoá file này.
public struct {name}Snapshot: Sendable, Hashable {{
    public static let empty = {name}Snapshot()
}}
''',
        f"{FEAT}/Sources/{f}/Previews/{name}Screen+Previews.swift": f'''#if DEBUG
import SwiftUI

#Preview("Light") {{ {name}Screen(store: {name}Store()) }}
#Preview("Dark") {{ {name}Screen(store: {name}Store()).preferredColorScheme(.dark) }}
#Preview("AX5") {{ {name}Screen(store: {name}Store()).dynamicTypeSize(.accessibility5) }}
#endif
''',
        f"{FEAT}/Tests/{f}Tests/{name}StoreTests.swift": f'''import Testing
@testable import {f}

/// Test store bằng bản giả trong TestSupport, không cần simulator (testing.md).
@MainActor
@Test func {lower_first(name)}StartsEmpty() {{
    let store = {name}Store()
    #expect(store.snapshot == .empty)
}}
''',
    }


def t_component(name: str) -> dict[str, str]:
    return {f"{DS}/Components/{name}.swift": f'''import SwiftUI

/// Component dùng chung. Nhận giá trị + closure, không biết Store hay Domain.
/// Thêm vào Catalog.swift và bảng ánh xạ trong README của gói.
public struct {name}: View {{
    public init() {{}}

    public var body: some View {{
        EmptyView()
            .accessibilityElement(children: .combine) // nhãn VoiceOver bắt buộc (conventions §5)
    }}
}}
'''}


def t_entity(name: str) -> dict[str, str]:
    return {
        f"{CORE}/Sources/Domain/Model/{name}.swift": f'''/// Entity {name}. Bảng: `{snake(name)}` (data-model.md). Giá trị thuần, không I/O.
public struct {name}: Sendable, Hashable, Identifiable {{
    public typealias ID = EntityID<{name}>
    public let id: ID

    public init(id: ID) {{
        self.id = id
    }}
}}
''',
        f"{CORE}/Tests/DomainTests/{name}Tests.swift": f'''import Testing
@testable import Domain

@Test func {lower_first(name)}IsValueType() {{
    // Thay bằng test hành vi thật của entity.
    #expect(true)
}}
''',
    }


def t_value(name: str) -> dict[str, str]:
    return {
        f"{CORE}/Sources/Domain/Values/{name}.swift": f'''/// Kiểu giá trị {name}. Kiểm hợp lệ trong init; không để giá trị sai tồn tại.
public struct {name}: Sendable, Hashable {{
}}
''',
        f"{CORE}/Tests/DomainTests/{name}Tests.swift": f'''import Testing
@testable import Domain

@Test func {lower_first(name)}RejectsInvalidInput() {{
    #expect(true)
}}
''',
    }


def t_rule(name: str) -> dict[str, str]:
    return {
        f"{CORE}/Sources/Domain/Rules/{name}.swift": f'''/// Quy tắc nghiệp vụ {name}. Ghi mã BR ở từng nhánh: `// BR-XXX-NN`. Hàm thuần, không I/O, không đồng hồ thật.
public enum {name} {{
}}
''',
        f"{CORE}/Tests/DomainTests/{name}Tests.swift": f'''import Testing
@testable import Domain

/// Tên test theo TC: test_TC_<MOD>_<NN>_… (AGENTS.md, Definition of Done).
@Test func {lower_first(name)}FollowsBusinessRule() {{
    #expect(true)
}}
''',
    }


def t_repository(name: str) -> dict[str, str]:
    p = f"{name}Repository"
    return {
        f"{CORE}/Sources/Domain/Ports/{p}.swift": f'''/// Port đọc/ghi {name} (ADR-0017). Cài đặt: `SQLite{p}` (Persistence); bản giả: `Fake{p}` (TestSupport).
public protocol {p}: Sendable {{
    // func observeAll() -> AsyncStream<[{name}]>
    // func save(_ value: {name}) async throws
}}
''',
        f"{CORE}/Sources/TestSupport/Fakes/Fake{p}.swift": f'''import Domain

/// Bản giả trong bộ nhớ cho test store. Giữ hành vi giống SQLite{p} ở mức API.
public final class Fake{p}: {p}, @unchecked Sendable {{ // chỉ dùng trong test, một luồng
    public init() {{}}
}}
''',
        f"{DATA}/Sources/Persistence/Repositories/SQLite{p}.swift": f'''import Domain
import GRDB

/// Cài đặt {p} trên SQLite (ADR-0016). Ghi `updated_at`; xoá = đặt `deleted_at`. Không nhắc tới SyncEngine.
public struct SQLite{p}: {p} {{
    private let database: AppDatabase

    public init(database: AppDatabase) {{
        self.database = database
    }}
}}
''',
        f"{DATA}/Tests/PersistenceTests/SQLite{p}Tests.swift": f'''import Testing
import TestSupport
@testable import Persistence

/// DB tạm thật (testing.md, mức I).
@Test func sqlite{p}RoundTrips() async throws {{
    #expect(true)
}}
''',
    }


def t_query(name: str) -> dict[str, str]:
    return {
        f"{CORE}/Sources/Domain/ReadModels/{name}Snapshot.swift": f'''/// Read model cho {name}: dữ liệu đã gộp sẵn bằng SQL, chỉ giá trị (ADR-0017).
public struct {name}Snapshot: Sendable, Hashable {{
    public static let empty = {name}Snapshot()
    public init() {{}}
}}
''',
        f"{CORE}/Sources/Domain/Ports/{name}Reading.swift": f'''/// Port đọc {name}Snapshot. Cài đặt: `{name}Query` (Persistence).
public protocol {name}Reading: Sendable {{
    func observe() -> AsyncStream<{name}Snapshot>
}}
''',
        f"{DATA}/Sources/Persistence/Queries/{name}Query.swift": f'''import Domain
import GRDB

/// Truy vấn cho {name}. Phải có index cho mọi điều kiện lọc/sắp xếp (TC-PERF-10); gộp bằng SQL, không gộp trong Swift.
public struct {name}Query: {name}Reading {{
    private let database: AppDatabase

    public init(database: AppDatabase) {{
        self.database = database
    }}

    public func observe() -> AsyncStream<{name}Snapshot> {{
        AsyncStream {{ continuation in
            continuation.yield(.empty) // LOS-024: thay bằng ValueObservation .immediate
            continuation.finish()
        }}
    }}
}}
''',
        f"{DATA}/Tests/PersistenceTests/{name}QueryTests.swift": f'''import Testing
import TestSupport
@testable import Persistence

/// Chạy trên DB seed (data-model §5) và kiểm EXPLAIN QUERY PLAN không có SCAN bảng lớn.
@Test func {lower_first(name)}QueryUsesIndex() async throws {{
    #expect(true)
}}
''',
    }


def t_table(name: str) -> dict[str, str]:
    return {f"{DATA}/Sources/Persistence/Tables/{name}Row.swift": f'''import Domain
import SQLiteData

/// Một hàng bảng `{snake(name)}` (schema/*.sql). Ánh xạ 2 chiều với entity {name} ở Domain.
/// Tên cột phải khớp SQL; không đặt tên trùng tên dành riêng của CKRecord (ADR-0016).
@Table("{snake(name)}")
public struct {name}Row: Sendable, Hashable {{
    public let id: String
}}
'''}


def next_number(folder: Path, pattern: str, width: int) -> str:
    nums = [int(m.group(1)) for p in folder.glob("*") if (m := re.match(pattern, p.name))]
    return str((max(nums) if nums else 0) + 1).zfill(width)


def t_migration(slug: str) -> dict[str, str]:
    if not re.fullmatch(r"[a-z][a-z0-9_]+", slug):
        raise SystemExit("Tên migration dạng snake_case, ví dụ add_goal_table")
    n = next_number(ROOT / "schema", r"(\d{4})_", 4)
    camel = "".join(w.capitalize() for w in slug.split("_"))
    sql = f'''-- M{n}: {slug}. Chỉ THÊM (ADR-0003/0016): không đổi tên, không xoá cột.
-- Cột NOT NULL phải có "ON CONFLICT REPLACE" + DEFAULT. Bảng đồng bộ thì có deleted_at và thêm vào CloudSync.SyncTables.
'''
    return {
        f"schema/{n}_{slug}.sql": sql,
        f"{DATA}/Sources/Persistence/Migrations/sql/{n}_{slug}.sql": sql,
        f"{DATA}/Sources/Persistence/Migrations/M{n}_{camel}.swift": f'''/// Chạy schema/{n}_{slug}.sql. Đăng ký trong AppDatabase.migrator theo đúng thứ tự số.
/// Đã merge vào main thì không sửa file này nữa; cần đổi thì tạo migration mới.
enum M{n}_{camel} {{
    static let identifier = "{n}_{slug}"
    static let resource = "sql/{n}_{slug}"
}}
''',
    }


def t_adr(slug: str) -> dict[str, str]:
    if not re.fullmatch(r"[a-z0-9-]+", slug):
        raise SystemExit("Tên ADR dạng kebab-case, ví dụ use-tuist")
    folder = ROOT / "docs/architecture/adr"
    n = next_number(folder, r"(\d{4})-", 4)
    text = (folder / "0000-template.md").read_text().replace("ADR-NNNN", f"ADR-{n}")
    return {f"docs/architecture/adr/{n}-{slug}.md": text}


KINDS = {
    "screen": (t_screen, 2, "Màn mới trong một Feature: Screen, Store, Snapshot, Previews, test"),
    "component": (t_component, 1, "Component dùng chung trong DesignSystem"),
    "entity": (t_entity, 1, "Entity trong Domain/Model + test"),
    "value": (t_value, 1, "Kiểu giá trị trong Domain/Values + test"),
    "rule": (t_rule, 1, "Quy tắc nghiệp vụ thuần trong Domain/Rules + test"),
    "repository": (t_repository, 1, "Port + bản giả + SQLite…Repository + test"),
    "query": (t_query, 1, "Read model + port đọc + Query SQL + test"),
    "table": (t_table, 1, "@Table row trong Persistence/Tables"),
    "migration": (t_migration, 1, "SQL mới trong schema/ + bản sao + Swift migration"),
    "adr": (t_adr, 1, "ADR mới từ mẫu"),
}

NEXT_STEPS = {
    "screen": ["Viết docs/design/screens/<màn>.md trước (mẫu _template.md)",
               "Thêm testTarget '<X>FeatureTests' vào Packages/LifeOSFeatures/Package.swift nếu chưa có",
               "Nối Store trong AppFeature (AppEnvironment.live) và điều hướng",
               "Chuỗi vào Strings/Localizable.xcstrings; ảnh preview Light/Dark/AX5 trong PR"],
    "component": ["Thêm vào Catalog.swift", "Thêm dòng vào bảng ánh xạ trong Packages/LifeOSDesignSystem/README.md"],
    "entity": ["Cập nhật docs/architecture/data-model.md", "Cần lưu? → scripts/new.py migration + table + repository"],
    "value": ["Dùng ở mọi API thay cho kiểu trần (String/Double/Date)"],
    "rule": ["Ghi BR tương ứng trong docs/product/business-rules.md", "Đặt tên test theo TC liên quan"],
    "repository": ["Nối SQLite…Repository trong AppFeature", "Cần bảng mới? → scripts/new.py migration + table"],
    "query": ["Thêm index trong migration nếu lọc/sắp xếp", "Đo trên DB seed, ghi perf-log.md nếu là màn chính"],
    "table": ["Khớp tên cột với schema/*.sql"],
    "migration": ["Viết SQL theo luật ở header schema/0001_initial.sql", "Đăng ký trong AppDatabase.migrator",
                  "Bảng đồng bộ → thêm vào CloudSync.SyncTables + data-model.md + TC-SYNC-15"],
    "adr": ["Thêm dòng vào docs/architecture/adr/README.md"],
}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("kind", nargs="?")
    ap.add_argument("names", nargs="*")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    if a.list or not a.kind:
        for k, (_, _, d) in KINDS.items():
            print(f"  {k:<11} {d}")
        return 0
    if a.kind not in KINDS:
        raise SystemExit(f"Loại lạ '{a.kind}'. Xem --list.")
    fn, argc, _ = KINDS[a.kind]
    if len(a.names) != argc:
        raise SystemExit(f"'{a.kind}' cần {argc} tên. Ví dụ ở đầu file scripts/new.py.")
    names = a.names
    if a.kind not in ("migration", "adr"):
        names = [camel_ok(n) for n in names]
    if a.kind == "screen":
        feat_dir = ROOT / FEAT / "Sources" / f"{names[0]}Feature"
        if not feat_dir.is_dir():
            raise SystemExit(f"Không có {feat_dir.relative_to(ROOT)}. Feature mới cần ADR (module-structure §4).")
    files = fn(*names)
    clash = [p for p in files if (ROOT / p).exists()]
    if clash:
        raise SystemExit("Đã có, không ghi đè:\n  " + "\n  ".join(clash) + "\nMở rộng file có sẵn thay vì tạo bản thứ hai.")
    for rel, body in files.items():
        print(("sẽ tạo " if a.dry_run else "tạo   ") + rel)
        if not a.dry_run:
            path = ROOT / rel
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(body)
    print("\nCòn phải làm (recipes.md):")
    for s in NEXT_STEPS[a.kind]:
        print("  - " + s)
    return 0


if __name__ == "__main__":
    sys.exit(main())
