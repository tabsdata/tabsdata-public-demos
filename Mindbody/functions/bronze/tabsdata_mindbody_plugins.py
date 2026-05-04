import json

import polars as pl
import requests
import tabsdata as td

BASE_URL = "https://api.mindbodyonline.com/public/v6"


def flatten(record, prefix=""):
    result = {}
    for k, v in record.items():
        key = f"{prefix}__{k}" if prefix else k
        if isinstance(v, dict):
            result.update(flatten(v, key))
        elif isinstance(v, list):
            result[key] = json.dumps(v)
        else:
            result[key] = v
    return result


def paginate(url, headers, extract, params=None):
    offset = 0
    while True:
        resp = requests.get(
            url,
            headers=headers,
            params={"limit": 200, "offset": offset, **(params or {})},
        )
        if resp.status_code != 200:
            break
        data = resp.json()
        batch = extract(data)
        if not batch:
            break
        yield from batch
        offset += 200
        if offset >= data.get("PaginationResponse", {}).get("TotalResults", 0):
            break


class MindbodyBase(td.SourcePlugin):
    def __init__(self, api_key: str, site_id: str, username: str, password: str):
        self.api_key = api_key
        self.site_id = site_id
        self.username = username
        self.password = password

    def _get_token(self) -> str:
        resp = requests.post(
            f"{BASE_URL}/usertoken/issue",
            headers={"Api-Key": self.api_key, "SiteId": self.site_id},
            json={"Username": self.username, "Password": self.password},
        )
        resp.raise_for_status()
        return resp.json()["AccessToken"]

    def _auth_headers(self, token: str) -> dict:
        return {"Api-Key": self.api_key, "SiteId": self.site_id, "Authorization": f"Bearer {token}"}


class MindbodyCollectionSource(MindbodyBase):
    def __init__(self, api_key, site_id, username, password, endpoint, extra_params=None):
        super().__init__(api_key, site_id, username, password)
        self.endpoint = endpoint
        self.extra_params = extra_params or {}

    def chunk(self, working_dir: str) -> str:
        token = self._get_token()
        headers = self._auth_headers(token)

        records = []
        offset = 0

        while True:
            resp = requests.get(
                f"{BASE_URL}{self.endpoint}",
                headers=headers,
                params={"limit": 200, "offset": offset, **self.extra_params},
            )
            if resp.status_code != 200:
                break
            data = resp.json()
            batch = next((v for v in data.values() if isinstance(v, list)), [])
            if not batch:
                break
            records.extend(batch)
            offset += 200
            if offset >= data.get("PaginationResponse", {}).get("TotalResults", 0):
                break

        flat = [flatten(r) for r in records]
        df = pl.from_dicts(flat, infer_schema_length=None) if flat else pl.DataFrame()

        path = f"{working_dir}/data.parquet"
        df.write_parquet(path)
        return path


class MindbodySalesSource(MindbodyBase):
    def chunk(self, working_dir: str) -> str:
        headers = self._auth_headers(self._get_token())

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
        path = f"{working_dir}/data.parquet"
        df.write_parquet(path)
        return path
