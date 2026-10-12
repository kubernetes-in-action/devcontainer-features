#!/usr/bin/env bash
set -e

# Bundled with the devcontainer CLI's test runner.
source dev-container-features-test-lib

check "kind is on PATH" bash -c "command -v kind"
check "kind version runs" kind version

reportResults
