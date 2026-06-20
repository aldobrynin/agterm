#!/usr/bin/env bash
# Download the prebuilt libghostty (GhosttyKit.xcframework) and ghostty resources.
# No Zig build — these are prebuilt artifacts from the thdxg/ghostty fork's CI.
# Pinned to a tag for reproducibility; bump TAG deliberately when adopting a newer libghostty.
set -euo pipefail
cd "$(dirname "$0")/.."

REPO="thdxg/ghostty"
TAG="build-2026-06-20"
XCFRAMEWORK_DIR="GhosttyKit.xcframework"
# terminfo/ is the marker: it must extract as a SIBLING of ghostty/ so libghostty's
# TERMINFO=dirname(GHOSTTY_RESOURCES_DIR)/terminfo derivation resolves xterm-ghostty.
RESOURCES_MARKER="agt/Resources/terminfo"

need_xc=true
need_res=true
[[ -d "$XCFRAMEWORK_DIR" ]] && need_xc=false
[[ -d "$RESOURCES_MARKER" ]] && need_res=false

if ! $need_xc && ! $need_res; then
  echo "GhosttyKit and resources already present"
  exit 0
fi

if $need_xc; then
  echo "downloading GhosttyKit.xcframework ($TAG)..."
  gh release download "$TAG" --repo "$REPO" --pattern "GhosttyKit.xcframework.tar.gz" --clobber
  tar xzf GhosttyKit.xcframework.tar.gz
  rm GhosttyKit.xcframework.tar.gz
fi

if $need_res; then
  echo "downloading ghostty resources ($TAG)..."
  gh release download "$TAG" --repo "$REPO" --pattern "ghostty-resources.tar.gz" --clobber
  rm -rf agt/Resources/ghostty agt/Resources/terminfo
  mkdir -p agt/Resources
  tar xzf ghostty-resources.tar.gz -C agt/Resources
  rm ghostty-resources.tar.gz
fi

echo "setup complete"
