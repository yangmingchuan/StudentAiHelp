#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEVICE_NAME="${1:-iPhone 17 Pro}"

cd "$PROJECT_DIR"

echo "正在运行到 iOS 设备：$DEVICE_NAME"

exec fvm flutter run -d "$DEVICE_NAME" \
  --dart-define=APP_FLAVOR=dev \
  --dart-define=CLOUDBASE_ENV_ID=little-hero-dev-d7f95sqy70d3a475 \
  --dart-define=AUTH_API_BASE_URL=https://little-hero-dev-d7f95sqy70d3a475.api.tcloudbasegateway.com \
  --dart-define=FUNCTION_API_BASE_URL=https://little-hero-dev-d7f95sqy70d3a475.service.tcloudbase.com
