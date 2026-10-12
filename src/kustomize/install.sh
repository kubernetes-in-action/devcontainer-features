#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-"latest"}"

case "$(uname -m)" in
  x86_64) ARCH="amd64" ;;
  aarch64 | arm64) ARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

CURL="curl -fsSL --retry 5 --retry-all-errors --retry-delay 2"

if [ "${VERSION}" = "latest" ]; then
  VERSION="$($CURL "https://api.github.com/repos/kubernetes-sigs/kustomize/releases" | \
    jq -r 'map(select(.tag_name | startswith("kustomize/"))) | .[0].tag_name' | \
    sed -e 's+kustomize/++')"
fi

if [ -z "${VERSION}" ]; then
  echo "Could not resolve a kustomize version to install." >&2
  exit 1
fi

echo "Installing kustomize ${VERSION} (linux/${ARCH})"

ARCHIVE="kustomize_${VERSION}_linux_${ARCH}.tar.gz"
RELEASE_URL="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${VERSION}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

$CURL -o "${TMP_DIR}/${ARCHIVE}" "${RELEASE_URL}/${ARCHIVE}"

$CURL -o "${TMP_DIR}/checksums.txt" "${RELEASE_URL}/checksums.txt"

echo "Verifying checksum"
(cd "${TMP_DIR}" && grep -E "  ${ARCHIVE}\$" checksums.txt | sha256sum -c -)

tar -xzf "${TMP_DIR}/${ARCHIVE}" -C /usr/local/bin kustomize
chmod +x /usr/local/bin/kustomize

kustomize version
