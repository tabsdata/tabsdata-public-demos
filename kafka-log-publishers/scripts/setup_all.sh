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

print_step "Installing Python dependencies from requirements.txt"
python3 -m pip install -r "${ROOT_DIR}/requirements.txt"
print_success "Python dependencies installed"

"${SCRIPT_DIR}/setup_hashicorp.sh"
"${SCRIPT_DIR}/setup_mysql.sh"
"${SCRIPT_DIR}/setup_log_producer.sh"
"${SCRIPT_DIR}/setup_redpanda.sh"

print_step "Resetting Tabsdata demo server instance"
tdserver stop --instance demo
echo yes | tdserver delete --instance demo

tdserver start --instance demo
print_success "Tabsdata server started"

TD_SERVER=${TD_SERVER:=localhost:2457}
TD_USER=${TD_USER:=admin}
TD_PASSWORD=${TD_PASSWORD:=tabsdata}
TD_ROLE=${TD_ROLE:=sys_admin}

td login --server ${TD_SERVER} --user ${TD_USER} --password ${TD_PASSWORD} --role ${TD_ROLE}

td collection create --name airport

print_success "Created collection: airport"

subscribe="True"

(cd "${ROOT_DIR}/pipelines/sql";
  td fn register --coll airport --path 01_flight_pub.py::flight_pub
  if [ "$subscribe" = "True" ]; then
      td fn register --coll airport --path 02_mysql_sub.py::mysql_sub --update
  else
      print_warning "Skipping SQL subscriber setup"
  fi
)

print_success "Registered SQL ingestion functions"

td fn trigger --coll airport --name flight_pub

(cd "${ROOT_DIR}/pipelines/log-publisher";
  td fn register --coll airport --path 09_log_pub.py::publish_air_web_page_views --update
)

td collection create --name flight_streaming
(cd "${ROOT_DIR}/pipelines/kafka";
  td fn register --coll flight_streaming --path 08_flight_events_pub.py::flight_event_publisher --update
)
td fn trigger --coll airport --name publish_air_web_page_views

print_header "Demo Environment Ready"
print_kv "Redpanda Console" "http://localhost:8080"
print_kv "Tabsdata UI" "http://localhost:2457"
print_kv "Log directory" "${ROOT_DIR}/data/td-logs"
