#!/bin/bash
#
# Copyright 2026. Tabs Data Inc.
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${ROOT_DIR}/source.sh"

echo
echo "Installing Python dependencies from requirements.txt..."
python3 -m pip install -r "${ROOT_DIR}/requirements.txt"

"${SCRIPT_DIR}/setup_hashicorp.sh"
"${SCRIPT_DIR}/setup_mysql.sh"
"${SCRIPT_DIR}/setup_log_producer.sh"
"${SCRIPT_DIR}/setup_redpanda.sh"

tdserver stop --instance demo
echo yes | tdserver delete --instance demo

tdserver start --instance demo

TD_SERVER=${TD_SERVER:=localhost:2457}
TD_USER=${TD_USER:=admin}
TD_PASSWORD=${TD_PASSWORD:=tabsdata}
TD_ROLE=${TD_ROLE:=sys_admin}

td login --server ${TD_SERVER} --user ${TD_USER} --password ${TD_PASSWORD} --role ${TD_ROLE}

td collection create --name airport

echo
echo "Created 1 collection(s)"
echo

subscribe="False"

(cd "${ROOT_DIR}/pipelines/sql";
  td fn register --coll airport --path 01_flight_pub.py::flight_pub
  if [ "$subscribe" = "True" ]; then
      td fn register --coll airport --path 02_mysql_sub.py::mysql_sub --update
  else
      echo "skipping sql subscriber setup"
  fi
)

echo
echo "Registered SQL ingestion functions"
echo

td fn trigger --coll airport --name flight_pub

(cd "${ROOT_DIR}/pipelines/log-publisher";
  td fn register --coll airport --path 09_log_pub.py::publish_air_web_page_views --update
)

td collection create --name flight_streaming
(cd "${ROOT_DIR}/pipelines/kafka";
  td fn register --coll flight_streaming --path 08_flight_events_pub.py::flight_event_publisher --update
)
td fn trigger --coll airport --name publish_air_web_page_views

echo
echo "------------------------------------------------------------"
echo "Demo environment is ready"
echo "Redpanda Console (messages): http://localhost:8080"
echo "Tabsdata UI:                  http://localhost:2457"
echo "Log directory:                ${ROOT_DIR}/data/td-logs"
echo "------------------------------------------------------------"
