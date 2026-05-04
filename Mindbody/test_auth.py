import os

import requests

API_KEY = os.environ["MINDBODY_API_KEY"]
SITE_ID = os.environ["MINDBODY_STUDIO_ID"]
USERNAME = os.environ["MINDBODY_USERNAME"]
PASSWORD = os.environ["MINDBODY_PASSWORD"]

BASE_URL = "https://api.mindbodyonline.com/public/v6"

headers = {
    "Api-Key": API_KEY,
    "SiteId": SITE_ID,
    "Content-Type": "application/json",
}

print(f"API_KEY: {API_KEY}")
print(f"SITE_ID: {SITE_ID}")
print(f"USERNAME: {USERNAME}")
print()

# Try v6 format with Request wrapper
print("--- Attempt 1: Request wrapper ---")
body = {
    "Request": {
        "Username": USERNAME,
        "Password": PASSWORD,
        "ISPProgramIds": [],
    }
}
resp = requests.post(f"{BASE_URL}/usertoken/issue", headers=headers, json=body)
print(f"Status: {resp.status_code}")
print(f"Body: {resp.text}")
print()

# Try flat format (no wrapper)
print("--- Attempt 2: Flat body ---")
body2 = {
    "Username": USERNAME,
    "Password": PASSWORD,
}
resp2 = requests.post(f"{BASE_URL}/usertoken/issue", headers=headers, json=body2)
print(f"Status: {resp2.status_code}")
print(f"Body: {resp2.text}")
print()

# Try with SiteIds array in body
print("--- Attempt 3: SiteIds in body ---")
body3 = {
    "Request": {
        "Username": USERNAME,
        "Password": PASSWORD,
        "ISPProgramIds": [],
        "SiteIds": [int(SITE_ID)],
    }
}
resp3 = requests.post(f"{BASE_URL}/usertoken/issue", headers=headers, json=body3)
print(f"Status: {resp3.status_code}")
print(f"Body: {resp3.text}")
