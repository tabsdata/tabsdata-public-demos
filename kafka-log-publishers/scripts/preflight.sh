#!/bin/bash
#
# Preflight checks for local demo dependencies.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/ui.sh"

missing=0

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    print_error "Missing required command: ${cmd}"
    missing=1
  fi
}

print_header "Preflight Checks"

if command -v python3 >/dev/null 2>&1; then
  run_cmd "Installing tabsdata extras" python3 -m pip install --upgrade 'tabsdata[all]'
  run_cmd "Installing Python dependencies from requirements.txt" python3 -m pip install -r "${ROOT_DIR}/requirements.txt"
else
  print_error "Missing required command: python3"
  missing=1
fi

require_cmd bash
require_cmd python3
require_cmd pip3
require_cmd docker
require_cmd curl
require_cmd jq
require_cmd td
require_cmd tdserver

if [ "${missing}" -ne 0 ]; then
  print_error "Preflight failed. Install missing dependencies and retry."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  print_error "Docker is installed but not running (or not accessible)."
  print_warning "Start Docker Desktop and retry."
  exit 1
fi

print_kv "Python" "$(python3 --version)"
print_kv "Pip" "$(pip3 --version)"
print_kv "Docker" "$(docker --version)"
print_kv "td" "$(td --version 2>/dev/null || echo 'installed')"
print_kv "tdserver" "$(tdserver --version 2>/dev/null || echo 'installed')"
print_success "Preflight passed"
print_kv "Workspace" "${ROOT_DIR}"
