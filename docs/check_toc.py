#!/usr/bin/env python3
"""Guard against TOC drift.

Separate per-flavor TOC files are what let a git checkout run in-game with no build
step, but they cost one file list per flavor to keep in sync. This checks four things:

  1. every path referenced by any TOC exists on disk
  2. every authored .lua under SOURCE_DIRS is referenced by at least one TOC, so adding
     UI/Foo.lua and forgetting to list it is caught
  3. every path referenced by a NON-flavor TOC is also in the reference TOC, so the two
     retail files cannot drift apart
  4. '## Version:' and '## X-Curse-Project-ID:' agree across every TOC

Check 2 is deliberately "at least one TOC" rather than "the reference TOC". A flavor
file such as Data/Providers/QuestsClassic.lua is legitimately absent from the retail
TOCs, and a rule anchored on the reference TOC would reject it.

Check 4 exists because the packager reads both out of the TOC, so a one-sided edit ships
a zip whose halves disagree. Before the flavor TOCs landed the retail two were
byte-identical, which is the only reason nothing had ever caught it.

Run locally or in CI. Exits non-zero on any problem. docs/test_check_toc.py proves it
fires on each of these shapes and stays quiet on a good tree.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIRS = ("Locales", "Core", "Data", "UI", "Options")
REFERENCE_TOC = "EQObjectiveTracker_Mainline.toc"
FALLBACK_TOC = "EQObjectiveTracker.toc"
SHARED_HEADERS = ("Version", "X-Curse-Project-ID")

_HEADER = re.compile(r"^##\s*([^:]+):\s*(.*?)\s*$")


def parse_toc(toc: Path):
    files, headers = [], {}
    for raw in toc.read_text(encoding="utf-8-sig").splitlines():
        line = raw.strip()
        if not line:
            continue
        if line.startswith("##"):
            m = _HEADER.match(line)
            if m:
                headers[m.group(1).strip()] = m.group(2)
            continue
        if line.startswith("#"):
            continue
        files.append(line.replace("\\", "/"))
    return files, headers


def main(root: Path = ROOT) -> int:
    root = Path(root)
    tocs = sorted(root.glob("*.toc"))
    if not tocs:
        print("error: no .toc files found at repo root")
        return 1

    problems = []
    parsed = {}

    for toc in tocs:
        parsed[toc.name] = parse_toc(toc)
        for rel in parsed[toc.name][0]:
            if not (root / rel).is_file():
                problems.append(f"{toc.name}: references missing file {rel}")

    for field in SHARED_HEADERS:
        seen = {}
        for name in sorted(parsed):
            seen.setdefault(parsed[name][1].get(field), []).append(name)
        if len(seen) > 1:
            detail = "; ".join(
                f"{value!r} in {', '.join(names)}"
                for value, names in sorted(seen.items(), key=lambda kv: str(kv[0]))
            )
            problems.append(f"## {field}: disagrees across TOCs - {detail}")

    if REFERENCE_TOC not in parsed:
        problems.append(f"missing reference TOC {REFERENCE_TOC}")
    else:
        anywhere = set()
        for name in parsed:
            anywhere.update(parsed[name][0])
        for d in SOURCE_DIRS:
            src = root / d
            if not src.is_dir():
                continue
            for lua in sorted(src.rglob("*.lua")):
                rel = lua.relative_to(root).as_posix()
                if rel not in anywhere:
                    problems.append(f"no TOC lists {rel}")

        # The retail pair must stay in step with each other. Flavor TOCs are exempt by
        # design - that is the whole point of having them.
        listed = set(parsed[REFERENCE_TOC][0])
        if FALLBACK_TOC in parsed:
            for rel in parsed[FALLBACK_TOC][0]:
                if rel not in listed:
                    problems.append(
                        f"{FALLBACK_TOC}: lists {rel}, which {REFERENCE_TOC} does not")
            for rel in listed:
                if rel not in set(parsed[FALLBACK_TOC][0]):
                    problems.append(
                        f"{REFERENCE_TOC}: lists {rel}, which {FALLBACK_TOC} does not")

    if problems:
        for p in problems:
            print(f"error: {p}")
        return 1

    counts = ", ".join(
        f"{name}={len(parsed[name][0])}" for name in sorted(parsed))
    print(f"TOC check passed ({counts})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
