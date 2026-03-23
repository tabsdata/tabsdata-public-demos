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

SELECTOR="${SCRIPT_DIR}/component_selector.py"
selection_file="$(mktemp)"
trap 'rm -f "${selection_file}"' EXIT

run_cmd "Selecting setup components" python3 "${SELECTOR}" select --mode setup --out-file "${selection_file}"

SELECTED_COMPONENTS=()
while IFS= read -r component; do
  [ -n "${component}" ] && SELECTED_COMPONENTS+=("${component}")
done < "${selection_file}"

if [ "${#SELECTED_COMPONENTS[@]}" -eq 0 ]; then
  print_warning "No components selected. Nothing to set up."
  exit 0
fi

contains_component() {
  local target="$1"
  local item
  for item in "${SELECTED_COMPONENTS[@]}"; do
    if [ "${item}" = "${target}" ]; then
      return 0
    fi
  done
  return 1
}

print_step "Selected components: ${SELECTED_COMPONENTS[*]}"

if contains_component "hashicorp"; then
  "${SCRIPT_DIR}/setup_hashicorp.sh"
fi
if contains_component "log_file"; then
  "${SCRIPT_DIR}/setup_log_producer.sh"
fi
if contains_component "mysql"; then
  "${SCRIPT_DIR}/setup_mysql.sh"
fi
if contains_component "redpanda"; then
  "${SCRIPT_DIR}/setup_redpanda.sh"
fi
if contains_component "tabsdata"; then
  "${SCRIPT_DIR}/setup_tabsdata.sh"
fi
