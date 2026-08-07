# tests/config.bats
setup() { source "${BATS_TEST_DIRNAME}/../config.sh"; }

@test "supported variants expose all ten upstream faces" {
  [ "${VARIANTS[*]}" = "term-sc term-tc" ]
  [ "${#FACES[@]}" -eq 10 ]
  [ "${FACES[*]}" = "XLight XLightItalic Light LightItalic Regular Italic SemiBold SemiBoldItalic Bold BoldItalic" ]
}

@test "Term TC derives its source, output, and cask names" {
  select_variant term-tc
  [ "$SUBFONT_BASE" = "Sarasa Term TC" ]
  [ "$FILE_STEM" = "SarasaTermTCNerdFontMono" ]
  [ "$PATCHED_FAMILY" = "SarasaTermTC Nerd Font Mono" ]
  [ "$CASK_TOKEN" = "font-sarasa-term-tc-nerd" ]
  [ "$(face_subfont XLightItalic)" = "Sarasa Term TC XLight Italic" ]
}

@test "unknown variants fail instead of silently selecting a family" {
  run select_variant term-xx
  [ "$status" -ne 0 ]
}

@test "face mappings preserve upstream names, styles, and weight classes" {
  [ "$(face_subfont XLightItalic)" = "Sarasa Term SC XLight Italic" ]
  [ "$(face_subfont Regular)" = "Sarasa Term SC" ]
  [ "$(face_subfont SemiBoldItalic)" = "Sarasa Term SC SemiBold Italic" ]
  [ "$(face_style XLight)" = "ExtraLight" ]
  [ "$(face_style BoldItalic)" = "Bold Italic" ]
  [ "$(face_weight LightItalic)" -eq 300 ]
  [ "$(face_weight SemiBold)" -eq 600 ]
}

@test "unknown faces fail instead of silently selecting a font" {
  run face_subfont Unknown
  [ "$status" -ne 0 ]
}
