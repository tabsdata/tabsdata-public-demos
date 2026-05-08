# Mindbody → Tabsdata Demo

This demo ingests data from the **Mindbody Public API v6** into Tabsdata, processes it through a bronze → silver → gold pipeline, and mirrors all tables to **PostgreSQL** via a subscriber.

> **Platform:** While Windows is supported by Tabsdata, this workflow is designed for **macOS** with a **bash/zsh** shell.

## Data Pipeline

```
API Endpoint              Bronze                 Silver                  Gold                  Destination

/site/locations        → locations_bronze     → locations_silver   ─────────────────────────→ PostgreSQL
/class/classes         → classes_bronze       → classes_silver     ─────────────────────────→ PostgreSQL
/client/clients        → clients_bronze       → clients_silver     ──┐ ──────────────────────→ PostgreSQL
/sale/services         → services_bronze      → services_silver    │ ─────────────────────────→ PostgreSQL
/sale/products         → products_bronze      → products_silver    │ ─────────────────────────→ PostgreSQL
/staff/staff           → staff_bronze         → staff_silver       │ ─────────────────────────→ PostgreSQL
classes_bronze +       → visits_bronze        → visits_silver      ├→ client_activity_gold ──→ PostgreSQL
  /class/classvisits                                                │
/sale/sales            → purchases_bronze     → purchases_silver   ──┘ ──────────────────────→ PostgreSQL
```

## Tables Produced

### Bronze
Raw data from the Mindbody API with no modifications.

| Function | Input Type | Input Data | Output Table | Description |
|---|---|---|---|---|
| `locations_pub` | API Endpoint | `/site/locations` | `locations_bronze` | Studio locations |
| `classes_pub` | API Endpoint | `/class/classes` | `classes_bronze` | Scheduled classes |
| `clients_pub` | API Endpoint | `/client/clients` | `clients_bronze` | Client profiles |
| `services_pub` | API Endpoint | `/sale/services` | `services_bronze` | Pricing plans and passes |
| `products_pub` | API Endpoint | `/sale/products` | `products_bronze` | Retail products |
| `staff_pub` | API Endpoint | `/staff/staff` | `staff_bronze` | Staff members |
| `visits_trf` | Table + API Endpoint | `classes_bronze` / `/class/classvisits` | `visits_bronze` | Per-class visit records |
| `purchases_pub` | API Endpoint | `/sale/sales` | `purchases_bronze` | Purchase transactions (one row per line item) |

### Silver
Cleaned bronze tables with irrelevant, null, and sensitive fields removed.

| Function | Input Type | Input Data | Output Table | Description |
|---|---|---|---|---|
| `locations_silver_trf` | Table | `locations_bronze` | `locations_silver` | Core location fields |
| `classes_silver_trf` | Table | `classes_bronze` | `classes_silver` | Class schedule with program and level info |
| `clients_silver_trf` | Table | `clients_bronze` | `clients_silver` | Client identity, contact, address, status, and communication preferences |
| `services_silver_trf` | Table | `services_bronze` | `services_silver` | Service/pass definitions with pricing and expiration |
| `products_silver_trf` | Table | `products_bronze` | `products_silver` | Product catalog with pricing and categorization |
| `staff_silver_trf` | Table | `staff_bronze` | `staff_silver` | Staff identity, contact, and role flags |
| `visits_silver_trf` | Table | `visits_bronze` | `visits_silver` | Visit records with service and program details |
| `purchases_silver_trf` | Table | `purchases_bronze` | `purchases_silver` | Sale header + line item fields with pricing and tax |

### Gold
Aggregated analytics tables built from silver.

| Function | Input Type | Input Data | Output Table | Description |
|---|---|---|---|---|
| `client_activity_gold_trf` | Table | `clients_silver`, `visits_silver`, `purchases_silver` | `client_activity_gold` | One row per client: `num_visits`, `num_purchases`, `total_purchase_amount` — zero-activity clients excluded |

## Requirements

- Python 3.12+
- `tabsdata` CLI (`td` and `tdserver` commands available)
- Docker Desktop (for PostgreSQL)

## Setup

### 1. Clone the repo

```bash
git clone https://github.com/tabsdata/tabsdata-public-demos.git
cd tabsdata-public-demos/Mindbody
```

### 2. Create and activate a virtual environment

You can use any method you prefer (venv, conda, pyenv, etc.), but **Python 3.12 is required**. Using the standard library:

```bash
python3 -m venv mindbody_venv
source mindbody_venv/bin/activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
pip install 'tabsdata[all]'
```

### 4. Configure credentials

Edit [source.sh](./source.sh) and fill in your Mindbody and PostgreSQL credentials:

```bash
# PostgreSQL (defaults work for the Docker container spun up by setup)
export PG_HOST=localhost
export PG_PORT=5432
export PG_DATABASE=mindbody
export PG_USER=postgres
export PG_PASSWORD=postgres

# Mindbody API credentials
export MINDBODY_API_KEY=?
export MINDBODY_STUDIO_ID=?
export MINDBODY_USERNAME=?
export MINDBODY_PASSWORD=?
```

#### Getting Mindbody credentials

| Variable | How to obtain |
|---|---|
| `MINDBODY_API_KEY` | Create a developer account at [developers.mindbodyonline.com](https://developers.mindbodyonline.com/ui/documentation/public-api#/http/mindbody-public-api-v6-0/introduction/creating-a-mindbody-developer-account). Log in, go to the account dropdown in the top right, click **API Credentials**, and create an API key. |
| `MINDBODY_STUDIO_ID` | Found in the [Mindbody sandbox portal](https://developers.mindbodyonline.com/ui/onboarding/use-sandbox).   |
| `MINDBODY_USERNAME` | Found in the [Mindbody sandbox portal](https://developers.mindbodyonline.com/ui/onboarding/use-sandbox). |
| `MINDBODY_PASSWORD` | Found in the [Mindbody sandbox portal](https://developers.mindbodyonline.com/ui/onboarding/use-sandbox). |

### 5. Load credentials into your shell

```bash
source ./source.sh
```

### 6. Confirm Docker is running

```bash
docker ps
```

If Docker is not running, start Docker Desktop before proceeding.

### 7. Run full setup

```bash
bash scripts/setup_all.sh
```

This runs three steps in sequence:

1. **Preflight** — checks that `td`, `tdserver`, `docker`, and `python3` are installed and installs Python dependencies
2. **PostgreSQL** — starts a `postgres:16` Docker container named `td-mindbody-postgres`
3. **Tabsdata** — creates a fresh Tabsdata instance, creates collections (`bronze`, `silver`, `gold`, `subscribers`), sets cross-collection permissions, registers all functions, and triggers the bronze publishers

> To run steps individually: `bash scripts/preflight.sh`, `bash scripts/setup_postgres.sh`, `bash scripts/setup_tabsdata.sh`

### 8. Log in to Tabsdata

```bash
td login --server localhost --user admin --role sys_admin --password tabsdata
```

## Tabsdata UI

Open [http://localhost:2457](http://localhost:2457) and sign in with:

| Field | Value |
|---|---|
| User | `admin` |
| Password | `tabsdata` |
| Role | `sys_admin` |

## Sampling Results

```bash
# Bronze
td table sample --coll bronze --name clients_bronze
td table sample --coll bronze --name visits_bronze

# Silver
td table sample --coll silver --name clients_silver
td table sample --coll silver --name visits_silver

# Gold
td table sample --coll gold --name client_activity_gold
```

## Folder Layout

```
Mindbody/
├── functions/
│   ├── bronze/          # Publishers and visit transformer (raw ingest)
│   ├── silver/          # Field-selection transformers (one per entity)
│   ├── gold/            # Aggregation transformers
│   └── subscribers/     # PostgreSQL subscriber (8 silver + 1 gold)
├── scripts/
│   ├── setup_all.sh     # Full setup (preflight + postgres + tabsdata)
│   ├── preflight.sh     # Dependency checks
│   ├── setup_postgres.sh
│   ├── setup_tabsdata.sh
│   └── stop_all.sh
├── source.sh            # Environment variables
└── requirements.txt
```

## Stopping the Tabsdata Server and Postgres Docker Container

```bash
bash scripts/stop_all.sh
```

This stops the Tabsdata server and removes the `td-mindbody-postgres` Docker container. You will be prompted whether to also delete the Tabsdata instance — choose No to stop services while preserving data.
