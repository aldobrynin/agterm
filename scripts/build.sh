#!/usr/bin/env bash
# Build a release app.
set -euo pipefail
cd "$(dirname "$0")/.."

./scripts/setup.sh
xcodegen generate
GIT_COMMIT="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
xcodebuild -project agterm.xcodeproj -scheme agterm -configuration Release \
  -derivedDataPath build/DerivedData GIT_COMMIT="$GIT_COMMIT" build
echo "built: build/DerivedData/Build/Products/Release/agterm.app"
