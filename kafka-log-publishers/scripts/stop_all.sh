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
print_step "Stopping Tabsdata server instance: demo"
if command -v tdserver >/dev/null 2>&1; then
  tdserver stop --instance demo >/dev/null 2>&1 || true
  print_success "Tabsdata server stop requested"
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
