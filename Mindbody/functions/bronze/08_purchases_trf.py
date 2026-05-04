import os
import sys

sys.path.insert(0, os.path.dirname(__file__))

import polars as pl
import requests
import tabsdata as td
from tabsdata_mindbody_plugins import flatten, paginate

MINDBODY_API_KEY = td.EnvironmentSecret("MINDBODY_API_KEY")
MINDBODY_STUDIO_ID = td.EnvironmentSecret("MINDBODY_STUDIO_ID")
MINDBODY_USERNAME = td.EnvironmentSecret("MINDBODY_USERNAME")
MINDBODY_PASSWORD = td.EnvironmentSecret("MINDBODY_PASSWORD")

BASE_URL = "https://api.mindbodyonline.com/public/v6"


@td.transformer(
    input_tables=["clients"],
    output_tables=["purchases"],
)
def purchases_trf(clients: td.TableFrame) -> td.TableFrame:
    api_key = MINDBODY_API_KEY.secret_value
    site_id = MINDBODY_STUDIO_ID.secret_value

    token = requests.post(
        f"{BASE_URL}/usertoken/issue",
        headers={"Api-Key": api_key, "SiteId": site_id},
        json={
            "Username": MINDBODY_USERNAME.secret_value,
            "Password": MINDBODY_PASSWORD.secret_value,
        },
    ).json()["AccessToken"]

    headers = {
        "Api-Key": api_key,
        "SiteId": site_id,
        "Authorization": f"Bearer {token}",
    }

    rows = []
    for sale in paginate(
        f"{BASE_URL}/sale/sales", headers, lambda d: d.get("Sales", [])
    ):
        sale_flat = flatten(
            {k: v for k, v in sale.items() if k != "PurchasedItems"}, "sale"
        )
        for item in sale.get("PurchasedItems", []):
            rows.append({**sale_flat, **flatten(item, "item")})

    df = pl.from_dicts(rows, infer_schema_length=None) if rows else pl.DataFrame()

    return td.TableFrame.from_polars(df)
