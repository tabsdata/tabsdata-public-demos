#!/bin/bash
#
# Stop local demo services (Tabsdata + Docker containers).
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${ROOT_DIR}/source.sh"
source "${SCRIPT_DIR}/ui.sh"

confirm_delete_instance() {
  if [ ! -t 0 ]; then
    return 1
  fi

  echo
  print_divider
  printf "%b\n" "${UI_BOLD}${UI_YELLOW}Delete Tabsdata Demo Instance${UI_RESET}"
  printf "  %bThis will permanently delete instance 'demo'.%b\n" "${UI_YELLOW}" "${UI_RESET}"
  printf "  %bChoose No to stop services without deleting the instance.%b\n" "${UI_YELLOW}" "${UI_RESET}"
  print_divider
  printf "%b" "${UI_BOLD}Delete instance while stopping [y/N]: ${UI_RESET}"
  read -r reply
  echo

  case "${reply}" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

print_header "Stopping Demo Services"
print_step "Stopping Tabsdata server instance: demo"
if command -v tdserver >/dev/null 2>&1; then
  tdserver stop --instance demo >/dev/null 2>&1 || true
  print_success "Tabsdata server stop requested"
  if confirm_delete_instance; then
    run_cmd_sh "Deleting Tabsdata demo server instance" "printf 'yes\n' | tdserver delete --instance demo --force || true"
  else
    print_warning "Skipping Tabsdata demo instance deletion"
  fi
else
  print_warning "tdserver not found; skipping Tabsdata server stop."
fi

containers=(
  td-grok-log-producer
  td-redpanda-flights-producer
  td-redpanda-console
  td-redpanda
  td-sample-data
  td-sample-secrets
)

print_step "Stopping and removing Docker containers"
for c in "${containers[@]}"; do
  docker kill "${c}" >/dev/null 2>&1 || true
  docker rm "${c}" >/dev/null 2>&1 || true
done

print_success "Demo containers stopped"
