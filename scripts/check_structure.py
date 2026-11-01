#!/usr/bin/env python3
"""Kiểm vị trí và tên file theo docs/architecture/module-structure.md (ADR-0008, ADR-0017).

Bắt các lỗi agent hay mắc:
- tạo thư mục hay target lạ;
- file `Utils`/`Helpers`;
- tên file không khớp type bên trong;
- Feature import Persistence.

Chạy ở CI và lefthook:  python3 -I scripts/check_structure.py
Muốn thêm thư mục được phép: sửa bảng ALLOWED dưới đây + module-structure.md trong cùng PR (cần lý do).
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

ROOT_DIRS = {"App", "Packages", "design", "docs", "schema", "scripts", "reference", "TestVectors", ".github", ".claude"}
PACKAGES = {"LifeOSCore", "LifeOSData", "LifeOSPlatform", "LifeOSDesignSystem", "LifeOSFeatures"}

# target → (thư mục con cấp 1 được phép, file ở gốc target: None = mọi tên, set = chỉ các tên này, regex = khớp mẫu)
ANY = None
ALLOWED: dict[str, tuple[set[str], object]] = {
    "Domain": ({"Model", "Values", "Rules", "Errors", "Ports", "ReadModels"}, set()),
    "Capture": (set(), ANY),
    "SyncCore": ({"Clock", "Model", "Merge", "Transport", "Coordinator"}, set()),
    "CryptoCore": ({"Envelope", "Keys"}, {"CryptoProvider.swift"}),
    "TestSupport": ({"Fakes", "Fixtures"}, ANY),
    "Persistence": ({"Database", "Migrations", "Tables", "Repositories", "Queries"}, set()),
    "CloudSync": (set(), ANY),
    "CryptoApple": (set(), ANY),
    "CloudKitTransport": (set(), ANY),
    "PlatformServices": (set(), ANY),
    "DesignSystem": ({"Components", "Foundation", "Generated", "Resources"}, {"Catalog.swift"}),
    "FeatureSupport": (set(), ANY),
    "AppFeature": (set(), ANY),
}
FEATURE_SUBDIRS = {"Components", "Strings", "Previews"}
FEATURE_ROOT = re.compile(r"^[A-Z][A-Za-z0-9]*(Screen|Store|Snapshot|Feature)\.swift$")
BANNED = re.compile(r"(Utils?|Helpers?|Common|Misc|Constants|Extensions|Stuff)\.swift$")
DECL = re.compile(r"^(?:@[\w()., \"]+\s+)*(?:public\s+|internal\s+|private\s+|fileprivate\s+)?(?:final\s+)?"
                  r"(?:struct|class|enum|protocol|actor|extension)\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
TYPE_DECL = re.compile(r"^(?:@[\w()., \"]+\s+)*(?:public\s+|internal\s+|private\s+|fileprivate\s+)?(?:final\s+)?"
                       r"(?:struct|class|enum|protocol|actor)\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
# Thư mục gom theo chủ đề (token, modifier), bỏ qua luật tên file. [Dự án]
GROUPED_DIRS = ("/Generated/", "/Previews/", "DesignSystem/Foundation/")
IMPORT = re.compile(r"^\s*import\s+(\w+)", re.M)


def files() -> list[Path]:
    try:
        out = subprocess.run(["git", "ls-files", "--cached", "--others", "--exclude-standard"],
                             cwd=ROOT, capture_output=True, text=True, check=True).stdout.split("\n")
        paths = [ROOT / p for p in out if p]
        if paths:
            return [p for p in paths if p.exists()]
    except (OSError, subprocess.CalledProcessError):
        pass
    skip = {".git", ".build", "node_modules", ".next", ".swiftpm", "__pycache__"}
    return [p for p in ROOT.rglob("*") if p.is_file() and not (set(p.relative_to(ROOT).parts) & skip)]


def targets_of(pkg: str) -> set[str]:
    manifest = ROOT / "Packages" / pkg / "Package.swift"
    return set(re.findall(r'\.(?:target|testTarget)\(\s*name:\s*"(\w+)"', manifest.read_text())) if manifest.exists() else set()


def main() -> int:
    errs: list[str] = []
    declared = {pkg: targets_of(pkg) for pkg in PACKAGES}
    for p in files():
        rel = p.relative_to(ROOT)
        parts = rel.parts
        if len(parts) > 1 and parts[0] not in ROOT_DIRS:
            errs.append(f"{rel}: thư mục gốc lạ '{parts[0]}' (được phép: {', '.join(sorted(ROOT_DIRS))})")
            continue
        if p.suffix != ".swift":
            continue
        if BANNED.search(p.name):
            errs.append(f"{rel}: tên file bị cấm, đặt theo việc nó làm hoặc <Type>+<Mục đích>.swift (conventions §2)")
        if parts[0] == "App":
            continue
        if parts[0] != "Packages":
            errs.append(f"{rel}: file Swift phải nằm trong Packages/ hoặc App/")
            continue
        if parts[1] not in PACKAGES:
            errs.append(f"{rel}: gói lạ '{parts[1]}'; gói mới cần ADR")
            continue
        if p.name == "Package.swift" and len(parts) == 3:
            continue
        if len(parts) < 5 or parts[2] not in ("Sources", "Tests"):
            errs.append(f"{rel}: phải nằm trong Packages/<gói>/Sources/<target>/ hoặc Tests/<target>/")
            continue
        pkg, kind, target = parts[1], parts[2], parts[3]
        if target not in declared[pkg]:
            errs.append(f"{rel}: target '{target}' chưa khai báo trong {pkg}/Package.swift")
        inner = parts[4:]
        text = p.read_text(errors="ignore")
        if kind == "Tests":
            if not p.name.endswith("Tests.swift"):
                errs.append(f"{rel}: file test phải kết thúc bằng Tests.swift")
            continue
        if pkg == "LifeOSFeatures" and target not in ALLOWED:
            if len(inner) > 1 and inner[0] not in FEATURE_SUBDIRS:
                errs.append(f"{rel}: trong Feature chỉ có {sorted(FEATURE_SUBDIRS)} (module-structure §3)")
            elif len(inner) == 1 and not FEATURE_ROOT.match(p.name):
                errs.append(f"{rel}: gốc Feature chỉ chứa <Name>Screen/Store/Snapshot.swift; view con vào Components/")
            for mod in IMPORT.findall(text):
                if mod in {"Persistence", "CloudSync", "SQLiteData", "GRDB", "CloudKitTransport", "CryptoApple", "PlatformServices"}:
                    errs.append(f"{rel}: Feature không import {mod}; dùng port trong Domain (ADR-0017)")
        elif target in ALLOWED:
            subdirs, root_files = ALLOWED[target]
            if len(inner) > 1 and inner[0] not in subdirs:
                errs.append(f"{rel}: thư mục '{inner[0]}' không có trong {target} (được phép: {sorted(subdirs) or 'không có thư mục con'})")
            if len(inner) == 1 and root_files is not ANY and p.name not in root_files:
                errs.append(f"{rel}: không đặt file ở gốc {target}; dùng một trong {sorted(subdirs)}")
        if any(x in str(rel) for x in GROUPED_DIRS) or p.name == "Catalog.swift":
            continue
        # Google Swift Style Guide: "A file that primarily contains a single type has the name of that type";
        # extension thì đặt <Type>+<Mục đích>.swift. File có nhiều type ngang nhau được đặt tên chung (references.md S-GOOG).
        base = p.stem.split("+")[0]
        types = set(TYPE_DECL.findall(text))
        names = set(DECL.findall(text))
        if len(types) == 1 and base not in types and f"{base}Module" not in types:
            errs.append(f"{rel}: file chỉ có một type '{next(iter(types))}' thì phải tên {next(iter(types))}.swift (S-GOOG)")
        elif not types and names and base not in names:
            errs.append(f"{rel}: file extension phải tên <Type>+<Mục đích>.swift (S-GOOG)")
    if errs:
        print("\n".join(errs))
        print(f"\n{len(errs)} lỗi cấu trúc. Xem docs/architecture/module-structure.md §4 và scripts/new.py.")
        return 1
    print("structure OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
