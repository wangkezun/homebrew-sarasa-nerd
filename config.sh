# config.sh — single source of truth, sourced by all scripts.
UPSTREAM_REPO="be5invis/Sarasa-Gothic"
THIS_REPO="wangkezun/homebrew-sarasa-nerd"

# Supported font family/locale variants. select_variant sets all derived names
# used by the build, verification, cask, and release scripts.
VARIANTS=("term-sc" "term-tc" "term-j" "term-k")
select_variant() {
  FONT_VARIANT="$1"
  MD_MAX_KEEP=5100
  case "$FONT_VARIANT" in
    term-sc) LOCALE="SC"; LOCALE_SLUG="sc" ;;
    term-tc) LOCALE="TC"; LOCALE_SLUG="tc" ;;
    # Japanese adds more base glyphs than the other locales, leaving less room
    # below the sfnt 65535-glyph ceiling for the Material Design subset.
    term-j) LOCALE="J"; LOCALE_SLUG="j"; MD_MAX_KEEP=3600 ;;
    term-k) LOCALE="K"; LOCALE_SLUG="k" ;;
    *) echo "unknown variant: $FONT_VARIANT" >&2; return 1 ;;
  esac

  SUBFONT_BASE="Sarasa Term $LOCALE"
  FILE_STEM="SarasaTerm${LOCALE}NerdFontMono"
  PATCHED_FAMILY="SarasaTerm${LOCALE} Nerd Font Mono"
  TTC_NAME="${FILE_STEM}.ttc"
  CASK_TOKEN="font-sarasa-term-${LOCALE_SLUG}-nerd"
  CASK_NAME="Sarasa Term $LOCALE Nerd Font Mono"
  CASK_DESC="Sarasa Term $LOCALE in five weights patched with Nerd Fonts (CJK 2:1 width preserved)"
}

# Sarasa ships five weights, each with upright and italic faces. Regular has no
# weight suffix in the SuperTTC subfont name.
FACES=(
  "XLight" "XLightItalic"
  "Light" "LightItalic"
  "Regular" "Italic"
  "SemiBold" "SemiBoldItalic"
  "Bold" "BoldItalic"
)
face_subfont() {              # $1 = face label -> exact SuperTTC subfont name
  case "$1" in
    Regular)         echo "$SUBFONT_BASE" ;;
    Italic)          echo "$SUBFONT_BASE Italic" ;;
    XLight)          echo "$SUBFONT_BASE XLight" ;;
    XLightItalic)    echo "$SUBFONT_BASE XLight Italic" ;;
    Light)           echo "$SUBFONT_BASE Light" ;;
    LightItalic)     echo "$SUBFONT_BASE Light Italic" ;;
    SemiBold)        echo "$SUBFONT_BASE SemiBold" ;;
    SemiBoldItalic)  echo "$SUBFONT_BASE SemiBold Italic" ;;
    Bold)            echo "$SUBFONT_BASE Bold" ;;
    BoldItalic)      echo "$SUBFONT_BASE Bold Italic" ;;
    *) echo "unknown face: $1" >&2; return 1 ;;
  esac
}

face_style() {                # $1 = face label -> OpenType typographic subfamily
  case "$1" in
    XLight)         echo "ExtraLight" ;;
    XLightItalic)   echo "ExtraLight Italic" ;;
    Light)          echo "Light" ;;
    LightItalic)    echo "Light Italic" ;;
    Regular)        echo "Regular" ;;
    Italic)         echo "Italic" ;;
    SemiBold)       echo "SemiBold" ;;
    SemiBoldItalic) echo "SemiBold Italic" ;;
    Bold)           echo "Bold" ;;
    BoldItalic)     echo "Bold Italic" ;;
    *) echo "unknown face: $1" >&2; return 1 ;;
  esac
}

face_weight() {               # $1 = face label -> OS/2 usWeightClass
  case "$1" in
    XLight|XLightItalic)     echo 200 ;;
    Light|LightItalic)       echo 300 ;;
    Regular|Italic)          echo 400 ;;
    SemiBold|SemiBoldItalic) echo 600 ;;
    Bold|BoldItalic)         echo 700 ;;
    *) echo "unknown face: $1" >&2; return 1 ;;
  esac
}

FONTPATCHER_VERSION="v3.4.0"
FONTPATCHER_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${FONTPATCHER_VERSION}/FontPatcher.zip"

# Patch recipe (see spec "背景:为何是这些参数").
PATCH_FLAGS=(--single-width-glyphs --makegroups 1 --cell "0:540:-285:965")
GLYPH_SETS=(--fontawesome --fontawesomeext --fontlogos --octicons --pomicons \
            --powerline --powerlineextra --powersymbols --codicons --weather)
# Material Design (~6880 glyphs) can't be patched whole: with the full CJK base the font
# would exceed the 65535 sfnt limit. Instead build-fonts.sh trims MD to a ~4900-glyph subset
# (see scripts/make-md-subset.py) and adds it via --custom. Inputs:
MD_GLYPH_SRC="src/glyphs/materialdesign/MaterialDesignIconsDesktop.ttf"  # relative to fontpatcher dir
MD_WHITELIST="scripts/eza-lsd-md-icons.txt"                              # relative to repo root

GLYPH_LIMIT=65535

# Preserve the original Term SC behavior for callers that only source config.sh.
select_variant "${FONT_VARIANT:-term-sc}"
