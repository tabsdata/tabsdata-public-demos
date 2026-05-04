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
    input_tables=["classes_bronze"],
    output_tables=["visits_bronze"],
)
def visits_trf(classes: td.TableFrame) -> td.TableFrame:
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
    class_ids = classes.to_polars_df()["Id"].cast(str).to_list()

    rows = []
    for class_id in class_ids:
        for v in paginate(
            f"{BASE_URL}/class/classvisits",
            headers,
            lambda d: d.get("Class", {}).get("Visits", []),
            {"classId": class_id},
        ):
            rows.append(flatten(v))

    df = pl.from_dicts(rows, infer_schema_length=None) if rows else pl.DataFrame()

    return td.TableFrame.from_polars(df)
