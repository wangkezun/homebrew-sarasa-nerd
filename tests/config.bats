# tests/config.bats
setup() { source "${BATS_TEST_DIRNAME}/../config.sh"; }

@test "supported variants expose all ten upstream faces" {
  [ "${VARIANTS[*]}" = "term-sc term-tc term-j term-k term-hc term-cl term-slab-sc term-slab-tc term-slab-j term-slab-k term-slab-hc term-slab-cl" ]
  [ "${#FACES[@]}" -eq 10 ]
  [ "${FACES[*]}" = "XLight XLightItalic Light LightItalic Regular Italic SemiBold SemiBoldItalic Bold BoldItalic" ]
}

@test "Term Slab HC and CL derive distinct source, output, and cask names" {
  select_variant term-slab-hc
  [ "$SUBFONT_BASE" = "Sarasa Term Slab HC" ]
  [ "$SOURCE_STEM" = "SarasaTermSlabHC" ]
  [ "$FILE_STEM" = "SarasaTermSlabHCNerdFontMono" ]
  [ "$PATCHED_FAMILY" = "SarasaTermSlabHC Nerd Font Mono" ]
  [ "$CASK_TOKEN" = "font-sarasa-term-slab-hc-nerd" ]
  [ "$(face_subfont LightItalic)" = "Sarasa Term Slab HC Light Italic" ]

  select_variant term-slab-cl
  [ "$SUBFONT_BASE" = "Sarasa Term Slab CL" ]
  [ "$SOURCE_STEM" = "SarasaTermSlabCL" ]
  [ "$FILE_STEM" = "SarasaTermSlabCLNerdFontMono" ]
  [ "$CASK_TOKEN" = "font-sarasa-term-slab-cl-nerd" ]
  [ "$(face_subfont Regular)" = "Sarasa Term Slab CL" ]
}

@test "Term Slab J and K derive distinct source, output, and cask names" {
  select_variant term-slab-j
  [ "$SUBFONT_BASE" = "Sarasa Term Slab J" ]
  [ "$SOURCE_STEM" = "SarasaTermSlabJ" ]
  [ "$FILE_STEM" = "SarasaTermSlabJNerdFontMono" ]
  [ "$PATCHED_FAMILY" = "SarasaTermSlabJ Nerd Font Mono" ]
  [ "$CASK_TOKEN" = "font-sarasa-term-slab-j-nerd" ]
  [ "$MD_MAX_KEEP" -eq 3600 ]
  [ "$(face_subfont BoldItalic)" = "Sarasa Term Slab J Bold Italic" ]

  select_variant term-slab-k
  [ "$SUBFONT_BASE" = "Sarasa Term Slab K" ]
  [ "$SOURCE_STEM" = "SarasaTermSlabK" ]
  [ "$FILE_STEM" = "SarasaTermSlabKNerdFontMono" ]
  [ "$CASK_TOKEN" = "font-sarasa-term-slab-k-nerd" ]
  [ "$MD_MAX_KEEP" -eq 5100 ]
}

@test "Term Slab SC and TC derive distinct source, output, and cask names" {
  select_variant term-slab-sc
  [ "$SUBFONT_BASE" = "Sarasa Term Slab SC" ]
  [ "$SOURCE_STEM" = "SarasaTermSlabSC" ]
  [ "$FILE_STEM" = "SarasaTermSlabSCNerdFontMono" ]
  [ "$PATCHED_FAMILY" = "SarasaTermSlabSC Nerd Font Mono" ]
  [ "$CASK_TOKEN" = "font-sarasa-term-slab-sc-nerd" ]
  [ "$(face_subfont BoldItalic)" = "Sarasa Term Slab SC Bold Italic" ]

  select_variant term-slab-tc
  [ "$SUBFONT_BASE" = "Sarasa Term Slab TC" ]
  [ "$SOURCE_STEM" = "SarasaTermSlabTC" ]
  [ "$FILE_STEM" = "SarasaTermSlabTCNerdFontMono" ]
  [ "$CASK_TOKEN" = "font-sarasa-term-slab-tc-nerd" ]
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
  [ "$SOURCE_STEM" = "SarasaTermTC" ]
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
