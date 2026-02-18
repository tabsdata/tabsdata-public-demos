from pathlib import Path

import tabsdata as td
import tabsdata.tableframe as tdf
from tabsdata import LogFormat

LOG_GLOB = str(
    Path(__file__).resolve().parents[2] / "data" / "td-logs" / "td-web_airline.log.*"
)

air_web_pattern = (
    r"%{TIMESTAMP_ISO8601:timestamp} "
    r"event_id=%{UUID:event_id} "
    r"type=%{WORD:type} "
    r"passenger_id=%{INT:passenger_id} "
    r"path=%{URIPATHPARAM:path} "
    r"referrer=%{URIPATHPARAM:referrer} "
    r'user_agent="%{DATA:user_agent}"'
)

air_web_schema = {
    "timestamp": tdf.Column("timestamp", td.String),
    "event_id": tdf.Column("event_id", td.String),
    "type": tdf.Column("event_type", td.String),
    "passenger_id": tdf.Column("passenger_id", td.Int32),
    "path": tdf.Column("path", td.String),
    "referrer": tdf.Column("referrer", td.String),
    "user_agent": tdf.Column("user_agent", td.String),
}


@td.publisher(
    trigger_by=td.CronTrigger("* * * * *"),
    source=td.LocalFileSource(
        path=[LOG_GLOB],
        format=LogFormat(),
        initial_last_modified="2025-01-01T00:00:00Z",
    ),
    tables=["air_web_page_views"],
)
def publish_air_web_page_views(air_web: list[tdf.TableFrame]):
    return (
        td.concat(air_web).grok("message", air_web_pattern, air_web_schema)
        if air_web
        else td.TableFrame.empty()
    )
