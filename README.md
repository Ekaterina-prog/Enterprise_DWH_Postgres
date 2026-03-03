Comparison of DWH Architectures: Kimball, Inmon, Data Vault

Customer

Educational project (self-developed).
The goal was not only to build data marts, but to practically compare three approaches to enterprise data warehouse design.

Project Overview

Three DWH architectures were implemented in PostgreSQL:
- Kimball — Star Schema
- Inmon — 3NF + centralized warehouse + DDS
- Data Vault 2.0 — Raw Vault (hubs, links, satellites)

The same data source is organized in different ways to compare:
- model flexibility
- scalability
- analytical usability
- development and maintenance complexity

Data Source
Educational database dvdrental
(movies, rentals, payments, customers)

Tech Stack
- PostgreSQL
- SQL / PLpgSQL
- DBeaver
- FDW
- Power BI
- Git

Implemented Tasks
Kimball
- staging layer with incremental loading
- fact tables (rental, payment)
 -dimensions with SCD Type 2
- sales data marts
- BI dashboard

Inmon
- layers: staging → ODS → REF → integration (3NF) → DDS
- historization via hash control
- data marts built on top of centralized warehouse

Data Vault 2.0
- Hubs (business keys)
- Links (relationships)
- Satellites (attributes + historization)
- hash keys (MD5)
- insert-only logic

Key Findings
Kimball – Fast, BI-friendly analytics, but rigid structure.
Inmon – Centralized, no redundancy, but complex to build.
Data Vault – Highly flexible and scalable, but requires strict discipline.

Key Findings
- Kimball – Fast, BI-friendly analytics, but rigid structure.
- Inmon – Centralized, no redundancy, but complex to build.
- Data Vault – Highly flexible and scalable, but requires strict discipline.

How to Run
git clone https://github.com/Ekaterina-prog/Enterprise_DWH_Postgres.git

Configure FDW connection and execute loading scripts inside the selected architecture folder.

Repository Structure
01_Kimball/
02_Inmon/
03_Data_Vault/
04_Anchor_Modeling/
README.md



