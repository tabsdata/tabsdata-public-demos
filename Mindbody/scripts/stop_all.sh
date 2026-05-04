#!/bin/bash
#
# Stop Mindbody demo services (Tabsdata + Docker).
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
  printf "%b\n" "${UI_BOLD}${UI_YELLOW}Delete Tabsdata Instance${UI_RESET}"
  printf "  %bThis will permanently delete instance '%s'.%b\n" "${UI_YELLOW}" "${TD_INSTANCE_NAME}" "${UI_RESET}"
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

print_header "Stopping Mindbody Demo"

print_step "Stopping Tabsdata server instance: ${TD_INSTANCE_NAME}"
if command -v tdserver >/dev/null 2>&1; then
  tdserver stop --instance "${TD_INSTANCE_NAME}" >/dev/null 2>&1 || true
  print_success "Tabsdata server stopped"
  if confirm_delete_instance; then
    run_cmd_sh "Deleting Tabsdata instance: ${TD_INSTANCE_NAME}" "printf 'yes\n' | tdserver delete --instance \"${TD_INSTANCE_NAME}\" --force || true"
  else
    print_warning "Skipping Tabsdata instance deletion"
  fi
else
  print_warning "tdserver not found; skipping"
fi

print_step "Stopping and removing Docker containers"
docker kill td-mindbody-postgres >/dev/null 2>&1 || true
docker rm td-mindbody-postgres >/dev/null 2>&1 || true
print_success "Docker containers stopped"
