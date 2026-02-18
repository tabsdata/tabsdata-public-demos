#!/bin/bash
#
# Copyright 2026. Tabs Data Inc.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../source.sh"
source "${SCRIPT_DIR}/ui.sh"
TABLE_SQL="${SCRIPT_DIR}/../data/sql/flight-only.sql"
TABLE_NAME="flight"

print_header "MySQL Setup"

if [ ! -f "${TABLE_SQL}" ]; then
  print_error "Missing required SQL file: ${TABLE_SQL}"
  print_error "Expected file: ${SCRIPT_DIR}/../data/sql/flight-only.sql"
  exit 1
fi

print_step "Resetting MySQL container"
docker kill td-sample-data 2>/dev/null || true
docker rm -v td-sample-data 2>/dev/null || true
print_step "Starting MySQL container"
docker run --name td-sample-data \
  -e MYSQL_ROOT_PASSWORD="${MYSQL_PASSWORD}" \
  -p "${MYSQL_PORT}:3306" \
  -d \
  mysql:8.0

sleep 2
if ! docker ps --format '{{.Names}}' | grep -qx 'td-sample-data'; then
  print_error "MySQL container failed to stay running"
  docker logs td-sample-data --tail 120 2>/dev/null || true
  exit 1
fi

print_step "Waiting for MySQL startup and root login readiness"
for i in {1..60}; do
  if docker exec -i td-sample-data mysql -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; then
    break
  fi
  if [ "$i" -eq 60 ]; then
    print_error "MySQL did not become ready for root login"
    docker logs td-sample-data --tail 120 || true
    exit 1
  fi
  sleep 2
done

print_step "Creating schemas and loading seed data"
docker exec -i td-sample-data mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "DROP DATABASE IF EXISTS airportdb; CREATE DATABASE airportdb;"
docker exec -i td-sample-data mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "DROP DATABASE IF EXISTS td_processed_data; CREATE DATABASE td_processed_data;"
docker exec -i td-sample-data mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} airportdb < "${TABLE_SQL}"
docker exec -i td-sample-data mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SHOW TABLES IN airportdb; SELECT COUNT(*) AS ${TABLE_NAME}_rows FROM airportdb.${TABLE_NAME}; SHOW DATABASES LIKE 'td_processed_data';"

if ! docker ps --format '{{.Names}}' | grep -qx 'td-sample-data'; then
  print_error "MySQL container stopped unexpectedly after setup"
  docker logs td-sample-data --tail 120 2>/dev/null || true
  exit 1
fi

print_success "MySQL setup complete"
print_kv "Endpoint" "${MYSQL_HOST}:${MYSQL_PORT}"
print_kv "Schemas" "airportdb, td_processed_data"
print_kv "Loaded table" "airportdb.${TABLE_NAME} from $(basename "${TABLE_SQL}")"
