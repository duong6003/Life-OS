"""Đọc docs/plan/issues/*.md (frontmatter đơn giản) — dùng chung cho plan_graph.py và bootstrap_github.py."""
from __future__ import annotations
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ISSUES = ROOT / "docs" / "plan" / "issues"
MILESTONES = ["M0 Nền móng", "M1 Lõi dữ liệu cục bộ", "M2 MVP cục bộ", "M3 Bắt đầu",
              "M4 Đồng bộ iCloud", "M5 Hoàn thiện và beta", "M6 Sau MVP"]


def _list(v: str) -> list[str]:
    v = v.strip()
    return [x.strip() for x in v[1:-1].split(",") if x.strip()] if v.startswith("[") else [v]


def load() -> list[dict]:
    out = []
    for p in sorted(ISSUES.glob("LOS-*.md")):
        text = p.read_text()
        m = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.S)
        if not m:
            raise SystemExit(f"{p.name}: thiếu frontmatter")
        meta = {}
        for line in m.group(1).splitlines():
            k, _, v = line.partition(":")
            meta[k.strip()] = v.strip()
        out.append({
            "id": meta["id"], "title": meta["title"].strip('"'), "milestone": meta["milestone"].strip('"'),
            "labels": _list(meta.get("labels", "[]")), "depends_on": _list(meta.get("depends_on", "[]")),
            "size": meta.get("size", "M"), "body": m.group(2).strip(), "file": p.name,
        })
    return out


def validate(issues: list[dict]) -> list[str]:
    errs, ids = [], {i["id"] for i in issues}
    order = {m: n for n, m in enumerate(MILESTONES)}
    by = {i["id"]: i for i in issues}
    for i in issues:
        if i["milestone"] not in order:
            errs.append(f"{i['id']}: milestone lạ {i['milestone']}")
        for d in i["depends_on"]:
            if d not in ids:
                errs.append(f"{i['id']}: phụ thuộc không tồn tại {d}")
            elif order.get(by[d]["milestone"], 0) > order.get(i["milestone"], 0):
                errs.append(f"{i['id']} ({i['milestone']}) phụ thuộc {d} ở milestone sau ({by[d]['milestone']})")
    state: dict[str, int] = {}

    def visit(n: str, path: list[str]):
        if state.get(n) == 1:
            errs.append("vòng phụ thuộc: " + " → ".join(path + [n])); return
        if state.get(n) == 2 or n not in by:
            return
        state[n] = 1
        for d in by[n]["depends_on"]:
            visit(d, path + [n])
        state[n] = 2
    for i in issues:
        visit(i["id"], [])
    return errs
