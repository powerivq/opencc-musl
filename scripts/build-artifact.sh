#!/usr/bin/env bash
set -euo pipefail

OPENCC_VERSION="${OPENCC_VERSION:-1.3.1}"
OPENCC_REF="${OPENCC_REF:-ver.${OPENCC_VERSION}}"
ARCH="${1:-$(uname -m)}"
case "$ARCH" in
  amd64|x86_64) TARGETARCH=amd64 ;;
  arm64|aarch64) TARGETARCH=arm64 ;;
  *) echo "unsupported arch: $ARCH" >&2; exit 1 ;;
esac

OUT_DIR="dist"
OUT_NAME="opencc-${OPENCC_VERSION}-alpine-${TARGETARCH}.tar.gz"
ROOTFS="${OUT_DIR}/rootfs-${TARGETARCH}"
PLATFORM="linux/${TARGETARCH}"

mkdir -p "$OUT_DIR"
rm -rf "$ROOTFS"
docker buildx build \
  --platform "$PLATFORM" \
  --build-arg "OPENCC_VERSION=${OPENCC_VERSION}" \
  --build-arg "OPENCC_REF=${OPENCC_REF}" \
  --target artifact \
  --output "type=local,dest=${ROOTFS}" \
  .
tar -C "$ROOTFS" -czf "${OUT_DIR}/${OUT_NAME}" .
sha256sum "${OUT_DIR}/${OUT_NAME}" > "${OUT_DIR}/${OUT_NAME}.sha256"

echo "wrote ${OUT_DIR}/${OUT_NAME}"
