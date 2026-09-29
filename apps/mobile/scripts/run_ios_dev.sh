#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEVICE_NAME="${1:-iPhone 17 Pro}"

cd "$PROJECT_DIR"

echo "正在运行到 iOS 设备：$DEVICE_NAME"

# Flutter 只会列出已启动的模拟器。先确保目标模拟器已完全启动，
# 这样新克隆项目不需要手动打开 Simulator 或等待设备被 Flutter 发现。
xcrun simctl boot "$DEVICE_NAME" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$DEVICE_NAME" -b
open -a Simulator

exec bash "$SCRIPT_DIR/run_dev.sh" -d "$DEVICE_NAME"
