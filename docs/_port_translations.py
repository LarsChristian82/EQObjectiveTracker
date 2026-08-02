# Rebuild Locales/frFR.lua, ruRU.lua and koKR.lua, carrying across every translation
# Everything Quests already has for a phrase EQOT words identically.
#
# ADDITIVE, like EQ's own _merge_frfr.py: a translation already present in EQOT's
# locale file WINS over EQ's and is preserved. That is what lets a translation be
# hand-corrected here, or contributed by someone who does not have EQ, without the
# next run throwing it away. Only phrases EQOT has no translation for are filled in
# from EQ.
#
# EQOT has no CurseForge localization page, so EQ is the only bulk source available.
# The English string is the key in both addons, so an identically worded phrase can
# inherit EQ's approved translation with no judgement involved. Anything worded
# differently is left out and renders in English via the enUS.lua metatable.
#
# Matching is done on the DECODED BYTES, not the source text: EQ writes an em dash
# as a literal UTF-8 character while EQOT writes "\226\128\148" to keep its .lua
# files ASCII. Those are the same Lua string at runtime and must match here too.
#
# Re-run after regenerating the manifest, and whenever EQ ships new translations:
#   python docs/_gen_enus.py   then   python docs/_port_translations.py
#   then   python docs/_verify_locale.py
import re, io, os, sys

EQ_DEFAULT = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                          '..', '..', 'EverythingQuests')

LOCALES = [
    ('frFR', 'French'),
    ('ruRU', 'Russian'),
    ('koKR', 'Korean'),
]

# An identical English key does NOT imply an identical meaning. Where EQ uses the same
# word for something else, its translation is not just imperfect but WRONG, and carrying
# it across is worse than leaving the phrase in English. Each entry here needs EQ's
# conflicting usage named, so the call can be re-checked if EQ's wording changes.
#
# Judgement line: exclude when the inherited word means the wrong THING, keep it when it
# is merely stylistically off. "Daily"/"Weekly" are deliberately NOT excluded - EQ uses
# them for a History time-granularity toggle rather than a quest-type filter, so ruRU
# gets adverbs where adjectives would read better, but the meaning still lands.
# Empty today, and that is the point: the phrase that created this guard - "Back" for the
# cloak slot, which inherited EQ's Chain Guide go-back button and read "Retour" in French -
# was fixed at the source instead. Data/QuestRewards.lua now resolves slot names through
# Blizzard's own _G[equipLoc] globals, so the phrase is not in the manifest at all and is
# right in every client language rather than the ones we ship. Prefer that shape when it
# exists; reach for this list only when there is no Blizzard string to defer to.
AMBIGUOUS = set()

PAIR = re.compile(r'^\s*L\["((?:[^"\\]|\\.)*)"\]\s*=\s*"((?:[^"\\]|\\.)*)"\s*$')
MANIFEST = re.compile(r'^L\["((?:[^"\\]|\\.)*)"\]\s*=\s*true\s*$')
GROUP = re.compile(r'^--\s+(\S+\.lua)\s*$')

HEADER = '''-- Locales/%(code)s.lua
-- %(lang)s (%(code)s) translations for EQ Objective Tracker.
--
-- HOW TO USE: type the %(lang)s translation between the quotes after each "=".
-- The English text is the key inside L["..."]. Example:
--     L["Hide tracker in combat"] = "..."
--
-- KEEP THESE EXACTLY AS THEY APPEAR (do not translate them):
--   |cffaaaaaa ... |r   -> colour codes
--   %%d  %%s              -> numbers / names get inserted here
--   \\n                  -> line break
--   \\"                  -> an escaped quote inside the text
--
-- Any phrase absent from this file stays English via the metatable in
-- Locales/enUS.lua, so a partial translation is always safe.
--
-- NOTE: do NOT add an @localization@ packager token here. CurseForge
-- localization is not enabled on this project. That token fails the release
-- build with errorCode 1002. Translations are bundled directly below.
--
-- Maintained by docs/_port_translations.py, which fills in any phrase Everything
-- Quests already translates and words identically. It is ADDITIVE: a line already
-- here wins over EQ's and survives a re-run, so corrections and contributions made
-- in this file are safe to keep.

if GetLocale() ~= "%(code)s" then return end

local _, ns = ...
local L = ns.L
'''

ESCAPES = {'a': '\a', 'b': '\b', 'f': '\f', 'n': '\n', 'r': '\r',
           't': '\t', 'v': '\v', '\\': '\\', '"': '"', "'": "'"}


def decode(s):
    """Decode a Lua short-string body to the BYTES Lua would hold at runtime.

    Bytes, not characters, is the whole point. EQ writes an em dash as the literal
    UTF-8 character while EQOT writes "\\226\\128\\148" to keep its .lua files ASCII.
    Those are one identical Lua string at runtime, but comparing them as decoded
    Python text makes them one character against three, and the phrase silently
    misses its translation with nothing to show it happened.
    """
    out, i, n = [], 0, len(s)
    while i < n:
        c = s[i]
        if c != '\\':
            out.append(c.encode('utf-8'))
            i += 1
            continue
        i += 1
        if i >= n:
            break
        e = s[i]
        if e in ESCAPES:
            out.append(ESCAPES[e].encode('utf-8'))
            i += 1
        elif e.isdigit():
            digits = ''
            while i < n and s[i].isdigit() and len(digits) < 3:
                digits += s[i]
                i += 1
            out.append(bytes([int(digits) & 0xFF]))
        else:
            out.append(e.encode('utf-8'))
            i += 1
    return b''.join(out)


def read_eq(path, warn=False):
    """decoded key -> source-form value, for non-empty translations.

    Only the canonical one-line L["k"] = "v" form is understood. This file gets
    REWRITTEN from what this returns, so anything unparsed would be dropped without
    a trace - hence warn=True when reading a file we are about to overwrite.
    """
    out = {}
    for n, line in enumerate(io.open(path, encoding='utf-8').read().splitlines(), 1):
        if line.lstrip().startswith('--'):
            continue
        m = PAIR.match(line)
        if m and m.group(2):
            out[decode(m.group(1))] = m.group(2)
        elif warn and 'L[' in line:
            print('  ! %s:%d not in L["key"] = "value" form, would be DROPPED: %s'
                  % (path, n, line.strip()[:70]))
    return out


def read_manifest(path):
    """[(group_comment_or_None, source_key), ...] in manifest order."""
    out, group = [], None
    for line in io.open(path, encoding='utf-8').read().splitlines():
        g = GROUP.match(line)
        if g:
            group = g.group(1)
            continue
        m = MANIFEST.match(line)
        if m:
            out.append((group, m.group(1)))
    return out


def main():
    eq = os.path.normpath(sys.argv[1] if len(sys.argv) > 1 else EQ_DEFAULT)
    if not os.path.isdir(os.path.join(eq, 'Locales')):
        print('error: no Locales/ under %s' % eq)
        print('usage: python docs/_port_translations.py [path-to-EverythingQuests]')
        return 1

    manifest = read_manifest('Locales/enUS.lua')
    if not manifest:
        print('error: Locales/enUS.lua has no phrases - run docs/_gen_enus.py first')
        return 1

    for code, lang in LOCALES:
        src = os.path.join(eq, 'Locales', '%s.lua' % code)
        eqmap = read_eq(src) if os.path.isfile(src) else {}
        if not eqmap:
            print('note %s: nothing to carry from %s' % (code, src))

        # Additive: whatever this file already says wins, so a hand correction or a
        # contribution from someone without EQ is never clobbered by a re-run.
        own = os.path.join('Locales', '%s.lua' % code)
        ownmap = read_eq(own, warn=True) if os.path.isfile(own) else {}

        lines = [HEADER % {'code': code, 'lang': lang}]
        kept, added, skipped, group = 0, 0, 0, None
        for g, key in manifest:
            dk = decode(key)
            value = ownmap.get(dk)
            if value:
                kept += 1
            else:
                if key in AMBIGUOUS:
                    skipped += 1
                    continue
                value = eqmap.get(dk)
                if not value:
                    continue
                added += 1
            if g != group:
                group = g
                lines.append('')
                lines.append('-- %s' % g)
            lines.append('L["%s"] = "%s"' % (key, value))

        io.open(own, 'w', encoding='utf-8',
                newline='\n').write('\n'.join(lines) + '\n')
        total = kept + added
        print('wrote %s: %d of %d phrases (%d%%) - %d kept, %d added from EQ, '
              '%d held back as ambiguous'
              % (own, total, len(manifest), round(100.0 * total / len(manifest)),
                 kept, added, skipped))
    return 0


if __name__ == '__main__':
    sys.exit(main())
