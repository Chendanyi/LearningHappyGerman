#!/usr/bin/env python3
"""Fail if any B1 lemma (normalized) appears in A1 or A2 libraries in full_vocabulary.json."""
from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    path = root / "LearnHappyGerman" / "full_vocabulary.json"
    if len(sys.argv) > 1:
        path = Path(sys.argv[1])
    data = json.loads(path.read_text(encoding="utf-8"))
    words = data.get("words", [])

    def lemmas(level: str) -> set[str]:
        return {w["germanWord"].casefold() for w in words if w.get("level") == level}

    a1, a2, b1 = lemmas("A1"), lemmas("A2"), lemmas("B1")
    leak = (b1 & a1) | (b1 & a2)
    if leak:
        print("LEVEL OVERLAP (B1 vs A1/A2):", ", ".join(sorted(leak)))
        sys.exit(1)
    print("audit_level_overlap: OK — no B1 lemma duplicated in A1/A2.")


if __name__ == "__main__":
    main()
