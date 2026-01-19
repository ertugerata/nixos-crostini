#!/usr/bin/env bash
set -e

UPSTREAM_URL="https://github.com/aldur/nixos-crostini.git"
UPSTREAM_REMOTE="upstream-check"
GUEST_TOOLS_URL="https://chromium.googlesource.com/chromiumos/containers/cros-container-guest-tools"
COMMON_NIX="common.nix"

echo ">>> Setting up remote..."
if ! git remote | grep -q "^${UPSTREAM_REMOTE}$"; then
    git remote add "${UPSTREAM_REMOTE}" "${UPSTREAM_URL}"
fi

echo ">>> Fetching upstream..."
git fetch "${UPSTREAM_REMOTE}" main

echo ">>> Checking for upstream changes (excluding baguette.nix)..."
# List commits in upstream/main that are not in HEAD
COMMITS=$(git log HEAD..${UPSTREAM_REMOTE}/main --oneline -- . ":!baguette.nix")

if [ -n "$COMMITS" ]; then
    echo "WARNING: There are new commits in upstream (excluding baguette.nix):"
    echo "$COMMITS"
else
    echo "OK: No relevant upstream changes found."
fi

echo ""
echo ">>> Checking cros-container-guest-tools version..."

# Extract current commit
CURRENT_HASH=$(grep 'cros-container-guest-tools-src-version =' "${COMMON_NIX}" | cut -d '"' -f 2)
echo "Current local hash: $CURRENT_HASH"

# Fetch latest remote hash
LATEST_HASH=$(git ls-remote "${GUEST_TOOLS_URL}" HEAD | awk '{print $1}')
echo "Latest remote hash: $LATEST_HASH"

if [ "$CURRENT_HASH" != "$LATEST_HASH" ]; then
    echo "WARNING: cros-container-guest-tools is outdated!"
    echo "You should update ${COMMON_NIX} with the new hash: ${LATEST_HASH}"
else
    echo "OK: cros-container-guest-tools is up to date."
    echo "Hash: $CURRENT_HASH"
fi
