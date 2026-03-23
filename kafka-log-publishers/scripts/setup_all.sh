#!/bin/bash
#
# Copyright 2026. Tabs Data Inc.
#

set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${ROOT_DIR}/source.sh"
source "${SCRIPT_DIR}/ui.sh"

print_header "Tabsdata Airport Demo Setup"
"${SCRIPT_DIR}/preflight.sh"

"${SCRIPT_DIR}/setup_hashicorp.sh"
"${SCRIPT_DIR}/setup_mysql.sh"
"${SCRIPT_DIR}/setup_log_producer.sh"
"${SCRIPT_DIR}/setup_redpanda.sh"
"${SCRIPT_DIR}/setup_tabsdata.sh"
