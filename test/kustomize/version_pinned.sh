#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "pinned kustomize version installed" bash -c "kustomize version | grep -q 'v5.7.1'"

reportResults
