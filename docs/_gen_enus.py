# Regenerate Locales/enUS.lua from the actual L["..."] usages in the code.
# The English string IS the key, so the manifest is a pure function of the code:
# this extracts every wrapped string (byte-exact, escapes preserved) and writes
# the self-keyed base-phrase list. Re-run after each extraction pass:
#   python docs/_gen_enus.py   then   python docs/_verify_locale.py
import re, io, glob

KEY = re.compile(r'L\["((?:[^"\\]|\\.)*)"\]')

HEADER = '''-- Locales/enUS.lua
-- Default locale + source-of-truth phrase list for EQ Objective Tracker.
--
-- ns.L["English string"] returns the localized text for the player's client
-- (per GetLocale()), or the English string itself when no translation exists
-- (the metatable __index below). So EVERY wrapped string is safe to use even
-- with zero translations loaded. Untranslated text simply renders in English.
--
-- Translations are bundled directly in the other Locales/*.lua files as
-- L["key"] = "value" lines, NOT fetched through an @localization@ packager
-- token. That token fails the CurseForge build with errorCode 1002 on a project
-- without localization enabled, so it must never be added here.
--
-- Pattern: the English string IS the key (no semantic IDs). Keep keys in sync
-- with the code. If you reword an English string, update it here too or the
-- existing translation orphans (and the new text falls back to English).
--
-- GENERATED FILE: produced by docs/_gen_enus.py from the L[...] usages in the
-- code. Do not hand-edit. Re-run the generator after an extraction pass.
'''

# Friendly ordering so the manifest reads top-down like the UI.
PREFERRED = [
    'Options/TabGeneral.lua', 'Options/TabSections.lua', 'Options/TabAppearance.lua',
    'Options/TabAbout.lua', 'Options/Frame.lua',
]


def strip_comments(s):
    return '\n'.join(l for l in s.splitlines() if not l.lstrip().startswith('--'))


# Collect raw keys (regex capture = exact source between quotes, escapes intact),
# deduped globally, attributed to the first file that uses them.
seen = set()
by_file = {}
files = [p.replace('\\', '/') for p in glob.glob('**/*.lua', recursive=True)]
files = [p for p in files if not p.startswith('Libs/') and not p.startswith('Locales/')]
ordered = [f for f in PREFERRED if f in files] + sorted(f for f in files if f not in PREFERRED)

for path in ordered:
    s = strip_comments(io.open(path, encoding='utf-8', errors='replace').read())
    for m in KEY.finditer(s):
        raw = m.group(1)
        if raw in seen:
            continue
        seen.add(raw)
        by_file.setdefault(path, []).append(raw)

out = [HEADER, '', 'local _, ns = ...', '',
       'ns.L = setmetatable({}, { __index = function(_, k) return k end })',
       'local L = ns.L', '']

for path in ordered:
    keys = by_file.get(path)
    if not keys:
        continue
    out.append('-- %s' % path)
    for raw in keys:
        out.append('L["%s"] = true' % raw)
    out.append('')

out.append('-- Convert the `true` sentinels to their key (the self-keyed English default).')
out.append('for k, v in pairs(L) do if v == true then L[k] = k end end')

io.open('Locales/enUS.lua', 'w', encoding='utf-8', newline='\n').write('\n'.join(out) + '\n')
print('wrote Locales/enUS.lua with %d phrases across %d files' % (len(seen), len(by_file)))
