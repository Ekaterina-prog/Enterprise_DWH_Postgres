Power BI Dashboards – Kimball DWH Project

Overview
This project includes two analytical dashboards built on top of the Kimball-based Data Warehouse.
The model follows a Star Schema architecture with fact and dimension tables in the core layer and dedicated reporting data marts in the report layer.

1. Core Sales Analytics Dashboard
Built directly on top of the core layer (fact and dimension tables).

Data Sources:
- core.fact_payment
- core.fact_rental
- core.dim_inventory
- core.dim_date
- core.dim_staff

Key Features:
- Date range filter (calendar dimension)
- Film selection checkboxes
- Address and rating filters

Line chart:
- Total Sales Amount
- Rental Count (rental_pk)
- Aggregated by Year

Pie chart:
- Total Sales Amount by Staff (first_name)
- This dashboard demonstrates analytical modeling using properly defined foreign key relationships in a Star Schema.

2. Daily Film Sales Performance (Report Layer)

Built on top of a dedicated reporting data mart:
- report.sales_film_by_date

Data Mart Structure:
- film_title
- amount
- date_actual

The data mart is populated via stored procedure:
- report.sales_film_by_date_calc()

Key Visualizations:
Date range slider (e.g., 14.02.2007 – 14.05.2007)
Matrix: Daily sales by date
Matrix: Film list with aggregated sales
Total sales for selected period
Total sales: 61,316.03

This dashboard demonstrates the transition from a normalized analytical model to a business-ready reporting layer optimized for BI tools.
Architecture Summary

The project implements:
- Kimball Star Schema (core layer)
- Aggregated reporting data marts (report layer)
- End-to-end BI visualization in Power BI

Pipeline:
Source → Staging → Core (Star Schema) → Report (Data Mart) → Power BI