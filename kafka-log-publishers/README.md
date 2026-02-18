# Tabsdata Airport Demo

## Quickstart (Beginner Friendly)

## 1. Requirements

- Docker Desktop (or Docker Engine) installed and running
- `git`
- Python 3.12+


## 2. Clone the repo

```bash
git clone https://github.com/tabsdata/tabsdata-public-demos.git
cd tabsdata-public-demos/kafka-log-publishers
```

If you already cloned the repo, just `cd` into:

```bash
cd /path/to/tabsdata-public-demos/kafka-log-publishers
```

## 3. Create and activate a virtual environment

```bash
python3.12 -m venv tabsdata-venv
```

```bash
source tabsdata-venv/bin/activate
```
OR use conda/pyenv/etc.

## 4. Install Python dependencies

```bash
pip install 'tabsdata[all]' --upgrade 
pip install mysql-connector-python
```

## 5. Verify Docker is running

```bash
docker ps
```

## 6. Run the demo setup

From `kafka-log-publishers`:

```bash
./setup-tabsdata.sh
```

If you are running on a remote EC2 host and want local browser access, open SSH tunnels from your laptop:

```bash
# Tabsdata UI -> http://localhost:2457
ssh -i ~/td-redhat.pem -N -L 2457:127.0.0.1:2457 ec2-user@ec2-3-143-248-77.us-east-2.compute.amazonaws.com
```

```bash
# Redpanda Console -> http://localhost:8080
ssh -i ~/td-redhat.pem -N -L 8080:127.0.0.1:8080 ec2-user@ec2-3-143-248-77.us-east-2.compute.amazonaws.com
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
