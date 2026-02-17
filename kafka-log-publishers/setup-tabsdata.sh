#!/bin/bash
#
# Compatibility wrapper. Preferred entrypoint: scripts/setup_all.sh
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
(cd "${SCRIPT_DIR}/scripts" && ./setup_all.sh)
