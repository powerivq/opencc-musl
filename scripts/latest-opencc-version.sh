#!/usr/bin/env bash
set -euo pipefail

git ls-remote --tags --refs https://github.com/BYVoid/OpenCC.git 'refs/tags/ver.*' \
  | awk -F/ '{print $NF}' \
  | sed 's/^ver\.//' \
  | sort -V \
  | tail -n 1
