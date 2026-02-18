#!/bin/bash

#
# Copyright 2026 Tabs Data Inc.
#

set -euo pipefail

CONTAINER_NAME="td-grok-log-producer"
IMAGE_NAME="grok-log-producer-image"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PRODUCER_DIR="${PROJECT_ROOT}/producers/log"
HOST_LOG_DIR="${HOST_LOG_DIR:-${PROJECT_ROOT}/data/td-logs}"
source "${SCRIPT_DIR}/ui.sh"

print_header "Log Producer Setup"
print_step "Stopping and removing existing log generator container"
docker kill "${CONTAINER_NAME}" 2>/dev/null || true
docker rm "${CONTAINER_NAME}" 2>/dev/null || true

print_step "Building image: ${IMAGE_NAME}"
mkdir -p "${HOST_LOG_DIR}"
docker build -t "${IMAGE_NAME}" "${PRODUCER_DIR}"

print_step "Starting container: ${CONTAINER_NAME}"
docker run -d --rm --name "${CONTAINER_NAME}" \
  -v "${HOST_LOG_DIR}:/logs" \
  "${IMAGE_NAME}"

sleep 2
if ! docker ps --format '{{.Names}}' | grep -qx "${CONTAINER_NAME}"; then
  print_error "Log producer failed to stay running"
  docker logs "${CONTAINER_NAME}" 2>/dev/null || true
  exit 1
fi

print_success "Log generator is running"
print_kv "Container" "${CONTAINER_NAME}"
print_kv "Host folder" "${HOST_LOG_DIR}"
print_kv "Current log file" "${HOST_LOG_DIR}/td-web_airline.log"
print_kv "Rotation files" "${HOST_LOG_DIR}/td-web_airline.log.*"
print_kv "Tail command" "tail -f ${HOST_LOG_DIR}/td-web_airline.log"
