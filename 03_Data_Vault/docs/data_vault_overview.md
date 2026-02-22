Data Vault 2.0 – Raw Vault Implementation

The project implements the Data Vault 2.0 model for the dvdrental training base.

The architecture includes:
Hubs – business entities (film, rental, payment, inventory, staff, store, address, city)
Links – links between hubs
Satellites – attributes and historicity

Technical features:
Hash Keys Are Used
Incremental loading is supported
Historicity is implemented via LoadDate / LoadEndDate
RecordSource and HashDiff are used.

Attributes are divided by frequency of changes

The Raw Vault layer is designed as a stable model that minimally depends on changes in the source.