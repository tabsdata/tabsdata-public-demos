#!/bin/bash
#
# Copyright 2026. Tabs Data Inc.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${ROOT_DIR}/source.sh"
source "${SCRIPT_DIR}/ui.sh"

run_cmd "Stopping Tabsdata demo server instance" tdserver stop --instance demo
run_cmd_sh "Deleting Tabsdata demo server instance" "printf 'yes\n' | tdserver delete --instance demo --force || true"

run_cmd "Starting Tabsdata demo server instance" tdserver start --instance demo

TD_SERVER=${TD_SERVER:=localhost:2457}
TD_USER=${TD_USER:=admin}
TD_PASSWORD=${TD_PASSWORD:=tabsdata}
TD_ROLE=${TD_ROLE:=sys_admin}

run_cmd "Logging into Tabsdata" td login --server "${TD_SERVER}" --user "${TD_USER}" --password "${TD_PASSWORD}" --role "${TD_ROLE}"

run_cmd "Creating collection: airport" td collection create --name airport

subscribe="True"

(cd "${ROOT_DIR}/tabsdata_functions/sql";
  run_cmd "Registering SQL publisher" td fn register --coll airport --path 01_flight_pub.py::flight_pub --update
  if [ "${subscribe}" = "True" ]; then
      run_cmd "Registering SQL subscriber" td fn register --coll airport --path 02_mysql_sub.py::mysql_sub --update
  else
      print_warning "Skipping SQL subscriber setup"
  fi
)

print_success "Registered SQL ingestion functions"

run_cmd "Triggering SQL publisher" td fn trigger --coll airport --name flight_pub

(cd "${ROOT_DIR}/tabsdata_functions/log-publisher";
  run_cmd "Registering log publisher" td fn register --coll airport --path 09_log_pub.py::publish_air_web_page_views --update
)

run_cmd "Creating collection: flight_streaming" td collection create --name flight_streaming
(cd "${ROOT_DIR}/tabsdata_functions/kafka";
  run_cmd "Registering Kafka publisher" td fn register --coll flight_streaming --path 08_flight_events_pub.py::flight_event_publisher --update
)
run_cmd "Triggering log publisher" td fn trigger --coll airport --name publish_air_web_page_views

print_header "Demo Environment Ready"
print_kv "Redpanda Console" "http://localhost:8080"
print_kv "Tabsdata UI" "http://localhost:2457"
print_kv "Log directory" "${ROOT_DIR}/data/td-logs"
