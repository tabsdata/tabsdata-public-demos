#
# Copyright 2026 Tabs Data Inc.
#

import json
import os
import random
import time
import argparse
import logging
from kafka import KafkaProducer

# --- Configuration ---
RP_HOST = os.getenv("RP_HOST", "localhost")
RP_PORT_KAFKA = int(os.getenv("RP_PORT_KAFKA", "9092"))
DEFAULT_BROKER = f"{RP_HOST}:{RP_PORT_KAFKA}"

RP_ADMIN_USER = os.getenv("RP_ADMIN_USER", "admin")
RP_ADMIN_PASS = os.getenv("RP_ADMIN_PASS", "secret")

DEFAULT_TOPIC = "flight_events"
FLIGHT_COUNT = 500
PUBLISH_INTERVAL_SECONDS = 0.5

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("flight-producer")

# --- Flight Data Simulation ---
AIRLINES = ["AA", "UA", "DL", "SW", "B6"]
STATUSES = ["ON TIME", "DELAYED", "CANCELLED", "BOARDING", "IN FLIGHT", "LANDED"]
GATES = [f"A{i}" for i in range(1, 15)] + [f"B{i}" for i in range(1, 15)]

def create_random_flight(flight_id):
    """Generates a single random flight status update."""
    return {
        "flight_id": flight_id,
        "flight_number": f"{random.choice(AIRLINES)}{random.randint(100, 9999)}",
        "status": random.choice(STATUSES),
        "gate": random.choice(GATES),
        "updated_at": time.strftime('%Y-%m-%d %H:%M:%S')
    }

# --- Kafka Callback Functions ---
def on_send_success(record_metadata):
    """Callback for successful message sends."""
    log.info(f"Message sent successfully to topic '{record_metadata.topic}' partition {record_metadata.partition} at offset {record_metadata.offset}")

def on_send_error(ex):
    """Callback for failed message sends."""
    log.error("Error sending message", exc_info=ex)

def main(broker, topic, user, password):
    """Continuously produces random flight status updates to a Kafka topic."""
    log.info(f"Connecting to Kafka broker at {broker}...")
    try:
        producer = KafkaProducer(
            bootstrap_servers=[broker],
            value_serializer=lambda v: json.dumps(v).encode('utf-8'),
            # --- Use SCRAM-SHA-256 for Redpanda ---
            security_protocol="SASL_PLAINTEXT",
            sasl_mechanism="SCRAM-SHA-256",
            sasl_plain_username=user,
            sasl_plain_password=password,
            # --- End of auth settings ---
            retries=5,
            reconnect_backoff_ms=1000
        )
        log.info("Successfully connected to Kafka.")
    except Exception as e:
        log.error(f"Could not connect to Kafka broker at {broker}", exc_info=e)
        return

    flight_ids = list(range(1, FLIGHT_COUNT + 1))
    log.info(f"Starting to publish flight status updates to topic '{topic}'. Press Ctrl+C to stop.")

    try:
        while True:
            flight_to_update = random.choice(flight_ids)
            message = create_random_flight(flight_to_update)

            log.info(f"Publishing: {message}")
            producer.send(topic, value=message).add_callback(on_send_success).add_errback(on_send_error)
            producer.flush()
            time.sleep(PUBLISH_INTERVAL_SECONDS)

    except KeyboardInterrupt:
        log.info("\nStopping producer.")
    finally:
        log.info("Flushing final messages...")
        producer.flush()
        producer.close()
        log.info("Producer closed.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Flight Status Data Producer for Kafka.")
    parser.add_argument("--broker", default=DEFAULT_BROKER, help=f"Kafka broker address (default: {DEFAULT_BROKER})")
    parser.add_argument("--topic", default=DEFAULT_TOPIC, help=f"Kafka topic name (default: {DEFAULT_TOPIC})")
    parser.add_argument("--user", default=RP_ADMIN_USER, help=f"SASL username (default: {RP_ADMIN_USER})")
    parser.add_argument("--password", default=RP_ADMIN_PASS, help=f"SASL password (default: {RP_ADMIN_PASS})")
    args = parser.parse_args()
    main(args.broker, args.topic, args.user, args.password)
