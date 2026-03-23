#!/bin/bash
#
# Stop local demo services (Tabsdata + Docker containers).
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${ROOT_DIR}/source.sh"
source "${SCRIPT_DIR}/ui.sh"

print_header "Stopping Demo Services"
SELECTOR="${SCRIPT_DIR}/component_selector.py"
selection_file="$(mktemp)"
destroy_file="$(mktemp)"
trap 'rm -f "${selection_file}" "${destroy_file}"' EXIT

run_cmd "Selecting stop components" python3 "${SELECTOR}" select --mode stop --out-file "${selection_file}"

SELECTED_COMPONENTS=()
while IFS= read -r component; do
  [ -n "${component}" ] && SELECTED_COMPONENTS+=("${component}")
done < "${selection_file}"

if [ "${#SELECTED_COMPONENTS[@]}" -eq 0 ]; then
  print_warning "No components selected. Nothing to stop."
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

stop_container() {
  local name="$1"
  docker kill "${name}" >/dev/null 2>&1 || true
  docker rm "${name}" >/dev/null 2>&1 || true
}

print_step "Selected components: ${SELECTED_COMPONENTS[*]}"

if contains_component "hashicorp"; then
  print_step "Stopping HashiCorp container"
  stop_container "td-sample-secrets"
  print_success "HashiCorp stopped"
fi

if contains_component "log_file"; then
  print_step "Stopping log file producer container"
  stop_container "td-grok-log-producer"
  print_success "Log file producer stopped"
fi

if contains_component "mysql"; then
  print_step "Stopping MySQL container"
  stop_container "td-sample-data"
  print_success "MySQL stopped"
fi

if contains_component "redpanda"; then
  print_step "Stopping Redpanda containers"
  stop_container "td-redpanda-flights-producer"
  stop_container "td-redpanda-console"
  stop_container "td-redpanda"
  print_success "Redpanda stopped"
fi

if contains_component "tabsdata"; then
  print_step "Stopping Tabsdata server instance: demo"
  if command -v tdserver >/dev/null 2>&1; then
    tdserver stop --instance demo >/dev/null 2>&1 || true
    print_success "Tabsdata server stop requested"
    run_cmd "Confirming Tabsdata destroy" python3 "${SELECTOR}" confirm-destroy --out-file "${destroy_file}"
    destroy_choice="$(tr -d '\r\n' < "${destroy_file}")"
    if [ "${destroy_choice}" = "true" ]; then
      run_cmd_sh "Deleting Tabsdata demo server instance" "printf 'yes\n' | tdserver delete --instance demo --force || true"
    else
      print_warning "Tabsdata instance destroy skipped"
    fi
  else
    print_warning "tdserver not found; skipping Tabsdata stop/destroy."
  fi
fi

print_success "Selected components stopped"
