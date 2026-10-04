# Failure-path tests run a copied build script, never the live work/dist trees.
setup() {
  bats_require_minimum_version 1.5.0
  fixture="$BATS_TEST_TMPDIR/repo"
  stub_bin="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$fixture/scripts" "$fixture/fontpatcher" "$stub_bin"
  cp "$BATS_TEST_DIRNAME/../scripts/build-fonts.sh" "$fixture/scripts/"
  cp "$BATS_TEST_DIRNAME/../config.sh" "$fixture/"
  touch "$fixture/fontpatcher/font-patcher" "$BATS_TEST_TMPDIR/input.ttc"
  chmod +x "$fixture/fontpatcher/font-patcher"

  cat >"$stub_bin/python3" <<'SH'
#!/usr/bin/env bash
# Only the MD subset creation should be reached in these failure-path tests.
[[ "$1" == */make-md-subset.py ]] || exit 99
touch "$5"
SH
  cat >"$stub_bin/fontforge" <<'SH'
#!/usr/bin/env bash
case "$1" in
  -lang=py) stage=extract ;;
  -script) stage=patch ;;
  *) exit 99 ;;
esac
echo "$stage stdout diagnostic"
echo "$stage stderr diagnostic" >&2
if [ "$stage" = "$FAIL_STAGE" ]; then
  exit "$FAIL_STATUS"
fi
[ "$stage" = extract ] || exit 99
touch "${@: -1}"
SH
  # An accidental download must fail locally rather than use the network.
  printf '#!/usr/bin/env bash\nexit 99\n' >"$stub_bin/curl"
  chmod +x "$stub_bin/"*
}

@test "extraction failure reports variant and face, retains log, and preserves exit code" {
  run --separate-stderr env PATH="$stub_bin:$PATH" \
    SARASA_TTC="$BATS_TEST_TMPDIR/input.ttc" FAIL_STAGE=extract FAIL_STATUS=37 \
    bash "$fixture/scripts/build-fonts.sh" v1.0.42 term-sc

  [ "$status" -eq 37 ]
  [[ "$stderr" == *'[term-sc/XLight] FontForge extraction failed (exit 37)'* ]]
  [[ "$stderr" == *'extract stdout diagnostic'* ]]
  [[ "$stderr" == *'extract stderr diagnostic'* ]]
  [ "$(cat "$fixture/work/term-sc/XLight-extract.log")" = \
    $'extract stdout diagnostic\nextract stderr diagnostic' ]
  [ ! -e "$fixture/work/term-sc/XLight-patch.log" ]
}

@test "patch failure reports variant and face, retains log, and preserves exit code" {
  run --separate-stderr env PATH="$stub_bin:$PATH" \
    SARASA_TTC="$BATS_TEST_TMPDIR/input.ttc" FAIL_STAGE=patch FAIL_STATUS=42 \
    bash "$fixture/scripts/build-fonts.sh" v1.0.42 term-slab-hc

  [ "$status" -eq 42 ]
  [[ "$stderr" == *'[term-slab-hc/XLight] font-patcher failed (exit 42)'* ]]
  [[ "$stderr" == *'patch stdout diagnostic'* ]]
  [[ "$stderr" == *'patch stderr diagnostic'* ]]
  [ "$(cat "$fixture/work/term-slab-hc/XLight-patch.log")" = \
    $'patch stdout diagnostic\npatch stderr diagnostic' ]
  [ -f "$fixture/work/term-slab-hc/SarasaTermSlabHC-XLight.ttf" ]
  [ ! -e "$fixture/work/term-slab-hc/XLightItalic-extract.log" ]
}
