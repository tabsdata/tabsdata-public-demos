#
# Copyright 2026 Tabs Data Inc.
#

import json
import os
import uuid

import tabsdata as td

RP_HOST = os.getenv("RP_HOST_FUNCTION", "localhost")
RP_PORT_KAFKA = int(os.getenv("RP_PORT_KAFKA_FUNCTION", "19092"))

user = td.HashiCorpSecret("redpanda", "user")
password = td.HashiCorpSecret("redpanda", "password")

schema = {
    "title": "Status",
    "description": "Flight status update",
    "type": "object",
    "properties": {
        "flight_id": {"description": "The flight ID", "type": "number"},
        "flight_number": {"description": "The flight number", "type": "string"},
        "status": {"description": "The flight status", "type": "string"},
        "gate": {"description": "The flight gate", "type": "string"},
        "updated_at": {"description": "The status update time", "type": "string"},
    },
    "required": ["flight_id", "flight_number", "status", "gate", "updated_at"],
}


@td.publisher(
    source=td.Stage(use_existing_data=True),
    tables="flight_events",
    trigger_by=td.KafkaTrigger(
        conn=td.KafkaConn(
            servers=f"{RP_HOST}:{RP_PORT_KAFKA}",
            credentials=td.UserPasswordCredentials(user, password),
            group_id=str(uuid.uuid4()),
        ),
        topic="flight_events",
        data_format="json",
        schema=json.dumps(schema),
        time_rollover_secs=30,
    ),
)
def flight_event_publisher(tfs: list[td.TableFrame]) -> td.TableFrame:
    return td.concat(tfs) if tfs else td.TableFrame.empty()
