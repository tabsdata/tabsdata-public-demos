#!/bin/bash
#
# Copyright 2025. Tabs Data Inc.
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../source.sh"
source "${SCRIPT_DIR}/ui.sh"

print_header "HashiCorp Vault Setup"

print_step "Resetting Vault container"
docker kill td-sample-secrets 2>/dev/null
docker rm td-sample-secrets 2>/dev/null
print_step "Starting Vault dev container"
docker run --name td-sample-secrets -e VAULT_DEV_ROOT_TOKEN_ID=${HASHICORP_TOKEN} -p ${HASHICORP_PORT}:8200 -d hashicorp/vault
sleep 5

json_payload='{  "data": {   "user": "root", "password" : "mysql"  } }'

curl --header "X-Vault-Token: ${HASHICORP_TOKEN}" \
      --header "X-Vault-Namespace: admin" \
      --data "${json_payload}" \
      http://${HASHICORP_HOST}:${HASHICORP_PORT}/v1/secret/data/mysql 2>/dev/null \
      | exit 1

json_payload='{  "data": {   "access_key": "'${AWS_ACCESS_KEY}'", "secret_key" : "'${AWS_SECRET_KEY}'"  } }'

curl --header "X-Vault-Token: ${HASHICORP_TOKEN}" \
      --header "X-Vault-Namespace: admin" \
      --data "${json_payload}" \
      http://${HASHICORP_HOST}:${HASHICORP_PORT}/v1/secret/data/s3 2>/dev/null \
      | exit 1

json_payload='{  "data": {   "user": "'${SALESFORCE_USER}'", "password" : "'${SALESFORCE_PASSWORD}'", "token" : "'${SALESFORCE_TOKEN}'"   } }'

curl --header "X-Vault-Token: ${HASHICORP_TOKEN}" \
      --header "X-Vault-Namespace: admin" \
      --data "${json_payload}" \
      http://${HASHICORP_HOST}:${HASHICORP_PORT}/v1/secret/data/salesforce 2>/dev/null \
      | exit 1

json_payload='{  "data": {  "account": "'${SNOWFLAKE_ACCOUNT}'", "user": "'${SNOWFLAKE_USER}'", "pat" : "'${SNOWFLAKE_PAT}'", "role" : "'${SNOWFLAKE_ROLE}'"   } }'

curl --header "X-Vault-Token: ${HASHICORP_TOKEN}" \
      --header "X-Vault-Namespace: admin" \
      --data "${json_payload}" \
      http://${HASHICORP_HOST}:${HASHICORP_PORT}/v1/secret/data/snowflake 2>/dev/null \
      | exit 1


json_payload='{  "data": {   "user": "'${RP_ADMIN_USER}'", "password" : "'${RP_ADMIN_PASS}'" } }'

curl --header "X-Vault-Token: ${HASHICORP_TOKEN}" \
      --header "X-Vault-Namespace: admin" \
      --data "${json_payload}" \
      http://${HASHICORP_HOST}:${HASHICORP_PORT}/v1/secret/data/redpanda 2>/dev/null \
      | exit 1

# Show stored secrets
print_step "Listing stored secret paths"
curl --header "X-Vault-Token: ${HASHICORP_TOKEN}" \
      --header "X-Vault-Namespace: admin" \
      "http://${HASHICORP_HOST}:${HASHICORP_PORT}/v1/secret/metadata?list=true" | jq

print_success "Vault setup complete"
print_kv "Endpoint" "${HASHICORP_HOST}:${HASHICORP_PORT}"
print_kv "Root token" "${HASHICORP_TOKEN}"
