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

@test "render_cask supports Term J and K" {
  run render_cask term-j "v1.0.40" "deadbeef" "https://example.com/j.ttc"
  [ "$status" -eq 0 ]
  [[ "$output" == *'cask "font-sarasa-term-j-nerd"'* ]]
  [[ "$output" == *'font "SarasaTermJNerdFontMono.ttc"'* ]]

  run render_cask term-k "v1.0.40" "cafebabe" "https://example.com/k.ttc"
  [ "$status" -eq 0 ]
  [[ "$output" == *'cask "font-sarasa-term-k-nerd"'* ]]
  [[ "$output" == *'font "SarasaTermKNerdFontMono.ttc"'* ]]
}

@test "render_cask supports Term HC and CL" {
  run render_cask term-hc "v1.0.40" "deadbeef" "https://example.com/hc.ttc"
  [ "$status" -eq 0 ]
  [[ "$output" == *'cask "font-sarasa-term-hc-nerd"'* ]]
  [[ "$output" == *'font "SarasaTermHCNerdFontMono.ttc"'* ]]

  run render_cask term-cl "v1.0.40" "cafebabe" "https://example.com/cl.ttc"
  [ "$status" -eq 0 ]
  [[ "$output" == *'cask "font-sarasa-term-cl-nerd"'* ]]
  [[ "$output" == *'font "SarasaTermCLNerdFontMono.ttc"'* ]]
}

@test "render_cask supports Term Slab SC and TC" {
  run render_cask term-slab-sc "v1.0.40" "deadbeef" "https://example.com/slab-sc.ttc"
  [ "$status" -eq 0 ]
  [[ "$output" == *'cask "font-sarasa-term-slab-sc-nerd"'* ]]
  [[ "$output" == *'name "Sarasa Term Slab SC Nerd Font Mono"'* ]]
  [[ "$output" == *'font "SarasaTermSlabSCNerdFontMono.ttc"'* ]]

  run render_cask term-slab-tc "v1.0.40" "cafebabe" "https://example.com/slab-tc.ttc"
  [ "$status" -eq 0 ]
  [[ "$output" == *'cask "font-sarasa-term-slab-tc-nerd"'* ]]
  [[ "$output" == *'font "SarasaTermSlabTCNerdFontMono.ttc"'* ]]
}

@test "render_cask supports Term Slab J and K" {
  run render_cask term-slab-j "v1.0.40" "deadbeef" "https://example.com/slab-j.ttc"
  [ "$status" -eq 0 ]
  [[ "$output" == *'cask "font-sarasa-term-slab-j-nerd"'* ]]
  [[ "$output" == *'name "Sarasa Term Slab J Nerd Font Mono"'* ]]
  [[ "$output" == *'font "SarasaTermSlabJNerdFontMono.ttc"'* ]]

  run render_cask term-slab-k "v1.0.40" "cafebabe" "https://example.com/slab-k.ttc"
  [ "$status" -eq 0 ]
  [[ "$output" == *'cask "font-sarasa-term-slab-k-nerd"'* ]]
  [[ "$output" == *'font "SarasaTermSlabKNerdFontMono.ttc"'* ]]
}
