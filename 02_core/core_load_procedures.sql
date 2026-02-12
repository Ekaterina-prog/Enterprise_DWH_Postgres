-- Процедуры загрузки данных в core слой
-- Реализована полная перезапись (full reload)

create or replace procedure core.load_core_inventory()
as $$
	begin
		delete from core.dim_inventory;

		insert into core.dim_inventory
		(
			inventory_id, 
			film_id, 
			title, 
			rental_duration, 
			rental_rate, 
			length, 
			rating
		)
		select
			i.inventory_id,
			i.film_id,
			f.title,
			f.rental_duration,
			f.rental_rate,
			f.length,
			f.rating
		from 
			staging.inventory i
			join staging.film f using(film_id);
	end;
$$ language plpgsql;

create or replace procedure core.load_core_staff()
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
			join staging.store st using(store_id)
			join staging.address a using(address_id)
			join staging.city c using(city_id);
	end;
$$ language plpgsql;

create or replace procedure core.load_core_payment()
as $$
	begin
		delete from core.fact_payment;

		insert into core.fact_payment
		(
			payment_id,
			amount, 
			payment_date, 
			inventory_fk, 
			staff_fk
		)
		select
			p.payment_id,
			p.amount,
			p.payment_date::date as payment_date,
			di.inventory_pk as inventory_fk,
			ds.staff_pk as staff_fk
		from 
			staging.payment p
			join staging.rental r using(rental_id)
			join core.dim_inventory di using(inventory_id)
			join core.dim_staff ds on p.staff_id = ds.staff_id;
	end;
$$ language plpgsql;

create or replace procedure core.load_core_rental()
as $$
	begin 
		delete from core.fact_rental;

		insert into core.fact_rental
		(
			rental_id,
			inventory_fk, 
			staff_fk, 
			rental_date, 	
			return_date, 
			amount,
			cnt
		)
		select
			r.rental_id,
			i.inventory_pk as inventory_fk,
			s.staff_pk as staff_fk,
			r.rental_date::date as rental_date,
			r.return_date::date as return_date,
			sum(p.amount) as amount,
			count(*) as cnt
		from
			staging.rental r
			join core.dim_inventory i using(inventory_id)
			join core.dim_staff s on s.staff_id = r.staff_id
			left join staging.payment p using(rental_id)
		group by 
			r.rental_id,
			i.inventory_pk,
			s.staff_pk,
			r.rental_date::date,
			r.return_date::date;
	end;
$$ language plpgsql;

create or replace procedure core.fact_delete()
as $$
	begin
		delete from core.fact_payment;
		delete from core.fact_rental;
	end;
$$ language plpgsql;

