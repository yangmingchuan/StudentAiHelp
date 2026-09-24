#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEVICE_NAME="${1:-iPhone 17 Pro}"

cd "$PROJECT_DIR"

echo "正在运行到 iOS 设备：$DEVICE_NAME"

exec bash "$SCRIPT_DIR/run_dev.sh" -d "$DEVICE_NAME"
