-- Процедуры загрузки данных в core слой
-- Реализована полная перезапись (full reload)

create or replace procedure core.load_inventory()
as $$
	begin 
		-- помечаем удаленные записи
		update core.dim_inventory i
		set
			is_active = false,
			effective_date_to = si.deleted
		from 
			staging.inventory si
		where 
			si.deleted is not null
			and i.inventory_id = si.inventory_id
			and i.is_active is true;

		-- получаем список идентификаторов новых компакт дисков
		create temporary table new_inventory_id_list on commit drop as -- удаление автоматически
		select
			i.inventory_id
		from 
			staging.inventory i
			left join core.dim_inventory di using(inventory_id)
		where 
			di.inventory_id is null;

		-- добавляем новые компакт диски в измерение dim_inventory
		insert
			into
			core.dim_inventory
		(
			inventory_id,
			film_id,
			title,
			rental_duration,
			rental_rate,
			length,
			rating,
			effective_date_from,
			effective_date_to,
			is_active
		)
		select
			i.inventory_id,
			i.film_id,
			f.title,
			f.rental_duration,
			f.rental_rate,
			f.length,
			f.rating,
			'1900-01-01'::date as effective_date_from ,
			coalesce(i.deleted, '9999-01-01'::date) as effective_date_to,
			true as is_active
		from
			staging.inventory i
			join staging.film f using(film_id)
			join new_inventory_id_list idl using(inventory_id);

		-- помечаем изменные компакт диски не активными
		update core.dim_inventory i
		set 
			is_active = false,
			effective_date_to = si.last_update
		from 
			staging.inventory si
			left join new_inventory_id_list idl using(inventory_id)
		where 
			idl.inventory_id is null
			and si.deleted is null
			and i.inventory_id = si.inventory_id
			and i.is_active is true;
		
		-- по измененым компакт дискам добавляем актуальные строки
		insert
			into
			core.dim_inventory
		(
			inventory_id,
			film_id,
			title,
			rental_duration,
			rental_rate,
			length,
			rating,
			effective_date_from,
			effective_date_to,
			is_active
		)
		select
			i.inventory_id,
			i.film_id,
			f.title,
			f.rental_duration,
			f.rental_rate,
			f.length,
			f.rating,
			i.last_update as effective_date_from,
			'9999-01-01'::date as effective_date_to,
			true as is_active 
		from
			staging.inventory i
			join staging.film f using(film_id)
			left join new_inventory_id_list idl using(inventory_id)
		where 
			idl.inventory_id is null
			and i.deleted is null;
	end;
$$ language plpgsql;

create or replace procedure core.load_staff()
as $$
	begin 
		delete from core.dim_staff;
	
		insert into core.dim_staff
		(
			staff_id,
			first_name,
			last_name,
			address,
			district,
			city_name
		)
		select
			s.staff_id,
			s.first_name,
			s.last_name,
			a.address,
			a.district,
			c.city 
		from
			staging.staff s
			join staging.store st using (store_id)
			join staging.address a using (address_id)
			join staging.city c using (city_id);
	end;
$$ language plpgsql;

create or replace procedure core.load_payment()
as $$
	begin
		delete from core.fact_payment;
	
		insert into core.fact_payment
		(
			payment_id,
			amount,
			payment_date_fk,
			inventory_fk,
			staff_fk
		)
		select
			p.payment_id,
			p.amount,
			dt.date_dim_pk as payment_date_fk,
			di.inventory_pk as inventory_fk,
			ds.staff_pk as staff_fk
		from
			staging.payment p
			join staging.rental r using (rental_id)
			join core.dim_inventory di 
				on r.inventory_id = di.inventory_id
				and p.payment_date between di.effective_date_from and di.effective_date_to 
			join core.dim_staff ds on p.staff_id = ds.staff_id
			join core.dim_date dt on dt.date_actual = p.payment_date::date;

	end;
$$ language plpgsql;

create or replace procedure core.load_rental()
as $$
	begin 
		delete from core.fact_rental;
	
		insert into core.fact_rental
		(
			rental_id,
			inventory_fk,
			staff_fk,
			rental_date_fk,
			return_date_fk,
			amount,
			cnt
		)
		select
			r.rental_id,
			i.inventory_pk as inventory_fk,
			s.staff_pk as staff_fk,
			dt_rental.date_dim_pk as rental_date_fk,
			dt_return.date_dim_pk as return_date_fk,
			sum(p.amount) as amount,
			count(*) as cnt
		from
			staging.rental r
			join core.dim_inventory i 
				on r.inventory_id = i.inventory_id 
				and r.rental_date between i.effective_date_from and i.effective_date_to 
			join core.dim_staff s on s.staff_id = r.staff_id
			join core.dim_date dt_rental on dt_rental.date_actual = r.rental_date::date
			left join staging.payment p using (rental_id)
			left join core.dim_date dt_return on dt_return.date_actual = r.return_date::date
		group by
			r.rental_id,
			i.inventory_pk,
			s.staff_pk,
			dt_rental.date_dim_pk,
			dt_return.date_dim_pk;

	end
$$ language plpgsql;


create or replace procedure core.fact_delete()
as $$
	begin
		delete from core.fact_payment;
		delete from core.fact_rental;
	end
$$ language plpgsql;

-- создание data mart слоя

drop table if exists report.sales_date;

create table report.sales_date (
	date_title varchar(20) not null,
	amount numeric(7,2) not null,
	date_sort integer not null
);

drop table if exists report.sales_film;

create table report.sales_film (
	film_title varchar(255) not null,
	amount numeric(7,2) not null 
);


create or replace procedure report.sales_date_calc()
as $$
	begin 
		delete from report.sales_date;
	
		insert
			into
			report.sales_date
		(
			date_title, --'1 сентября 2022'
			amount,
			date_sort
		)
		select
			dt.day_of_month || ' ' || dt.month_name || ' ' || dt.year_actual as date_title,
			sum(fp.amount) as amount,
			dt.date_dim_pk as date_sort
		from
			core.fact_payment fp
			join core.dim_date dt
				on	 fp.payment_date_fk = dt.date_dim_pk
		group by
			dt.day_of_month || ' ' || dt.month_name || ' ' || dt.year_actual,
			dt.date_dim_pk;

	end
$$ language plpgsql;

create or replace procedure report.sales_film_calc()
as $$
	begin 
		delete from report.sales_film;
	
		INSERT INTO report.sales_film
		(
			film_title, 
			amount
		)
		select
			di.title as film_title,
			sum(p.amount) as amount
		from
			core.fact_payment p
			join core.dim_inventory di 
				on p.inventory_fk = di.inventory_pk 
		group by
			di.title;
	end;
$$ language plpgsql;


