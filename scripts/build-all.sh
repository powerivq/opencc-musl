#!/usr/bin/env bash
set -euo pipefail

"$(dirname "$0")/build-artifact.sh" amd64
"$(dirname "$0")/build-artifact.sh" arm64
