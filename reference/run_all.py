"""Kiểm/sinh mọi test vector. `--check` (CI): báo lỗi nếu file trong TestVectors khác kết quả code tham chiếu."""
from __future__ import annotations
import os, subprocess, shutil, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
sys.path.insert(0, str(HERE))
import gen_vectors  # noqa: E402


def main() -> int:
    check = "--check" in sys.argv
    bad = 0
    for rel, content in gen_vectors.build().items():
        p = ROOT / "TestVectors" / rel
        if check:
            if not p.exists() or p.read_text() != content:
                print(f"STALE  TestVectors/{rel}"); bad += 1
        else:
            p.parent.mkdir(parents=True, exist_ok=True); p.write_text(content)
    node = shutil.which("node")
    ok_node = False
    if node:
        ver = subprocess.run([node, "--version"], capture_output=True, text=True).stdout.strip().lstrip("v").split(".")
        ok_node = len(ver) >= 2 and (int(ver[0]), int(ver[1])) >= (22, 6)
    if ok_node:
        env = dict(os.environ, TZ="Asia/Ho_Chi_Minh")
        args = [node, "--experimental-strip-types", "--no-warnings", str(HERE / "gen_quick_capture.mjs")] + (["--check"] if check else [])
        bad += subprocess.call(args, env=env) != 0
    else:
        print("SKIP   quick-capture (cần node ≥ 22.6)")
    print("OK" if not bad else f"{bad} lỗi")
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
