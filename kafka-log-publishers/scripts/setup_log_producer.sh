#!/bin/bash

#
# Copyright 2026 Tabs Data Inc.
#

CONTAINER_NAME="td-grok-log-producer"
IMAGE_NAME="grok-log-producer-image"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PRODUCER_DIR="${PROJECT_ROOT}/producers/log"
HOST_LOG_DIR="${HOST_LOG_DIR:-${PROJECT_ROOT}/data/td-logs}"

echo "Stopping and removing existing log generator container..."
docker kill "${CONTAINER_NAME}" 2>/dev/null || true
docker rm "${CONTAINER_NAME}" 2>/dev/null || true

echo "Building ${IMAGE_NAME} image..."
mkdir -p "${HOST_LOG_DIR}"
echo "Clearing existing log files in ${HOST_LOG_DIR}..."
for file in "${HOST_LOG_DIR}"/td-web_airline.log*; do
  [ -f "${file}" ] || continue
  filename="$(basename "${file}")"

  if [[ "${filename}" == "td-web_airline.log" || "${filename}" =~ ^td-web_airline\.log\.[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}$ ]]; then
    rm -f "${file}"
  fi
done
docker build -t "${IMAGE_NAME}" "${PRODUCER_DIR}"

echo "Starting ${CONTAINER_NAME} container..."
docker run -d --rm --name "${CONTAINER_NAME}" \
  -v "${HOST_LOG_DIR}:/logs" \
  "${IMAGE_NAME}"

echo
echo ">>> Log generator is running: ${CONTAINER_NAME}"
echo ">>> Host folder: ${HOST_LOG_DIR}"
echo ">>> Current log file: ${HOST_LOG_DIR}/td-web_airline.log"
echo ">>> Rotation files: ${HOST_LOG_DIR}/td-web_airline.log.*"
echo
echo "To tail:"
echo "  tail -f ${HOST_LOG_DIR}/td-web_airline.log"
