#!/bin/bash
#
# Start a PostgreSQL container for the Mindbody demo.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../source.sh"
source "${SCRIPT_DIR}/ui.sh"

print_header "PostgreSQL Setup"

print_step "Resetting PostgreSQL container"
docker kill td-mindbody-postgres 2>/dev/null || true
docker rm -v td-mindbody-postgres 2>/dev/null || true

print_step "Starting PostgreSQL container"
docker run --name td-mindbody-postgres \
  -e POSTGRES_USER="${PG_USER}" \
  -e POSTGRES_PASSWORD="${PG_PASSWORD}" \
  -e POSTGRES_DB="${PG_DATABASE}" \
  -p "${PG_PORT}:5432" \
  -d \
  postgres:16

sleep 2
if ! docker ps --format '{{.Names}}' | grep -qx 'td-mindbody-postgres'; then
  print_error "PostgreSQL container failed to stay running"
  docker logs td-mindbody-postgres --tail 120 2>/dev/null || true
  exit 1
fi

print_step "Waiting for PostgreSQL to be ready"
for i in {1..30}; do
  if docker exec td-mindbody-postgres pg_isready -U "${PG_USER}" >/dev/null 2>&1; then
    break
  fi
  if [ "$i" -eq 30 ]; then
    print_error "PostgreSQL did not become ready in time"
    docker logs td-mindbody-postgres --tail 120 || true
    exit 1
  fi
  sleep 2
done

print_success "PostgreSQL setup complete"
print_kv "Endpoint" "${PG_HOST}:${PG_PORT}"
print_kv "Database" "${PG_DATABASE}"
print_kv "User" "${PG_USER}"
