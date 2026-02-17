#!/bin/bash
#
# Copyright 2026. Tabs Data Inc.
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../source.sh"
TABLE_SQL="${SCRIPT_DIR}/../data/sql/flight-only.sql"
TABLE_NAME="flights"

if [ ! -f "${TABLE_SQL}" ]; then
  echo "Missing required SQL file: ${TABLE_SQL}"
  echo "Expected file: ${SCRIPT_DIR}/../data/sql/flight-only.sql"
  exit 1
fi

docker kill td-sample-data 2>/dev/null || true
docker rm td-sample-data 2>/dev/null || true
docker run --name td-sample-data \
  -e MYSQL_ROOT_PASSWORD="${MYSQL_PASSWORD}" \
  -p "${MYSQL_PORT}:3306" \
  -d \
  mysql

sleep 8

docker exec -i td-sample-data mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "DROP DATABASE IF EXISTS airportdb; CREATE DATABASE airportdb;"
docker exec -i td-sample-data mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "DROP DATABASE IF EXISTS td_processed_data; CREATE DATABASE td_processed_data;"
docker exec -i td-sample-data mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} airportdb < "${TABLE_SQL}"
docker exec -i td-sample-data mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SHOW TABLES IN airportdb; SELECT COUNT(*) AS ${TABLE_NAME}_rows FROM airportdb.${TABLE_NAME}; SHOW DATABASES LIKE 'td_processed_data';"

echo
echo ">>> MySQL ready with schemas: airportdb, td_processed_data at ${MYSQL_HOST}:${MYSQL_PORT}"
echo ">>> Loaded table: airportdb.${TABLE_NAME} from $(basename "${TABLE_SQL}")"
echo
