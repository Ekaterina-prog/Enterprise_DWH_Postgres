-- процедуры наполнения слоя витрин

create or replace procedure report.fill_calendar(sdate date, nm integer)
as $$
	begin
		set lc_time = 'ru_RU';
		
		insert into report.calendar
		select
			TO_CHAR(datum, 'yyyymmdd')::INT as date_id,
			datum as date_actual,
			extract(day from datum) as day_of_month,
			TO_CHAR(datum, 'TMMonth') as month_name,
			extract(year from datum) as year_actual
		from
			(
			select
				sdate + SEQUENCE.DAY as datum
			from
				GENERATE_SERIES(0, nm - 1) as sequence (day)
			order by
				SEQUENCE.day) DQ
		order by
			1;
	end;
$$ language plpgsql;

create or replace procedure report.sales_by_date_calc() 
as $$
	begin
		delete from report.sales_by_date;
	
		INSERT INTO report.sales_by_date
		(
			sales_date_rn, 
			sales_date_title, 
			amount
		)
		select
			c.date_id as sales_date_rn,
			concat(c.day_of_month, ' ', c.month_name, ' ', c."year") as sales_date_title,
			sum(p.amount) as amount
		from
			dds.payment p
			join report.calendar c
				on p.payment_date::date = c.date_actual
		where 
			p.deleted is null
		group by 
			c.date_id,
			concat(c.day_of_month, ' ', c.month_name, ' ', c."year");
	end;
$$ language plpgsql;

create or replace function sales_by_date() returns table(sales_date_rn int, sales_date_title varchar, amount float)
as $$
	select
		sales_date_rn,
		sales_date_title,
		amount
	from
		report.sales_by_date;
$$ language sql;
