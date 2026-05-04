#!/bin/bash
#
# Register Mindbody functions and trigger publishers.
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
  printf "%b\n" "${UI_BOLD}${UI_YELLOW}Delete And Rebuild Tabsdata Instance${UI_RESET}"
  printf "  %bThis will permanently delete instance '%s' and recreate it.%b\n" "${UI_YELLOW}" "${TD_INSTANCE_NAME}" "${UI_RESET}"
  printf "  %bChoose Yes to continue setup, or No to stop this script now.%b\n" "${UI_YELLOW}" "${UI_RESET}"
  print_divider
  printf "%b" "${UI_BOLD}Delete and rebuild instance [y/N]: ${UI_RESET}"
  read -r reply
  echo

  case "${reply}" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

print_header "Tabsdata Setup"

run_cmd "Stopping Tabsdata server instance: ${TD_INSTANCE_NAME}" tdserver stop --instance "${TD_INSTANCE_NAME}"
if confirm_delete_instance; then
  run_cmd_sh "Deleting Tabsdata server instance: ${TD_INSTANCE_NAME}" "printf 'yes\n' | tdserver delete --instance \"${TD_INSTANCE_NAME}\" --force || true"
else
  print_warning "User chose not to delete/rebuild Tabsdata instance. Stopping."
  exit 0
fi

run_cmd "Starting Tabsdata server instance: ${TD_INSTANCE_NAME}" tdserver start --instance "${TD_INSTANCE_NAME}"
run_cmd "Logging into Tabsdata" td login --server "${TD_SERVER}" --user "${TD_USER}" --password "${TD_PASSWORD}" --role "${TD_ROLE}"
run_cmd "Creating collection: bronze"      td collection create --name bronze
run_cmd "Creating collection: silver"      td collection create --name silver
run_cmd "Creating collection: gold"        td collection create --name gold
run_cmd "Creating collection: subscribers" td collection create --name subscribers

run_cmd "Granting bronze access to silver"      td collection add-perm --name bronze --to-coll silver
run_cmd "Granting bronze access to gold"        td collection add-perm --name bronze --to-coll gold
run_cmd "Granting silver access to bronze"      td collection add-perm --name silver --to-coll bronze
run_cmd "Granting silver access to gold"        td collection add-perm --name silver --to-coll gold
run_cmd "Granting gold access to bronze"        td collection add-perm --name gold --to-coll bronze
run_cmd "Granting gold access to silver"        td collection add-perm --name gold --to-coll silver
run_cmd "Granting subscribers access to bronze" td collection add-perm --name subscribers --to-coll bronze
run_cmd "Granting subscribers access to silver" td collection add-perm --name subscribers --to-coll silver
run_cmd "Granting subscribers access to gold"   td collection add-perm --name subscribers --to-coll gold
run_cmd "Granting bronze access to subscribers" td collection add-perm --name bronze --to-coll subscribers
run_cmd "Granting silver access to subscribers" td collection add-perm --name silver --to-coll subscribers
run_cmd "Granting gold access to subscribers"   td collection add-perm --name gold --to-coll subscribers

(cd "${ROOT_DIR}/functions/bronze";
  run_cmd "Registering locations publisher"   td fn register --coll bronze --path 01_locations_pub.py::locations_pub
  run_cmd "Registering classes publisher"     td fn register --coll bronze --path 02_classes_pub.py::classes_pub
  run_cmd "Registering clients publisher"     td fn register --coll bronze --path 03_clients_pub.py::clients_pub
  run_cmd "Registering services publisher"    td fn register --coll bronze --path 04_services_pub.py::services_pub
  run_cmd "Registering products publisher"    td fn register --coll bronze --path 05_products_pub.py::products_pub
  run_cmd "Registering staff publisher"       td fn register --coll bronze --path 06_staff_pub.py::staff_pub
  run_cmd "Registering visits transformer"    td fn register --coll bronze --path 07_visits_trf.py::visits_trf
  run_cmd "Registering purchases publisher"   td fn register --coll bronze --path 08_purchases_pub.py::purchases_pub
)

(cd "${ROOT_DIR}/functions/silver";
  run_cmd "Registering locations silver transformer"  td fn register --coll silver --path 01_locations_silver_trf.py::locations_silver_trf
  run_cmd "Registering classes silver transformer"    td fn register --coll silver --path 02_classes_silver_trf.py::classes_silver_trf
  run_cmd "Registering clients silver transformer"    td fn register --coll silver --path 03_clients_silver_trf.py::clients_silver_trf
  run_cmd "Registering services silver transformer"   td fn register --coll silver --path 04_services_silver_trf.py::services_silver_trf
  run_cmd "Registering products silver transformer"   td fn register --coll silver --path 05_products_silver_trf.py::products_silver_trf
  run_cmd "Registering staff silver transformer"      td fn register --coll silver --path 06_staff_silver_trf.py::staff_silver_trf
  run_cmd "Registering visits silver transformer"     td fn register --coll silver --path 07_visits_silver_trf.py::visits_silver_trf
  run_cmd "Registering purchases silver transformer"  td fn register --coll silver --path 08_purchases_silver_trf.py::purchases_silver_trf
)

(cd "${ROOT_DIR}/functions/gold";
  run_cmd "Registering client activity gold transformer" td fn register --coll gold --path 01_client_activity_gold_trf.py::client_activity_gold_trf
)

(cd "${ROOT_DIR}/functions/subscribers";
  run_cmd "Registering postgres subscriber"   td fn register --coll subscribers --path 09_postgres_sub.py::postgres_sub
)

print_success "All functions registered"

for fn in locations_pub classes_pub clients_pub services_pub products_pub staff_pub purchases_pub; do
  run_cmd "Triggering ${fn}" td fn trigger --coll bronze --name "${fn}"
done

run_cmd "Triggering postgres_sub" td fn trigger --coll subscribers --name postgres_sub

print_header "Mindbody Demo Ready"
print_kv "Tabsdata UI"   "http://localhost:${TD_PORT:-2457}"
print_kv "PostgreSQL"    "${PG_HOST}:${PG_PORT}/${PG_DATABASE}"
