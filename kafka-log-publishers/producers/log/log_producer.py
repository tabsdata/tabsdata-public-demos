import logging
import os
import random
import time
import uuid
from datetime import datetime, timezone
from logging.handlers import TimedRotatingFileHandler

LOG_DIR = "/logs"
BASE_FILENAME = "web_airline.log"

BACKUP_COUNT = 10
ROTATE_EVERY_SECONDS = 30

LINES_PER_SECOND = 5
SLEEP_SECONDS = 1.0 / LINES_PER_SECOND

PATHS = [
    "/",
    "/home",
    "/flights/search",
    "/flights/results",
    "/flights/details",
    "/flights/seatmap",
    "/checkout",
    "/checkout/passengers",
    "/checkout/payment",
    "/booking/confirm",
]
REFERRERS = [
    "/",
    "/home",
    "/flights/search",
    "/flights/results",
    "/flights/details",
]
USER_AGENTS = [
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/121.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/121.0.0.0 Safari/537.36",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_2 like Mac OS X) AppleWebKit/605.1.15 Version/17.2 Mobile/15E148 Safari/604.1",
]
EVENT_TYPES = ["VIEW", "CLICK", "SEARCH", "DETAILS", "CHECKOUT_START"]


def iso_utc_now():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"


def ensure_dir(p):
    os.makedirs(p, exist_ok=True)


def random_passenger_id():
    return random.randint(1, 30000)


def format_line():
    ts = iso_utc_now()
    event_id = str(uuid.uuid4())
    et = random.choice(EVENT_TYPES)
    passenger_id = random_passenger_id()
    path = random.choice(PATHS)
    ref = random.choice(REFERRERS)
    ua = random.choice(USER_AGENTS)
    return f'{ts} event_id={event_id} type={et} passenger_id={passenger_id} path={path} referrer={ref} user_agent="{ua}"'


def main():
    ensure_dir(LOG_DIR)
    logfile = os.path.join(LOG_DIR, BASE_FILENAME)

    logger = logging.getLogger("web-airline-loggen")
    logger.setLevel(logging.INFO)
    logger.handlers.clear()

    handler = TimedRotatingFileHandler(
        logfile,
        when="S",
        interval=ROTATE_EVERY_SECONDS,
        backupCount=BACKUP_COUNT,
        encoding="utf-8",
    )
    handler.setFormatter(logging.Formatter("%(message)s"))
    logger.addHandler(handler)

    while True:
        logger.info(format_line())
        time.sleep(SLEEP_SECONDS)


if __name__ == "__main__":
    main()
