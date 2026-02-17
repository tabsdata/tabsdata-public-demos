#
#  Copyright 2025. Tabs Data Inc.
#
#
import os

import tabsdata as td

DB_HOST = os.getenv("MYSQL_HOST", "localhost")
DB_PORT = int(os.getenv("MYSQL_PORT", "3307"))
DB_DATABASE = os.getenv("MYSQL_DATABASE", "td_processed_data")

user = td.HashiCorpSecret("mysql", "user")
password = td.HashiCorpSecret("mysql", "password")


@td.subscriber(
    tables="flights",
    destination=td.MySQLDestination(
        uri=f"mysql://{DB_HOST}:{DB_PORT}/{DB_DATABASE}",
        destination_table="processed_flights",
        credentials=td.UserPasswordCredentials(user, password),
        if_table_exists="replace",
    ),
)
def mysql_sub(tf):
    return tf
