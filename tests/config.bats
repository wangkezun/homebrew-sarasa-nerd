# tests/config.bats
setup() { source "${BATS_TEST_DIRNAME}/../config.sh"; }

@test "supported variants expose all ten upstream faces" {
  [ "${VARIANTS[*]}" = "term-sc term-tc term-j term-k term-hc term-cl" ]
  [ "${#FACES[@]}" -eq 10 ]
  [ "${FACES[*]}" = "XLight XLightItalic Light LightItalic Regular Italic SemiBold SemiBoldItalic Bold BoldItalic" ]
}

@test "Term HC and CL derive their source, output, and cask names" {
  select_variant term-hc
  [ "$SUBFONT_BASE" = "Sarasa Term HC" ]
  [ "$FILE_STEM" = "SarasaTermHCNerdFontMono" ]
  [ "$PATCHED_FAMILY" = "SarasaTermHC Nerd Font Mono" ]
  [ "$CASK_TOKEN" = "font-sarasa-term-hc-nerd" ]
  [ "$(face_subfont LightItalic)" = "Sarasa Term HC Light Italic" ]

  select_variant term-cl
  [ "$SUBFONT_BASE" = "Sarasa Term CL" ]
  [ "$FILE_STEM" = "SarasaTermCLNerdFontMono" ]
  [ "$PATCHED_FAMILY" = "SarasaTermCL Nerd Font Mono" ]
  [ "$CASK_TOKEN" = "font-sarasa-term-cl-nerd" ]
  [ "$(face_subfont Regular)" = "Sarasa Term CL" ]
}

@test "Term J and K derive their source, output, and cask names" {
  select_variant term-j
  [ "$SUBFONT_BASE" = "Sarasa Term J" ]
  [ "$FILE_STEM" = "SarasaTermJNerdFontMono" ]
  [ "$CASK_TOKEN" = "font-sarasa-term-j-nerd" ]
  [ "$MD_MAX_KEEP" -eq 3600 ]
  [ "$(face_subfont BoldItalic)" = "Sarasa Term J Bold Italic" ]

  select_variant term-k
  [ "$SUBFONT_BASE" = "Sarasa Term K" ]
  [ "$PATCHED_FAMILY" = "SarasaTermK Nerd Font Mono" ]
  [ "$CASK_TOKEN" = "font-sarasa-term-k-nerd" ]
  [ "$MD_MAX_KEEP" -eq 5100 ]
  [ "$(face_subfont Regular)" = "Sarasa Term K" ]
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
