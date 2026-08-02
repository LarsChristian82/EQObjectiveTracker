# Locale consistency check (dev tool, not shipped).
# Scans every non-Lib .lua file for L["..."] usages and confirms each key is
# listed in Locales/enUS.lua, and that every translation file keys only on
# phrases the manifest knows about. A key in code but missing from the manifest
# still works at runtime (the metatable falls back to English) but will never be
# translated. A key in a translation file that is NOT in the manifest is dead
# weight - usually a phrase that was reworded in the code and orphaned here.
# Run after each extraction pass, and before any release:
#   python docs/_gen_enus.py   then   python docs/_verify_locale.py
import re, io, glob, sys

KEY = re.compile(r'L\["((?:[^"\\]|\\.)*)"\]')
PAIR = re.compile(r'^\s*L\["((?:[^"\\]|\\.)*)"\]\s*=\s*"((?:[^"\\]|\\.)*)"\s*$')
# %% must be matched FIRST so it is consumed as a literal percent rather than having its
# second % start a bogus spec - in "%d%% done" the flag class would otherwise eat the
# space and match "% d", counting two specifiers where there is one.
SPEC = re.compile(r'%%|%(?:\d+\$)?[-+ #0]*\d*(?:\.\d+)?([diouxXeEfgGqcs])')


def specs(s):
    """The ordered list of conversion types, ignoring %% literals.

    Compared as a SEQUENCE, not a count: swapping %s for %d keeps the count identical
    and still makes string.format raise on the argument it is handed.
    """
    return [m.group(1) for m in SPEC.finditer(s) if m.group(1)]


def strip_comments(s):
    # drop full-line Lua comments so doc examples like L["English string"] in
    # headers don't register as real keys. (Good enough; no block-comment use.)
    return '\n'.join(l for l in s.splitlines() if not l.lstrip().startswith('--'))


def keyset(path):
    s = strip_comments(io.open(path, encoding='utf-8', errors='replace').read())
    return set(m.group(1) for m in KEY.finditer(s))


manifest = keyset('Locales/enUS.lua')

code = {}
for path in glob.glob('**/*.lua', recursive=True):
    p = path.replace('\\', '/')
    if p.startswith('Libs/') or p.startswith('Locales/'):
        continue
    for k in keyset(p):
        code.setdefault(k, []).append(p)

print("distinct keys used in code:", len(code))
print("keys listed in enUS.lua   :", len(manifest))

problems = 0

missing = {k: v for k, v in code.items() if k not in manifest}
print("\nCODE keys MISSING from manifest (work, but are never translated):")
if missing:
    problems += len(missing)
    for k in sorted(missing):
        print("   !", repr(k[:60]), "<-", ", ".join(sorted(set(missing[k]))))
else:
    print("   (none - every code key is in the manifest)")

print("\nTRANSLATION files:")
for path in sorted(glob.glob('Locales/*.lua')):
    p = path.replace('\\', '/')
    if p.endswith('enUS.lua'):
        continue
    ks = keyset(p)
    orphans = sorted(k for k in ks if k not in manifest)

    # A translation whose format specifiers differ from its English key makes
    # string.format() raise the first time that line is drawn - at runtime, in one
    # language only, where nobody testing in English ever sees it. An added specifier
    # raises "no value"; a changed type raises on the argument it is handed.
    badfmt = []
    for line in io.open(p, encoding='utf-8').read().splitlines():
        if line.lstrip().startswith('--'):
            continue
        m = PAIR.match(line)
        if not m:
            continue
        want, got = specs(m.group(1)), specs(m.group(2))
        if got != want:
            badfmt.append((m.group(1), want, got))

    print("   %-18s %4d phrases, %d orphaned, %d bad format" %
          (p, len(ks), len(orphans), len(badfmt)))
    if orphans:
        problems += len(orphans)
        for k in orphans:
            print("      ! orphan:", repr(k[:60]))
    if badfmt:
        problems += len(badfmt)
        for k, want, got in badfmt:
            print("      ! format specifiers %s do not match the English key's %s: %s"
                  % (got, want, repr(k[:50])))

sys.exit(1 if problems else 0)
