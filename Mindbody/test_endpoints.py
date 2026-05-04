import json
import os

import requests

API_KEY = os.environ["MINDBODY_API_KEY"]
SITE_ID = os.environ["MINDBODY_STUDIO_ID"]
USERNAME = os.environ["MINDBODY_USERNAME"]
PASSWORD = os.environ["MINDBODY_PASSWORD"]

BASE_URL = "https://api.mindbodyonline.com/public/v6"

token = requests.post(
    f"{BASE_URL}/usertoken/issue",
    headers={"Api-Key": API_KEY, "SiteId": SITE_ID},
    json={"Username": USERNAME, "Password": PASSWORD},
).json()["AccessToken"]

headers = {"Api-Key": API_KEY, "SiteId": SITE_ID, "Authorization": f"Bearer {token}"}

# --- /sale/sales (no clientId) ---
print("--- GET /sale/sales (no clientId, limit=3) ---")
r = requests.get(
    f"{BASE_URL}/sale/sales",
    headers=headers,
    params={"limit": 3, "offset": 0},
)
print(f"Status: {r.status_code}")
print(json.dumps(r.json(), indent=2, default=str))
print()

# --- /class/classvisits (pick first class from /class/classes) ---
print("--- GET /class/classes (limit=1) ---")
r = requests.get(
    f"{BASE_URL}/class/classes",
    headers=headers,
    params={"limit": 1, "offset": 0},
)
print(f"Status: {r.status_code}")
classes = r.json().get("Classes", [])
# print(json.dumps(r.json(), indent=2, default=str))
# print()

if classes:
    class_id = classes[0].get("Id")
    print(f"--- GET /class/classvisits?classId={class_id} ---")
    r = requests.get(
        f"{BASE_URL}/class/classvisits",
        headers=headers,
        params={"classId": class_id, "limit": 3, "offset": 0},
    )
    print(f"Status: {r.status_code}")
    print(json.dumps(r.json(), indent=2, default=str))
