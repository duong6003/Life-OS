#!/usr/bin/env python3
"""Sinh docs/architecture/inventory.md: danh mục mọi type công khai theo gói và target, kèm dòng mô tả `///` đầu tiên.

Agent đọc file này TRƯỚC khi tạo type mới (overview.md §4) để dùng lại thứ đã có.
  python3 scripts/inventory.py          # sinh lại
  python3 scripts/inventory.py --check  # CI: báo lỗi nếu file đã cũ
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs/architecture/inventory.md"
DECL = re.compile(
    r"^(?:@\w+(?:\([^)]*\))?\s+)*public\s+(?:final\s+)?(struct|class|enum|protocol|actor|typealias)\s+([A-Za-z_][A-Za-z0-9_]*)"
)
EXT = re.compile(r"^(?:@\w+\s+)*(?:public\s+)?extension\s+([A-Za-z_][A-Za-z0-9_.]*)")
PUBLIC_FUNC = re.compile(r"^\s{4}public\s+(?:static\s+)?(?:func|var|let)\s+([A-Za-z_][A-Za-z0-9_]*)")


def doc_above(lines: list[str], i: int) -> str:
    j = i - 1
    while j >= 0 and lines[j].strip().startswith("@"):
        j -= 1
    docs = []
    while j >= 0 and lines[j].strip().startswith("///"):
        docs.insert(0, lines[j].strip()[3:].strip())
        j -= 1
    text = " ".join(docs)
    first = re.split(r"(?<=[.!?])\s", text, maxsplit=1)[0] if text else ""
    return first.replace("|", "\\|")[:160]


def scan() -> dict[tuple[str, str], list[tuple[str, str, str, str]]]:
    out: dict[tuple[str, str], list[tuple[str, str, str, str]]] = {}
    for f in sorted((ROOT / "Packages").glob("*/Sources/**/*.swift")):
        rel = f.relative_to(ROOT)
        if "/Generated/" in str(rel):
            continue
        pkg, target = rel.parts[1], rel.parts[3]
        lines = f.read_text().splitlines()
        for i, line in enumerate(lines):
            if m := DECL.match(line):
                kind, name = m.groups()
                members = []
                for line2 in lines[i + 1:]:
                    if line2.startswith("}"):
                        break
                    if mm := PUBLIC_FUNC.match(line2):
                        members.append(mm.group(1))
                api = ", ".join(dict.fromkeys(members))[:120]
                out.setdefault((pkg, target), []).append((name, kind, str(rel.relative_to(f"Packages/{pkg}/Sources/{target}")), doc_above(lines, i) + (f" API: `{api}`" if api else "")))
            elif m := EXT.match(line):
                if "public" in line or any(PUBLIC_FUNC.match(l) for l in lines[i + 1:i + 30]):
                    out.setdefault((pkg, target), []).append((m.group(1) + " (ext)", "extension", str(rel.relative_to(f"Packages/{pkg}/Sources/{target}")), doc_above(lines, i)))
    return out


def render() -> str:
    data = scan()
    total = sum(len(v) for v in data.values())
    parts = [
        "# Danh mục thứ đã có (tự sinh)",
        "",
        "<!-- File do scripts/inventory.py sinh. Không sửa tay; CI kiểm bằng --check. -->",
        "",
        f"{total} khai báo công khai. **Tìm ở đây và bằng `rg` trước khi tạo type mới** (overview.md §4).",
        "Component UI có sẵn của hệ thống (Button, List, DatePicker…) xem bảng ánh xạ trong `Packages/LifeOSDesignSystem/README.md`.",
        "",
    ]
    for pkg in sorted({p for p, _ in data}):
        parts.append(f"## {pkg}")
        parts.append("")
        for (p, target), items in sorted(data.items()):
            if p != pkg:
                continue
            parts.append(f"### {target}")
            parts.append("")
            parts.append("| Tên | Loại | File | Mô tả |")
            parts.append("|---|---|---|---|")
            for name, kind, file, doc in items:
                parts.append(f"| `{name}` | {kind} | `{file}` | {doc} |")
            parts.append("")
    return "\n".join(parts).rstrip() + "\n"


def main() -> int:
    text = render()
    if "--check" in sys.argv:
        if not OUT.exists() or OUT.read_text() != text:
            print("inventory.md đã cũ: chạy python3 scripts/inventory.py rồi commit")
            return 1
        print("inventory OK")
        return 0
    OUT.write_text(text)
    print(f"đã ghi {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
