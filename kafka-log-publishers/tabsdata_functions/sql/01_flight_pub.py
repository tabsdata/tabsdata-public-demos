#  Copyright 2025. Tabs Data Inc.
#
import os
from typing import Tuple

import tabsdata as td
import tabsdata.tableframe as tdf

DB_HOST = os.getenv("MYSQL_HOST", "localhost")
DB_PORT = int(os.getenv("MYSQL_PORT", "3307"))
DB_DATABASE = os.getenv("MYSQL_DATABASE", "airportdb")

user = td.HashiCorpSecret("mysql", "user")
password = td.HashiCorpSecret("mysql", "password")


@td.publisher(
    source=td.MySQLSource(
        uri=f"mysql://{DB_HOST}:{DB_PORT}/{DB_DATABASE}",
        query="SELECT * FROM flight WHERE flight_id > :flight_id ORDER BY flight_id LIMIT 10000",
        credentials=td.UserPasswordCredentials(user, password),
        initial_values={"flight_id": 0},
    ),
    tables="flights",
)
def flight_pub(booking: tdf.TableFrame) -> Tuple[tdf.TableFrame | None, dict | str]:
    if booking:
        flight_id = booking.select(td.col("flight_id").max()).item()
        return booking, {"flight_id": flight_id}
    else:
        return None, "SAME"
