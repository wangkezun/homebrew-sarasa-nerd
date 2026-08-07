# tests/config.bats
setup() { source "${BATS_TEST_DIRNAME}/../config.sh"; }

@test "Term SC exposes all ten upstream faces" {
  [ "${#FACES[@]}" -eq 10 ]
  [ "${FACES[*]}" = "XLight XLightItalic Light LightItalic Regular Italic SemiBold SemiBoldItalic Bold BoldItalic" ]
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
