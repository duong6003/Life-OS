"""SPEC-sync §6 — hợp nhất một hàng (hàm thuần)."""
from __future__ import annotations
from .ids import v5

KEEP_BOTH = {("journal_entry", "body")}


def policy(tbl: str, col: str) -> str:
    return "keepBoth" if (tbl, col) in KEEP_BOTH else "lww"


def merge_row(tbl: str, row_id: str, local: dict | None, remote: dict, local_dirty: set[str]):
    """local/remote: {col: {"v":..., "h": "...", "b"?: "..."}}. Trả (fields, conflicts, changed_cols)."""
    local = local or {}
    out, conflicts, changed = {}, [], []
    for col in sorted(set(local) | set(remote)):
        L, R = local.get(col), remote.get(col)
        if R is None:
            out[col] = L; continue
        if L is None:
            out[col] = R; changed.append(col); continue
        if R["h"] == L["h"]:
            out[col] = L; continue
        if policy(tbl, col) == "lww" or col not in local_dirty:
            if R["h"] > L["h"]:
                out[col] = R; changed.append(col)
            else:
                out[col] = L
            continue
        # keepBoth, local dirty
        if R["h"] <= (L.get("b") or ""):
            out[col] = L; continue
        winner, loser = (R, L) if R["h"] > L["h"] else (L, R)
        out[col] = winner
        if winner is R:
            changed.append(col)
        conflicts.append({
            "id": v5(f"journal_conflict:{row_id}:{loser['h']}"),
            "entry_id": row_id, "body": loser["v"], "loser_hlc": loser["h"],
        })
    return out, conflicts, changed
