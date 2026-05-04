import os
import sys

sys.path.insert(0, os.path.dirname(__file__))

import tabsdata as td
from tabsdata_mindbody_plugins import MindbodyCollectionSource

MINDBODY_API_KEY = td.EnvironmentSecret("MINDBODY_API_KEY")
MINDBODY_STUDIO_ID = td.EnvironmentSecret("MINDBODY_STUDIO_ID")
MINDBODY_USERNAME = td.EnvironmentSecret("MINDBODY_USERNAME")
MINDBODY_PASSWORD = td.EnvironmentSecret("MINDBODY_PASSWORD")


@td.publisher(
    source=MindbodyCollectionSource(
        api_key=MINDBODY_API_KEY.secret_value,
        site_id=MINDBODY_STUDIO_ID.secret_value,
        username=MINDBODY_USERNAME.secret_value,
        password=MINDBODY_PASSWORD.secret_value,
        endpoint="/site/locations",
    ),
    tables=["locations_raw"],
)
def locations_pub(tf: td.TableFrame) -> td.TableFrame:
    return tf
