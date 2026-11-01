"""SPEC-sync §2 — Hybrid Logical Clock."""
from __future__ import annotations
from dataclasses import dataclass
import calendar
from datetime import datetime, timezone

MAX_DRIFT = 300_000
MAX_COUNTER = 0xFFFF


class CounterOverflow(Exception): ...
class DuplicateNode(Exception): ...


@dataclass(frozen=True, order=True)
class HLC:
    millis: int
    counter: int
    node: str

    def __str__(self) -> str:
        dt = datetime.fromtimestamp(self.millis / 1000, tz=timezone.utc)
        iso = dt.strftime("%Y-%m-%dT%H:%M:%S.") + f"{self.millis % 1000:03d}Z"
        return f"{iso}-{self.counter:04X}-{self.node}"

    @staticmethod
    def parse(s: str) -> "HLC":
        if len(s) != 46:
            raise ValueError("bad hlc length")
        iso, counter, node = s[:24], s[25:29], s[30:]
        dt = datetime.strptime(iso[:19], "%Y-%m-%dT%H:%M:%S")
        millis = calendar.timegm(dt.timetuple()) * 1000 + int(iso[20:23])
        return HLC(millis, int(counter, 16), node)


class Clock:
    def __init__(self, node: str, millis: int = 0, counter: int = 0):
        self.node, self.millis, self.counter = node, millis, counter
        self.warnings: list[str] = []

    def tick(self, phys: int) -> HLC:
        l2 = max(self.millis, phys)
        c2 = self.counter + 1 if l2 == self.millis else 0
        if c2 > MAX_COUNTER:
            raise CounterOverflow()
        self.millis, self.counter = l2, c2
        return HLC(l2, c2, self.node)

    def receive(self, remote: HLC, phys: int) -> None:
        if remote.node == self.node and (remote.millis, remote.counter) > (self.millis, self.counter):
            raise DuplicateNode()
        if remote.millis - phys > MAX_DRIFT:
            self.warnings.append("ClockDrift")
            return
        l, c = self.millis, self.counter
        l2 = max(l, phys, remote.millis)
        if l2 == l and l2 == remote.millis:
            c2 = max(c, remote.counter) + 1
        elif l2 == l:
            c2 = c + 1
        elif l2 == remote.millis:
            c2 = remote.counter + 1
        else:
            c2 = 0
        if c2 > MAX_COUNTER:
            raise CounterOverflow()
        self.millis, self.counter = l2, c2
