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
  VERSION="$($CURL https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | jq -r '.tag_name' )"
fi

if [ -z "${VERSION}" ]; then
  echo "Could not resolve a kind version to install." >&2
  exit 1
fi

echo "Installing kind ${VERSION} (linux/${ARCH})"

BINARY="kind-linux-${ARCH}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

$CURL -o "${TMP_DIR}/${BINARY}" "https://kind.sigs.k8s.io/dl/${VERSION}/${BINARY}"

$CURL -o "${TMP_DIR}/${BINARY}.sha256sum" "https://kind.sigs.k8s.io/dl/${VERSION}/${BINARY}.sha256sum"

echo "Verifying checksum"
(cd "${TMP_DIR}" && sha256sum -c "${BINARY}.sha256sum")

install -m 0755 "${TMP_DIR}/${BINARY}" /usr/local/bin/kind

kind version
