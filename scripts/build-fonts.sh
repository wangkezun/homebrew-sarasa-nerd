#!/usr/bin/env bash
# scripts/build-fonts.sh <upstream_version_tag> [variant]
# Produces ten TTF faces and one TTC under dist/<variant>/.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DIR/config.sh"
VERSION="$1"
VARIANT="${2:-term-sc}"
select_variant "$VARIANT"
WORK="$DIR/work/$VARIANT"; DIST="$DIR/dist/$VARIANT"; FP="$DIR/fontpatcher"
if [ -n "${SARASA_TTC:-}" ]; then
  [ -f "$SARASA_TTC" ] || { echo "SARASA_TTC not found: $SARASA_TTC" >&2; exit 1; }
  SARASA_TTC="$(cd "$(dirname "$SARASA_TTC")" && pwd)/$(basename "$SARASA_TTC")"
  case "$SARASA_TTC" in
    "$WORK"/*) echo "SARASA_TTC must be outside the disposable work directory" >&2; exit 1 ;;
  esac
fi
rm -rf "$WORK" "$DIST"; mkdir -p "$WORK" "$DIST"

# 1. font-patcher (pinned)
if [ ! -x "$FP/font-patcher" ]; then
  curl -fSL -o "$WORK/FontPatcher.zip" "$FONTPATCHER_URL"
  mkdir -p "$FP"; unzip -oq "$WORK/FontPatcher.zip" -d "$FP"
fi

# 2. Use an explicitly supplied SuperTTC for reproducible local builds, or download
# the matching upstream archive in CI. Prefer the hinted SuperTTC .zip (extractable
# with plain unzip; excludes "Unhinted").
if [ -n "${SARASA_TTC:-}" ]; then
  TTC_SRC="$SARASA_TTC"
else
  github_headers=()
  [ -z "${GITHUB_TOKEN:-}" ] || github_headers=(-H "Authorization: Bearer $GITHUB_TOKEN")
  asset_url="$(curl -fsSL "${github_headers[@]}" \
    "https://api.github.com/repos/${UPSTREAM_REPO}/releases/tags/${VERSION}" \
    | jq -r '.assets[] | select(.name | test("^Sarasa-SuperTTC-[0-9][0-9.]*\\.zip$")) | .browser_download_url' | head -1)"
  [ -n "$asset_url" ] || { echo "no hinted SuperTTC zip for ${VERSION}" >&2; exit 1; }
  curl -fSL -o "$WORK/sarasa.zip" "$asset_url"
  unzip -oq "$WORK/sarasa.zip" -d "$WORK"
  TTC_SRC="$(find "$WORK" -iname 'Sarasa-SuperTTC*.ttc' | head -1)"
  [ -n "$TTC_SRC" ] || { echo "SuperTTC .ttc not found after extract" >&2; exit 1; }
fi

# 3. build trimmed Material Design subset once (shared across weights), added via --custom
MD_SUBSET="$WORK/md-subset.ttf"
python3 "$DIR/scripts/make-md-subset.py" \
  "$FP/$MD_GLYPH_SRC" "$FP/glyphnames.json" "$DIR/$MD_WHITELIST" "$MD_SUBSET" "$MD_MAX_KEEP"

# 4. extract + patch each face
for face in "${FACES[@]}"; do
  sub="$(face_subfont "$face")"
  raw="$WORK/SarasaTerm${LOCALE}-$face.ttf"
  fontforge -lang=py -c 'import fontforge,sys; g=fontforge.open(sys.argv[1]); g.generate(sys.argv[2]); g.close()' \
    "${TTC_SRC}(${sub})" "$raw" 2>/dev/null
  rm -rf "$WORK/patched"; mkdir -p "$WORK/patched"
  fontforge -script "$FP/font-patcher" "${PATCH_FLAGS[@]}" "${GLYPH_SETS[@]}" --custom "$MD_SUBSET" \
    -out "$WORK/patched" "$raw" >/dev/null 2>&1
  out="$(find "$WORK/patched" -iname '*.ttf' | head -1)"
  [ -n "$out" ] || { echo "patch produced no file for $face" >&2; exit 1; }
  mv "$out" "$DIST/${FILE_STEM}-$face.ttf"
done

# 4b. Normalize the family/style names, retain the real weight class, and restore
# post.isFixedPitch=1 on each face. Upstream Sarasa Term ships isFixedPitch as 1,
# but fontforge's subfont extraction in step 4 recomputes it to 0 (the 2:1 dual width
# makes advances non-uniform). macOS/CoreText reads this flag for its monospace trait,
# so without it the family stops showing up in editors'/terminals' "fixed-width" pickers.
for face in "${FACES[@]}"; do
  style="$(face_style "$face")"
  weight="$(face_weight "$face")"
  python3 - "$DIST/${FILE_STEM}-$face.ttf" "$PATCHED_FAMILY" "$style" "$weight" <<'PY'
import sys
from fontTools.ttLib import TTFont
f = TTFont(sys.argv[1])
family = sys.argv[2]
style = sys.argv[3]
weight = int(sys.argv[4])
f["post"].isFixedPitch = 1
f["OS/2"].usWeightClass = weight
# makegroups bakes the enabled glyph-set list into the Typographic Family (name ID 16),
# producing the very long "...Plus Font Awesome Plus..." name. macOS/CoreText prefers
# name 16 over name 1 when present, so that long string is what shows up in Font Book and
# font pickers. Re-assert one clean family and explicit style names so CoreText groups all
# ten faces under a single family while retaining ExtraLight/Light/SemiBold selection.
name = f["name"]
full_name = family if style == "Regular" else "%s %s" % (family, style)
postscript_name = (family + ("" if style == "Regular" else "-" + style)).replace(" ", "")
values = {1: family, 2: style, 4: full_name, 6: postscript_name, 16: family, 17: style}
contexts = {(r.platformID, r.platEncID, r.langID) for r in name.names if r.nameID in (1, 16)}
for nid, value in values.items():
    records = [r for r in name.names if r.nameID == nid]
    targets = {(r.platformID, r.platEncID, r.langID) for r in records} or contexts
    for platform, encoding, language in targets:
        name.setName(value, nid, platform, encoding, language)
f.save(sys.argv[1])
PY
done

# 5. merge into a single TTC (fonttools dedups identical tables)
face_paths=()
for face in "${FACES[@]}"; do
  face_paths+=("$DIST/${FILE_STEM}-$face.ttf")
done
python3 - "$DIST/$TTC_NAME" "${face_paths[@]}" <<'PY'
import sys
from fontTools.ttLib import TTFont, TTCollection
out = sys.argv[1]
ttc = TTCollection()
ttc.fonts = [TTFont(p) for p in sys.argv[2:]]
ttc.save(out)
PY

echo "built: $DIST"
ls -la "$DIST"
