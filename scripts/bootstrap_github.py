"""Tạo nhãn, milestone, issue và quan hệ "blocked by" trên GitHub từ docs/plan/issues/*.md.

  python3 scripts/bootstrap_github.py --repo owner/life-os            # xem trước, không ghi gì
  python3 scripts/bootstrap_github.py --repo owner/life-os --apply    # thực hiện

Cần `gh` đã đăng nhập (`gh auth login`). Chạy lại an toàn: issue đã có (tiêu đề bắt đầu bằng "[LOS-xxx]") sẽ được
cập nhật tiêu đề, milestone, nhãn, thân bài và quan hệ blocked-by thay vì tạo mới. Kết quả ánh xạ LOS → số issue ghi vào scripts/.issue-map.json (nên commit).
"""
from __future__ import annotations
import argparse, json, re, subprocess, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from plan_lib import ROOT, MILESTONES, load, validate  # noqa: E402

MAP = ROOT / "scripts" / ".issue-map.json"
RENAMED_MILESTONES = {"M3 Bắt đầu và khôi phục": "M3 Bắt đầu"}   # ADR-0016
COLORS = {"type": "1f6feb", "area": "8957e5", "mod": "2da44e", "perf": "d29922", "agent-ok": "0e8a16", "needs-decision": "d93f0b"}


def gh(*args: str, input: str | None = None, check: bool = True) -> str:
    r = subprocess.run(["gh", *args], input=input, capture_output=True, text=True)
    if check and r.returncode != 0:
        raise SystemExit(f"gh {' '.join(args)} lỗi:\n{r.stderr}")
    return r.stdout


def link_refs(body: str, numbers: dict[str, int]) -> str:
    return re.sub(r"LOS-(\d{3})", lambda m: f"LOS-{m.group(1)} (#{numbers[f'LOS-{m.group(1)}']})" if f"LOS-{m.group(1)}" in numbers else m.group(0), body)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", required=True)
    ap.add_argument("--apply", action="store_true")
    a = ap.parse_args()
    issues = load()
    if errs := validate(issues):
        print("\n".join(errs)); return 1
    labels = sorted({l for i in issues for l in i["labels"]})
    print(f"{len(labels)} nhãn, {len(MILESTONES)} milestone, {len(issues)} issue → {a.repo}")
    if not a.apply:
        for i in issues:
            print(f"  [{i['id']}] {i['title']}  ({i['milestone']}; blocked by {', '.join(i['depends_on']) or '—'})")
        print("Xem trước xong. Thêm --apply để tạo."); return 0

    for l in labels:
        color = COLORS.get(l.split(":")[0], "ededed")
        gh("label", "create", l, "--repo", a.repo, "--color", color, "--force")
    existing_ms = {m["title"]: m["number"] for m in json.loads(gh("api", f"repos/{a.repo}/milestones?state=all&per_page=100"))}
    for old, new in RENAMED_MILESTONES.items():   # đổi tên milestone cũ thay vì tạo trùng
        if old in existing_ms and new not in existing_ms:
            gh("api", "-X", "PATCH", f"repos/{a.repo}/milestones/{existing_ms[old]}", "-f", f"title={new}")
            existing_ms[new] = existing_ms.pop(old); print("đổi tên milestone", old, "→", new)
    for m in MILESTONES:
        if m not in existing_ms:
            gh("api", f"repos/{a.repo}/milestones", "-f", f"title={m}")

    found = json.loads(gh("issue", "list", "--repo", a.repo, "--state", "all", "--limit", "500", "--json", "number,title,labels"))
    numbers, current_labels = {}, {}
    for f in found:
        if m := re.match(r"^\[(LOS-\d{3})\]", f["title"]):
            numbers[m.group(1)] = f["number"]
            current_labels[m.group(1)] = {l["name"] for l in f.get("labels", [])}
    for i in issues:                      # lượt 1: tạo những issue chưa có
        if i["id"] in numbers:
            continue
        url = gh("issue", "create", "--repo", a.repo, "--title", f"[{i['id']}] {i['title']}", "--body", i["body"],
                 "--milestone", i["milestone"], *sum((["--label", l] for l in i["labels"]), []))
        numbers[i["id"]] = int(url.strip().rsplit("/", 1)[-1]); print("tạo", i["id"], "→ #", numbers[i["id"]])
    for i in issues:                      # lượt 2: đồng bộ tiêu đề, milestone, nhãn, thân bài + quan hệ blocked-by
        n = numbers[i["id"]]
        stale = sorted(current_labels.get(i["id"], set()) - set(i["labels"]))
        gh("issue", "edit", str(n), "--repo", a.repo, "--title", f"[{i['id']}] {i['title']}",
           "--milestone", i["milestone"], "--body", link_refs(i["body"], numbers),
           *sum((["--add-label", l] for l in i["labels"]), []), *sum((["--remove-label", l] for l in stale), []))
        want = {numbers[d] for d in i["depends_on"]}
        r = subprocess.run(["gh", "api", f"repos/{a.repo}/issues/{n}/dependencies/blocked_by"], capture_output=True, text=True)
        if r.returncode == 0:             # gỡ quan hệ blocked-by không còn trong depends_on
            for b in json.loads(r.stdout or "[]"):
                if b.get("number") not in want:
                    subprocess.run(["gh", "api", "-X", "DELETE", f"repos/{a.repo}/issues/{n}/dependencies/blocked_by/{b['id']}"],
                                   capture_output=True, text=True)
                    print(f"  gỡ blocked-by #{b.get('number')} khỏi {i['id']}")
        for d in i["depends_on"]:
            dep_id = json.loads(gh("api", f"repos/{a.repo}/issues/{numbers[d]}"))["id"]
            r = subprocess.run(["gh", "api", "-X", "POST", f"repos/{a.repo}/issues/{n}/dependencies/blocked_by",
                                "-F", f"issue_id={dep_id}"], capture_output=True, text=True)
            if r.returncode != 0 and "already" not in r.stderr.lower():
                print(f"  (không đặt được blocked-by {d} → {i['id']}; phụ thuộc vẫn ghi trong thân bài)")
    MAP.write_text(json.dumps(dict(sorted(numbers.items())), indent=2) + "\n")
    print(f"Xong. Ánh xạ ghi vào {MAP.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
