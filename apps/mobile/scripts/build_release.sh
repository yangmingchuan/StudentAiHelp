#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."
TARGET="${1:-appbundle}"
CONFIG_FILE="${2:-config/prod.json}"
case "$TARGET" in apk|appbundle|ipa) ;; *) echo "支持 apk、appbundle、ipa" >&2; exit 1;; esac
if command -v fvm >/dev/null 2>&1; then
  fvm dart run tool/validate_release_config.dart --file "$CONFIG_FILE"
  exec fvm flutter build "$TARGET" --release --dart-define-from-file="$CONFIG_FILE"
else
  dart run tool/validate_release_config.dart --file "$CONFIG_FILE"
  exec flutter build "$TARGET" --release --dart-define-from-file="$CONFIG_FILE"
fi
