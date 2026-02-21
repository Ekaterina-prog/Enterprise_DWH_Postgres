CREATE TABLE report.sales_film_by_date (
	film_title varchar(255) NOT NULL,
	amount numeric(7, 2) NOT null,
	date_actual date not null
);

CREATE OR REPLACE PROCEDURE report.sales_film_by_date_calc()
 LANGUAGE plpgsql
AS $procedure$
	begin 
		delete from report.sales_film_by_date;
	
		INSERT INTO report.sales_film_by_date
		(
			film_title, 
			amount,
			date_actual
		)
		select
			di.title as film_title,
			sum(p.amount) as amount,
			dd.date_actual as date_actual
		from
			core.fact_payment p
			join core.dim_inventory di 
				on p.inventory_fk = di.inventory_pk 
			join core.dim_date  dd
				on dd.date_dim_pk = p.payment_date_fk
		group by
			di.title,
			dd.date_actual;
	end;
$procedure$
;

call report.sales_film_by_date_calc();