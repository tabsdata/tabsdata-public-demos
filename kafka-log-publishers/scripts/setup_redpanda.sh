#!/bin/bash

#
# Copyright 2026 Tabs Data Inc.
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PRODUCER_DIR="${ROOT_DIR}/producers/kafka"
source "${ROOT_DIR}/source.sh"


# Stop and remove existing containers
echo "Stopping and removing existing Redpanda and producer containers..."
docker kill td-redpanda 2>/dev/null
docker rm td-redpanda 2>/dev/null
docker kill td-redpanda-flights-producer 2>/dev/null
docker rm td-redpanda-flights-producer 2>/dev/null
docker kill td-redpanda-console 2>/dev/null
docker rm td-redpanda-console 2>/dev/null

# Start Redpanda
echo "Starting Redpanda container..."
docker run -d --rm --name td-redpanda \
  --entrypoint /bin/sh \
  -e RP_HOST_FUNCTION="${RP_HOST_FUNCTION}" \
  -e RP_PORT_KAFKA_FUNCTION="${RP_PORT_KAFKA_FUNCTION}" \
  -e RP_HOST_DOCKER="${RP_HOST_DOCKER}" \
  -e RP_PORT_KAFKA_DOCKER="${RP_PORT_KAFKA_DOCKER}" \
  -e RP_PORT_SCHEMA="${RP_PORT_SCHEMA}" \
  -e RP_PORT_ADMIN="${RP_PORT_ADMIN}" \
  -e RP_ADMIN_USER="${RP_ADMIN_USER}" \
  -e RP_ADMIN_PASS="${RP_ADMIN_PASS}" \
  -p ${RP_PORT_KAFKA_FUNCTION}:${RP_PORT_KAFKA_FUNCTION} \
  -p ${RP_PORT_KAFKA_DOCKER}:${RP_PORT_KAFKA_DOCKER} \
  -p ${RP_PORT_SCHEMA}:${RP_PORT_SCHEMA} \
  -p ${RP_PORT_ADMIN}:${RP_PORT_ADMIN} \
  redpandadata/redpanda:latest \
  -c '
    # 1. Start Redpanda in background
    echo "Starting Redpanda service..."
    rpk redpanda start \
      --smp 1 --memory 1G --overprovisioned \
      --advertise-kafka-addr internal://localhost:9092,host://${RP_HOST_FUNCTION}:${RP_PORT_KAFKA_FUNCTION},docker://${RP_HOST_DOCKER}:${RP_PORT_KAFKA_DOCKER} \
      --set redpanda.kafka_api="[{\"name\":\"internal\",\"address\":\"0.0.0.0\",\"port\":9092,\"authentication_method\":\"none\"},{\"name\":\"host\",\"address\":\"0.0.0.0\",\"port\":${RP_PORT_KAFKA_FUNCTION},\"authentication_method\":\"sasl\"},{\"name\":\"docker\",\"address\":\"0.0.0.0\",\"port\":${RP_PORT_KAFKA_DOCKER},\"authentication_method\":\"sasl\"}]" \
      --set schema_registry.schema_registry_api="[{\"name\":\"internal\",\"address\":\"0.0.0.0\",\"port\":8081},{\"name\":\"external\",\"address\":\"0.0.0.0\",\"port\":${RP_PORT_SCHEMA},\"authentication_method\":\"http_basic\"}]" \
      --set redpanda.admin="[{\"name\":\"internal\",\"address\":\"0.0.0.0\",\"port\":9644},{\"name\":\"external\",\"address\":\"0.0.0.0\",\"port\":${RP_PORT_ADMIN}}]" &

    # 2. Wait for Redpanda (Internal Admin API on 9644)
    echo "Waiting for Redpanda to be ready..."
    until rpk cluster health --api-urls localhost:9644 >/dev/null 2>&1; do
      echo -n "."
      sleep 2
    done
    echo

    # 3. Create User
    echo "Creating admin user..."
    rpk acl user create ${RP_ADMIN_USER} -p ${RP_ADMIN_PASS} --mechanism SCRAM-SHA-256 --api-urls localhost:9644

    echo "Configuring ACLs..."
    rpk security acl create --allow-principal ${RP_ADMIN_USER} --operation all --topic "*" --group "*"

    echo "Redpanda setup complete inside container. Keeping container running."
    # Keep container running
    wait
'

# Build the producer image
echo "Building td-redpanda-flights-producer image..."
docker build -t redpanda-flights-producer-image -f "${PRODUCER_DIR}/Dockerfile" "${PRODUCER_DIR}"

# Start the producer
echo "Starting td-redpanda-flights-producer container..."
docker run -d --rm --name td-redpanda-flights-producer \
  redpanda-flights-producer-image \
  python events_producer.py \
    --broker "${RP_HOST_DOCKER}:${RP_PORT_KAFKA_DOCKER}" \
    --user "${RP_ADMIN_USER}" \
    --password "${RP_ADMIN_PASS}"

echo
echo ">>> Redpanda instance created (function): ${RP_HOST_FUNCTION}:${RP_PORT_KAFKA_FUNCTION}"
echo ">>> Redpanda instance created (docker): ${RP_HOST_DOCKER}:${RP_PORT_KAFKA_DOCKER}"
echo ">>> Schema Registry: ${RP_HOST_DOCKER}:${RP_PORT_SCHEMA}"
echo ">>> Admin API: ${RP_HOST_DOCKER}:${RP_PORT_ADMIN}"
echo ">>> Admin user: ${RP_ADMIN_USER} password: ${RP_ADMIN_PASS}"
echo ">>> Event producer is running in a separate container: td-redpanda-flights-producer"
echo

docker rm -f td-redpanda-console 2>/dev/null

docker run -d --rm --name td-redpanda-console -p 8080:8080 \
  -e CONSOLE_CONFIG_FILE="
kafka:
  brokers: [\"${RP_HOST_DOCKER}:${RP_PORT_KAFKA_DOCKER}\"]
  sasl:
    enabled: true
    mechanism: SCRAM-SHA-256
    username: \"${RP_ADMIN_USER}\"
    password: \"${RP_ADMIN_PASS}\"
" \
  -e CONFIG_FILEPATH=/tmp/config.yml \
  --entrypoint /bin/sh \
  redpandadata/console:latest \
  -c 'echo "$CONSOLE_CONFIG_FILE" > /tmp/config.yml && /app/console -config.filepath=/tmp/config.yml'
