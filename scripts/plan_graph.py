"""Kiểm plan và vẽ graph phụ thuộc vào docs/plan/roadmap-graph.md.
  python3 scripts/plan_graph.py          # ghi lại phần graph
  python3 scripts/plan_graph.py --check  # CI: lỗi nếu plan sai hoặc graph cũ
"""
from __future__ import annotations
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from plan_lib import ROOT, MILESTONES, load, validate  # noqa: E402

DOC = ROOT / "docs" / "plan" / "roadmap-graph.md"
BEGIN, END = "<!-- graph:begin -->", "<!-- graph:end -->"


def critical_path(issues):
    by = {i["id"]: i for i in issues}
    w = {"S": 1, "M": 2, "L": 3}
    memo: dict[str, tuple[int, list[str]]] = {}

    def longest(n):
        if n in memo: return memo[n]
        best = (0, [])
        for d in by[n]["depends_on"]:
            c = longest(d)
            if c[0] > best[0]: best = c
        memo[n] = (best[0] + w.get(by[n]["size"], 2), best[1] + [n])
        return memo[n]
    target = max((i for i in issues if i["milestone"] != MILESTONES[-1]), key=lambda i: longest(i["id"])[0])
    return longest(target["id"])


def render(issues) -> str:
    L = ["```mermaid", "flowchart LR"]
    for n, m in enumerate(MILESTONES):
        L.append(f'  subgraph M{n}["{m}"]')
        for i in issues:
            if i["milestone"] == m:
                nid = i["id"].replace("-", "")
                label = i["title"].replace('"', "'")
                L.append(f'    {nid}["{i["id"]}<br/>{label}"]')
        L.append("  end")
    for i in issues:
        for d in i["depends_on"]:
            L.append(f'  {d.replace("-", "")} --> {i["id"].replace("-", "")}')
    cp = critical_path(issues)[1]
    for i in issues:
        if "type:gate" in i["labels"]:
            L.append(f'  class {i["id"].replace("-", "")} gate')
    L.append("  class " + ",".join(x.replace("-", "") for x in cp) + " crit")
    L += ["  classDef gate fill:#fde68a,stroke:#b45309", "  classDef crit stroke:#dc2626,stroke-width:3px", "```"]
    rows = ["", "| Milestone | Số issue | Issue |", "|---|---|---|"]
    for m in MILESTONES:
        ids = [i["id"] for i in issues if i["milestone"] == m]
        rows.append(f"| {m} | {len(ids)} | {', '.join(ids)} |")
    rows += ["", "**Đường găng** (viền đỏ, ước lượng S=1, M=2, L=3): " + " → ".join(cp)]
    return "\n".join(L + rows)


def main():
    issues = load()
    errs = validate(issues)
    if errs:
        print("\n".join(errs)); return 1
    doc = DOC.read_text()
    a, b = doc.index(BEGIN) + len(BEGIN), doc.index(END)
    new = doc[:a] + "\n" + render(issues) + "\n" + doc[b:]
    if "--check" in sys.argv:
        if new != doc:
            print("roadmap-graph.md cũ: chạy python3 scripts/plan_graph.py"); return 1
        print(f"plan OK ({len(issues)} issue)"); return 0
    DOC.write_text(new); print(f"đã ghi graph ({len(issues)} issue)"); return 0


if __name__ == "__main__":
    raise SystemExit(main())
