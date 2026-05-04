import os

import tabsdata as td

PG_HOST = os.getenv("PG_HOST", "localhost")
PG_PORT = os.getenv("PG_PORT", "5432")
PG_DATABASE = os.getenv("PG_DATABASE", "mindbody")

PG_USER = td.EnvironmentSecret("PG_USER")
PG_PASSWORD = td.EnvironmentSecret("PG_PASSWORD")

INPUT_TABLES = [
    "bronze/locations_bronze",
    "bronze/classes_bronze",
    "bronze/clients_bronze",
    "bronze/services_bronze",
    "bronze/products_bronze",
    "bronze/staff_bronze",
    "bronze/visits_bronze",
    "bronze/purchases_bronze",
    "silver/locations_silver",
    "silver/classes_silver",
    "silver/clients_silver",
    "silver/services_silver",
    "silver/products_silver",
    "silver/staff_silver",
    "silver/visits_silver",
    "silver/purchases_silver",
    "gold/client_activity_gold",
]

DEST_TABLES = [
    "locations_bronze",
    "classes_bronze",
    "clients_bronze",
    "services_bronze",
    "products_bronze",
    "staff_bronze",
    "visits_bronze",
    "purchases_bronze",
    "locations_silver",
    "classes_silver",
    "clients_silver",
    "services_silver",
    "products_silver",
    "staff_silver",
    "visits_silver",
    "purchases_silver",
    "client_activity_gold",
]


@td.subscriber(
    tables=INPUT_TABLES,
    destination=td.PostgresDest(
        conn=td.PostgresConn(
            uri=f"postgresql://{PG_HOST}:{PG_PORT}/{PG_DATABASE}",
            credentials=td.UserPasswordCredentials(PG_USER, PG_PASSWORD),
        ),
        destination_tables=DEST_TABLES,
        if_table_exists="replace",
    ),
    trigger_by=[],
)
def postgres_sub(
    locations_bronze: td.TableFrame,
    classes_bronze: td.TableFrame,
    clients_bronze: td.TableFrame,
    services_bronze: td.TableFrame,
    products_bronze: td.TableFrame,
    staff_bronze: td.TableFrame,
    visits_bronze: td.TableFrame,
    purchases_bronze: td.TableFrame,
    locations_silver: td.TableFrame,
    classes_silver: td.TableFrame,
    clients_silver: td.TableFrame,
    services_silver: td.TableFrame,
    products_silver: td.TableFrame,
    staff_silver: td.TableFrame,
    visits_silver: td.TableFrame,
    purchases_silver: td.TableFrame,
    client_activity_gold: td.TableFrame,
) -> tuple:
    return (
        locations_bronze,
        classes_bronze,
        clients_bronze,
        services_bronze,
        products_bronze,
        staff_bronze,
        visits_bronze,
        purchases_bronze,
        locations_silver,
        classes_silver,
        clients_silver,
        services_silver,
        products_silver,
        staff_silver,
        visits_silver,
        purchases_silver,
        client_activity_gold,
    )
