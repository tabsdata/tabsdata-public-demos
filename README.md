# Tabsdata Public Demos

This repo contains demos for different kinds of Tabsdata workflows. Each demo is a self-contained pipeline you can run locally as a starting point for your own integrations.

## Demos

### [Mindbody → PostgreSQL](./Mindbody)

Ingests data from the **Mindbody Public API v6** through a bronze → silver → gold medallion pipeline and mirrors all tables to **PostgreSQL** via a subscriber.

- 8 bronze publishers/transformers (locations, classes, clients, services, products, staff, visits, purchases)
- 8 silver transformers (field cleanup)
- 1 gold transformer (client activity aggregation)
- 1 PostgreSQL subscriber

### [S3 → Databricks](./S3_to_Databricks)

Pulls CSV data out of S3, creates a secondary transformed table, and subscribes both tables into Databricks.

### [Kafka / Airport Demo](./kafka-log-publishers)

Simulates an airport data pipeline using Kafka (Redpanda) and MySQL. Ingests flight data from a MySQL `airportdb` database and log streams from a Kafka producer, then subscribes the results back out. Includes a demo video.