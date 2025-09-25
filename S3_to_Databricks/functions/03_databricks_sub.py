import tabsdata as td
import os

DATABRICKS_HOST_URL = td.EnvironmentSecret("DATABRICKS_HOST_URL")
DATABRICKS_TOKEN = td.EnvironmentSecret("DATABRICKS_TOKEN")
VOLUME = td.EnvironmentSecret("VOLUME")
CATALOG = td.EnvironmentSecret("CATALOG")
SCHEMA = td.EnvironmentSecret("SCHEMA")
WAREHOUSE = td.EnvironmentSecret("WAREHOUSE")

@td.subscriber(
    tables=["customers_processed", "customers_raw"],
    destination=td.DatabricksDestination(
        host_url = DATABRICKS_HOST_URL.secret_value,
        token = DATABRICKS_TOKEN.secret_value,
        tables = ["customers_processed", "customers_raw"],
        volume = VOLUME.secret_value,
        catalog = CATALOG.secret_value,
        schema = SCHEMA.secret_value,
        warehouse = WAREHOUSE.secret_value,
        if_table_exists = "replace",
        schema_strategy = "update"
    )
)

def databricks_sub(tf1: td.TableFrame, tf2: td.TableFrame):
    return tf1, tf2
