#!/usr/bin/env bash
set -euo pipefail

current="${OPENCC_VERSION:-1.3.1}"
latest="$($(dirname "$0")/latest-opencc-version.sh)"
if [ -z "$latest" ]; then
  echo "failed to discover latest OpenCC version" >&2
  exit 2
fi
if [ "$current" = "$latest" ]; then
  echo "OpenCC is up to date: ${current}"
  exit 0
fi
printf 'OpenCC update available: current=%s latest=%s\n' "$current" "$latest"
exit 1
