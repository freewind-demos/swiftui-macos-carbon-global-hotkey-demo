#!/usr/bin/env bash

set -euo pipefail

export DEVELOPER_DIR=/System/Volumes/Data/Applications/Xcode.app/Contents/Developer

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="SwiftUICarbonGlobalHotkeyDemo"

cd "$ROOT_DIR"

rtk xcodegen generate

rtk xcodebuild \
  -project "${PROJECT_NAME}.xcodeproj" \
  -scheme "$PROJECT_NAME" \
  -configuration Debug \
  -derivedDataPath .build/DerivedData \
  build

APP_PATH="$(rtk fd -a "${PROJECT_NAME}.app" .build/DerivedData/Build/Products/Debug -t d | rtk head -n 1)"

if [[ -n "${APP_PATH}" ]]; then
  rtk open "$APP_PATH"
fi
