from typing import List
import tabsdata as td
import os


USERNAME = td.EnvironmentSecret("AWS_ACCESS_KEY_ID")
PASSWORD = td.EnvironmentSecret("AWS_SECRET_ACCESS_KEY")
AWS_REGION = td.EnvironmentSecret("AWS_REGION")
AWS_BUCKET = td.EnvironmentSecret("AWS_BUCKET")

s3_credentials = td.S3AccessKeyCredentials(USERNAME,PASSWORD)




@td.publisher(
    source=td.S3Source(
        [
            f"{AWS_BUCKET.secret_value}/tabsdata/customers.csv",
        ],
        s3_credentials,
        region = f"{AWS_REGION.secret_value}",
    ),
    tables=["customers_raw"],
)

def s3_pub(tf: td.TableFrame):
    return tf