#!/usr/bin/env bash
# scripts/update-cask.sh — write Casks/<token>.rb and version.txt
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DIR/config.sh"

render_cask() {   # $1 variant  $2 version  $3 sha256  $4 url
  select_variant "$1"
  cat <<EOF
cask "${CASK_TOKEN}" do
  version "$2"
  sha256 "$3"

  url "$4"
  name "${CASK_NAME}"
  desc "${CASK_DESC}"
  homepage "https://github.com/${THIS_REPO}"

  font "${TTC_NAME}"
end
EOF
}

main() {   # $1 variant  $2 version  $3 sha256  $4 url
  select_variant "$1"
  mkdir -p "$DIR/Casks"
  render_cask "$1" "$2" "$3" "$4" > "$DIR/Casks/${CASK_TOKEN}.rb"
  printf '%s\n' "$2" > "$DIR/version.txt"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then main "$@"; fi
