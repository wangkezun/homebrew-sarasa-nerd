# tests/update-cask.bats
setup() { source "${BATS_TEST_DIRNAME}/../scripts/update-cask.sh"; }

@test "render_cask embeds version, sha, url, ttc filename" {
  run render_cask term-sc "v1.0.30" "deadbeef" "https://example.com/x.ttc"
  [ "$status" -eq 0 ]
  [[ "$output" == *'version "v1.0.30"'* ]]
  [[ "$output" == *'sha256 "deadbeef"'* ]]
  [[ "$output" == *'url "https://example.com/x.ttc"'* ]]
  [[ "$output" == *'font "SarasaTermSCNerdFontMono.ttc"'* ]]
  [[ "$output" == *'cask "font-sarasa-term-sc-nerd"'* ]]
  [[ "$output" == *'homepage "https://github.com/wangkezun/homebrew-sarasa-nerd"'* ]]
}

@test "render_cask supports Term TC" {
  run render_cask term-tc "v1.0.40" "cafebabe" "https://example.com/tc.ttc"
  [ "$status" -eq 0 ]
  [[ "$output" == *'cask "font-sarasa-term-tc-nerd"'* ]]
  [[ "$output" == *'name "Sarasa Term TC Nerd Font Mono"'* ]]
  [[ "$output" == *'font "SarasaTermTCNerdFontMono.ttc"'* ]]
}
