#!/usr/bin/env bash
# scripts/verify-fonts.sh <font.ttf|font.ttc>
# Asserts: Latin A=500, CJK 你=1000, glyphs<65535, family name, key icons present,
# correct weight/style metadata, and post.isFixedPitch=1 (CoreText monospace trait).
# For a .ttc, all ten expected faces must be present.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DIR/config.sh"

FONT="$1"
fontforge -lang=py -c '
import fontforge, sys
path = sys.argv[1]
family_expected = sys.argv[2]
limit = int(sys.argv[3])
names = fontforge.fontsInFile(path)          # list of subfont names; 1 entry for a plain TTF
problems = []
for nm in (names or [None]):
    f = fontforge.open(path + (("(%s)" % nm) if nm else ""))
    label = nm or f.fontname
    if f[0x41].width != 500:   problems.append("%s: Latin A width %d != 500" % (label, f[0x41].width))
    if f[0x4F60].width != 1000: problems.append("%s: CJK 你 width %d != 1000" % (label, f[0x4F60].width))
    gc = len(list(f.glyphs()))
    if gc >= limit:  problems.append("%s: glyph count %d >= %d" % (label, gc, limit))
    if f.familyname != family_expected: problems.append("%s: family %r != %r" % (label, f.familyname, family_expected))
    # FontAwesome/devicons/octicons (built-in sets) + Material Design (--custom subset, eza/lsd icons)
    for cp in (0xF07B, 0xE725, 0xF015, 0xF0306, 0xF024F, 0xF075A):
        try: f[cp]
        except TypeError: problems.append("%s: missing icon U+%04X" % (label, cp))
    f.close()
if problems:
    print("VERIFY FAIL:"); [print("  - " + p) for p in problems]; sys.exit(1)
print("VERIFY OK: %s (%d face[s])" % (path, len(names or [None])))
' "$FONT" "$PATCHED_FAMILY" "$GLYPH_LIMIT"

# post.isFixedPitch drives the macOS/CoreText monospace trait; fontforge can't read it, use fontTools.
python3 - "$FONT" "$PATCHED_FAMILY" <<'PY'
import sys
from fontTools.ttLib import TTFont, TTCollection
path = sys.argv[1]
family = sys.argv[2]
fonts = TTCollection(path).fonts if path.lower().endswith(".ttc") else [TTFont(path)]
bad = [i for i, f in enumerate(fonts) if f["post"].isFixedPitch != 1]
if bad:
    sys.exit("VERIFY FAIL: post.isFixedPitch != 1 on face(s) %s" % bad)

expected = {
    ("ExtraLight", 200, False), ("ExtraLight Italic", 200, True),
    ("Light", 300, False), ("Light Italic", 300, True),
    ("Regular", 400, False), ("Italic", 400, True),
    ("SemiBold", 600, False), ("SemiBold Italic", 600, True),
    ("Bold", 700, False), ("Bold Italic", 700, True),
}
actual = set()
problems = []
for i, f in enumerate(fonts):
    name = f["name"]
    face_family = name.getDebugName(16) or name.getDebugName(1)
    style = name.getDebugName(17) or name.getDebugName(2)
    weight = f["OS/2"].usWeightClass
    italic = bool(f["head"].macStyle & 0x02)
    if face_family != family:
        problems.append("face %d family %r != %r" % (i, face_family, family))
    item = (style, weight, italic)
    actual.add(item)
    if item not in expected:
        problems.append("face %d unexpected style/weight/italic %r" % (i, item))

if path.lower().endswith(".ttc") and actual != expected:
    problems.append("TTC face set mismatch; missing=%r extra=%r" %
                    (sorted(expected - actual), sorted(actual - expected)))
if problems:
    sys.exit("VERIFY FAIL: " + "; ".join(problems))
print("VERIFY OK: metadata and isFixedPitch=1 (%d face[s])" % len(fonts))
PY
