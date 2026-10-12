#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "kustomize is on PATH" bash -c "command -v kustomize"
check "kustomize version runs" kustomize version

reportResults
