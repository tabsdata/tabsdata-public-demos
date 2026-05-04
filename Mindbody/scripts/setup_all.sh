#!/bin/bash
#
# Full Mindbody demo setup: preflight → postgres → tabsdata.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${ROOT_DIR}/source.sh"
source "${SCRIPT_DIR}/ui.sh"

print_header "Mindbody Demo Setup"

"${SCRIPT_DIR}/preflight.sh"
"${SCRIPT_DIR}/setup_postgres.sh"
"${SCRIPT_DIR}/setup_tabsdata.sh"
