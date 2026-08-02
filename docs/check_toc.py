#!/usr/bin/env python3
"""Guard against TOC drift.

Separate per-flavor TOC files are what let a git checkout run in-game with no build
step, but they cost four file lists to keep in sync. The realistic failure is adding
UI/Foo.lua and forgetting to list it. This checks both directions:

  1. every path referenced by any TOC exists on disk
  2. every authored .lua is referenced by the Mainline TOC

Run locally or in CI. Exits non-zero on any problem.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIRS = ("Locales", "Core", "Data", "UI", "Options")
REFERENCE_TOC = "EQObjectiveTracker_Mainline.toc"


def referenced_paths(toc: Path):
    out = []
    for raw in toc.read_text(encoding="utf-8-sig").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        out.append(line.replace("\\", "/"))
    return out


def main() -> int:
    tocs = sorted(ROOT.glob("*.toc"))
    if not tocs:
        print("error: no .toc files found at repo root")
        return 1

    problems = []

    for toc in tocs:
        for rel in referenced_paths(toc):
            if not (ROOT / rel).is_file():
                problems.append(f"{toc.name}: references missing file {rel}")

    ref = ROOT / REFERENCE_TOC
    if not ref.is_file():
        problems.append(f"missing reference TOC {REFERENCE_TOC}")
    else:
        listed = set(referenced_paths(ref))
        for d in SOURCE_DIRS:
            for lua in sorted((ROOT / d).rglob("*.lua")):
                rel = lua.relative_to(ROOT).as_posix()
                if rel not in listed:
                    problems.append(f"{REFERENCE_TOC}: does not list {rel}")

    if problems:
        for p in problems:
            print(f"error: {p}")
        return 1

    counts = ", ".join(f"{t.name}={len(referenced_paths(t))}" for t in tocs)
    print(f"TOC check passed ({counts})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
