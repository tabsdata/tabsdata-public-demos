# Mindbody → Tabsdata Demo

This demo ingests data from the **Mindbody Public API v6** into Tabsdata, processes it through a bronze → silver → gold pipeline, and mirrors all tables to **PostgreSQL** via a subscriber.

## Data Pipeline

```
Mindbody Public API v6
  ├── /site/locations       → bronze/locations_bronze
  ├── /class/classes        → bronze/classes_bronze
  ├── /client/clients       → bronze/clients_bronze
  ├── /sale/services        → bronze/services_bronze
  ├── /sale/products        → bronze/products_bronze
  ├── /staff/staff          → bronze/staff_bronze
  ├── /class/classvisits    → bronze/visits_bronze    (transformer, reads classes)
  └── /sale/sales           → bronze/purchases_bronze
          │
          ▼ (silver transformers — field selection & cleanup)
  ├── silver/locations_silver
  ├── silver/classes_silver
  ├── silver/clients_silver
  ├── silver/services_silver
  ├── silver/products_silver
  ├── silver/staff_silver
  ├── silver/visits_silver
  └── silver/purchases_silver
          │
          ▼ (gold transformer — joins & aggregation)
  └── gold/client_activity_gold
          │
          ▼ (postgres subscriber)
  PostgreSQL — all 17 tables
```

## Tables Produced

### Bronze
Raw data from the Mindbody API with no modifications.

| Table | Source Endpoint | Description |
|---|---|---|
| `locations_bronze` | `/site/locations` | Studio locations |
| `classes_bronze` | `/class/classes` | Scheduled classes |
| `clients_bronze` | `/client/clients` | Client profiles |
| `services_bronze` | `/sale/services` | Pricing plans and passes |
| `products_bronze` | `/sale/products` | Retail products |
| `staff_bronze` | `/staff/staff` | Staff members |
| `visits_bronze` | `/class/classvisits` | Per-class visit records |
| `purchases_bronze` | `/sale/sales` | Purchase transactions (one row per line item) |

### Silver
Cleaned bronze tables with irrelevant, null, and sensitive fields removed.

| Table | Description |
|---|---|
| `locations_silver` | Core location fields |
| `classes_silver` | Class schedule with program and level info |
| `clients_silver` | Client identity, contact, address, status, and communication preferences |
| `services_silver` | Service/pass definitions with pricing and expiration |
| `products_silver` | Product catalog with pricing and categorization |
| `staff_silver` | Staff identity, contact, and role flags |
| `visits_silver` | Visit records with service and program details |
| `purchases_silver` | Sale header + line item fields with pricing and tax |

### Gold
Aggregated analytics tables built from silver.

| Table | Description |
|---|---|
| `client_activity_gold` | One row per client: `num_classes`, `num_visits`, `num_purchases`, `total_purchase_amount` — clients with zero activity across all three are excluded |

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

### 2. Create and activate a conda environment

```bash
conda create -y --name tabsdata_official python=3.12
conda activate tabsdata_official
pip install -r requirements.txt
pip install tabsdata
```

### 3. Configure credentials

Edit [source.sh](./source.sh) and fill in your Mindbody and PostgreSQL credentials:

```bash
# Mindbody API
export MINDBODY_API_KEY=your_api_key_here
export MINDBODY_STUDIO_ID=your_studio_id_here
export MINDBODY_USERNAME=your_staff_username
export MINDBODY_PASSWORD=your_staff_password

# PostgreSQL (defaults work for the Docker container spun up by setup)
export PG_HOST=localhost
export PG_PORT=5432
export PG_DATABASE=mindbody
export PG_USER=postgres
export PG_PASSWORD=postgres
```

#### Getting Mindbody credentials

| Variable | How to obtain |
|---|---|
| `MINDBODY_API_KEY` | Create a developer account at [developers.mindbodyonline.com](https://developers.mindbodyonline.com/ui/documentation/public-api#/http/mindbody-public-api-v6-0/introduction/creating-a-mindbody-developer-account). Log in, go to the account dropdown in the top right, click **API Credentials**, and create an API key. |
| `MINDBODY_STUDIO_ID` | Found in the [Mindbody sandbox portal](https://developers.mindbodyonline.com/ui/onboarding/use-sandbox).   |
| `MINDBODY_USERNAME` | Found in the [Mindbody sandbox portal](https://developers.mindbodyonline.com/ui/onboarding/use-sandbox). For a live studio, use the login email of a staff member with **Owner** or **Manager** role. |
| `MINDBODY_PASSWORD` | Found in the [Mindbody sandbox portal](https://developers.mindbodyonline.com/ui/onboarding/use-sandbox). For a live studio, use the password for the staff member above. |

> **Sandbox:** Mindbody provides a free sandbox site pre-loaded with test data. The sandbox credentials (`MINDBODY_STUDIO_ID=-99`, `MINDBODY_USERNAME=?`, `MINDBODY_PASSWORD=?`) are already set in `source.sh` so the demo works out of the box without a live site.

### 4. Load credentials into your shell

```bash
source ./source.sh
```

### 5. Run full setup

```bash
bash scripts/setup_all.sh
```

This runs three steps in sequence:

1. **Preflight** — checks that `td`, `tdserver`, `docker`, and `python3` are installed and installs Python dependencies
2. **PostgreSQL** — starts a `postgres:16` Docker container named `td-mindbody-postgres`
3. **Tabsdata** — creates a fresh Tabsdata instance, creates collections (`bronze`, `silver`, `gold`, `subscribers`), sets cross-collection permissions, registers all functions, and triggers the bronze publishers

> To run steps individually: `bash scripts/preflight.sh`, `bash scripts/setup_postgres.sh`, `bash scripts/setup_tabsdata.sh`

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
│   └── subscribers/     # PostgreSQL subscriber (all 17 tables)
├── scripts/
│   ├── setup_all.sh     # Full setup (preflight + postgres + tabsdata)
│   ├── preflight.sh     # Dependency checks
│   ├── setup_postgres.sh
│   ├── setup_tabsdata.sh
│   └── stop_all.sh
├── source.sh            # Environment variables
└── requirements.txt
```

## Notes

- **Visits ingest** fetches visits per class ID. For studios with many classes this can take several minutes.
- Cross-collection access requires **bidirectional** permissions. The setup script grants all required directions automatically.
- For production secret management, see the [Tabsdata HashiCorp Vault integration](https://docs.tabsdata.com/latest/guide/secrets_management/hashicorp/main.html).
