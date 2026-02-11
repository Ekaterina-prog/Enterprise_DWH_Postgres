# Data Warehouse Implementation (Kimball) — PostgreSQL

## Project Overview

This project demonstrates a practical implementation of a Data Warehouse using the Kimball methodology in PostgreSQL.

The goal is to design and build a layered DWH architecture starting from source system integration up to analytical data marts.

Source system: `dvdrental` (PostgreSQL sample dataset).

---

## Architecture

### 1. Source Layer

- PostgreSQL database: `dvdrental`
- Integration method: `postgres_fdw`
- Foreign tables imported into a dedicated schema

### 2. Staging Layer

- Separate PostgreSQL database for DWH
- Schema: `staging`
- Full reload strategy
- Data loading implemented via PL/pgSQL stored procedures

Implemented staging tables:

- film
- inventory
- rental
- payment

### 3. Core Layer (In Progress)

- Star schema (fact + dimensions)
- Dimensional modeling according to Kimball
- Planned implementation of Slowly Changing Dimensions (SCD Type 2)

### 4. Datamarts (Planned)

- Analytical views for reporting

---

## Technologies Used

- PostgreSQL
- PL/pgSQL
- postgres_fdw
- Git

---

## Current Status

- Source connection configured via postgres_fdw
- Staging layer implemented with full reload procedures
- Core layer design in progress

---

## How to Run

1. Clone repository:
   ```bash
   git clone https://github.com/Ekaterina-prog/DWH_Kimball_Postgres.git
   ```
