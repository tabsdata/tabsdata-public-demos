# Tabsdata Airport Demo

## Quickstart (Beginner Friendly)

## 1. Requirements

- Docker Desktop (or Docker Engine) installed and running
- `git`
- Python 3.12+
- `pip`
- Internet access to pull Docker images and Python packages

If `git` is missing on macOS:

```bash
xcode-select --install
# or, if Homebrew is installed:
brew install git
```

If `git` is missing on Linux:

```bash
sudo dnf install -y git || sudo yum install -y git
```

If Docker is missing on Linux:

```bash
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
sudo usermod -aG docker "$USER"
newgrp docker
docker --version
docker ps
```

If `dnf` is unavailable, use the equivalent `yum` packages/repo flow for your distro.

Then log out and back in (or use `newgrp docker`) before running setup scripts in a new session.

If you want Docker to auto-start on reboot:

```bash
sudo systemctl enable docker
```

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
