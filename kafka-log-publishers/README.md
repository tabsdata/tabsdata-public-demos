# Tabsdata Airport Demo

## Quickstart (Beginner Friendly)

## 1. Requirements

- Docker Desktop (or Docker Engine) installed and running
- Python 3.12+
- `pip`
- Internet access to pull Docker images and Python packages

## 2. Clone the repo

```bash
git clone <REPO_URL>
cd tabsdata-airport-demo/tabsdata-demo-daniel
```

If you already cloned the repo, just `cd` into:

```bash
cd /path/to/tabsdata-airport-demo/tabsdata-demo-daniel
```

## 3. Create and activate a virtual environment

```bash
python3 -m venv .venv
source .venv/bin/activate
```

## 4. Install Python dependencies

```bash
pip install 'tabsdata[all]' --upgrade 
pip install mysql-connector-python
```

## 5. Verify Docker is running

```bash
docker ps
```

If this fails, start Docker Desktop and run `docker ps` again.

## 6. Run the demo setup

From `tabsdata-demo-daniel`:

```bash
./setup-tabsdata.sh
```

## 7. What setup does

- Starts Vault (HashiCorp) and writes demo secrets
- Starts MySQL and recreates:
  - `airportdb` (loads `flights` table)
  - `td_processed_data`
- Starts log producer and Redpanda producer containers
- Starts Tabsdata server
- Registers publisher/subscriber functions

## Folder Layout

- `scripts/`: setup and orchestration scripts
- `pipelines/sql/`: SQL ingestion publisher/subscriber functions
- `pipelines/log-publisher/`: log ingestion functions
- `pipelines/kafka/`: Kafka ingestion functions
- `producers/log/`: log producer Docker assets
- `producers/kafka/`: Kafka producer Docker assets
- `data/sql/`: SQL seed files (for MySQL setup)
- `data/td-logs/`: generated log files

## Notes

- `setup-tabsdata.sh` is kept as a compatibility wrapper.
- MySQL setup recreates both schemas on each run: `airportdb` and `td_processed_data`.
