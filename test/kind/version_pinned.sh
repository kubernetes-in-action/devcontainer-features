#!/usr/bin/env bash
set -e

source dev-container-features-test-lib

check "pinned kind version installed" bash -c "kind version | grep -q 'v0.32.0'"

reportResults
