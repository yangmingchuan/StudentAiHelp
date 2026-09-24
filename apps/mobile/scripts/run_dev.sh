#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."
if command -v fvm >/dev/null 2>&1; then
  exec fvm flutter run --dart-define-from-file=config/dev.json "$@"
else
  exec flutter run --dart-define-from-file=config/dev.json "$@"
fi
