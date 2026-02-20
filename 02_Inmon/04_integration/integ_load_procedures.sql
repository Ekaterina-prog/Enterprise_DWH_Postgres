-- создание процедур integ слоя

create or replace procedure integ.film_load()
as $$
	begin
		delete from integ.film;
	
		insert into integ.film
		(
			film_id,
			title,
			description,
			release_year,
			language_id,
			rental_duration,
			rental_rate,
			length,
			replacement_cost,
			rating,
			last_update,
			special_features,
			fulltext
		)
		select
			rf.film_sk as film_id,
			title,
			description,
			release_year,
			language_id,
			rental_duration,
			rental_rate,
			length,
			replacement_cost,
			rating,
			last_update,
			special_features,
			fulltext
		from
			ods.film f
			join ref.film rf
				on f.film_id = rf.film_nk;
	end;
$$ language plpgsql;

create or replace procedure integ.inventory_load()
as $$
	begin
		delete from integ.inventory;
	
		insert into integ.inventory
		(
			inventory_id,
			film_id,
			store_id,
			last_update,
			deleted
		)
		select
			ri.inventory_sk as inventory_id,
			rf.film_sk as film_id,
			rs.store_sk  as store_id,
			last_update,
			deleted
		from
			ods.inventory i
			join ref.inventory ri
				on i.inventory_id = ri.inventory_nk
			join ref.film rf
				on rf.film_nk = i.film_id
			join ref.store rs
				on rs.store_nk = i.store_id ;
	end;
$$ language plpgsql;

create or replace procedure integ.rental_load()
as $$
	declare
		last_update_dt timestamp;
	begin
		-- дата и время последней измененной записи, загруженной в предыдущий раз
		last_update_dt = (
			select
				coalesce(max(r.last_update), '1900-01-01'::date)
			from
				integ.rental r
		);
	
		-- идентификаторы всех созданных, измененных или удаленных фактов сдачи в аренду с предыдущей загрузки из ods в integ
		create temporary table updated_integ_rent_id_list on commit drop as 
		select
			r.rental_id 
		from
			ods.rental r 
		where
			r.last_update > last_update_dt;
		
		-- удаляем из integ слоя все созданные, измененные или удаленные факты сдачи в аренду с предыдущей загрузки из ods в integ
		delete from integ.rental r
		where
			r.rental_id in (
				select
					rental_id
				from
					updated_integ_rent_id_list
			);
		
		-- вставляем в integ слой все созданные, измененные или удаленные факты сдачи в аренду с предыдущей загрузки из ods в integ
		insert into integ.rental
		(
			rental_id,
			rental_date,
			inventory_id,
			return_date,
			staff_id,
			last_update,
			deleted
		)
		select
			rr.rental_sk as rental_id,
			rental_date,
			ri.inventory_sk as inventory_id,
			return_date,
			rs.staff_sk as staff_id,
			last_update,
			deleted
		from 
			ods.rental r
			join ref.rental rr
				on r.rental_id = rr.rental_nk 
			join updated_integ_rent_id_list upd
				on upd.rental_id = r.rental_id
			join ref.inventory ri
				on ri.inventory_nk = r.inventory_id
			join ref.staff rs
				on rs.staff_nk = r.staff_id;
	end;
$$ language plpgsql;

create or replace procedure integ.address_load()
 as $$
 	begin
		delete from integ.address;
	
		insert into	integ.address
		(
			address_id,
			address,
			address2,
			district,
			city_id,
			postal_code,
			phone,
			last_update
		)
		select 
			ra.address_sk as address_id,
			address,
			address2,
			district,
			rc.city_sk as city_id,
			postal_code,
			phone,
			last_update
		from
			ods.address a
			join ref.address ra
				on a.address_id = ra.address_nk 
			join ref.city rc
				on a.city_id = rc.city_nk ;
	end;
$$ language plpgsql;

create or replace procedure integ.city_load()
 as $$
 	begin
		delete from integ.city;
	
		insert into	integ.city
		(
			city_id,
			city,
			last_update
		)
		select 
			rc.city_sk as city_id,
			city,
			last_update
		from
			ods.city c
			join ref.city rc
				on c.city_id = rc.city_nk;
	end;
$$ language plpgsql;

create or replace procedure integ.staff_load()
 as $$
 	begin
		delete from integ.staff;
	
		insert into	integ.staff
		(
			staff_id,
			first_name,
			last_name,
			address_id,
			email,
			store_id,
			active,
			username,
			last_update,
			picture,
			deleted
		)
		select 
			rs.staff_sk as staff_id,
			first_name,
			last_name,
			ra.address_sk as address_id,
			email,
			rst.store_sk as store_id,
			active,
			username,
			last_update,
			picture,
			deleted
		from
			ods.staff s
			join ref.staff rs
				on s.staff_id = rs.staff_nk 
			join ref.address ra
				on s.address_id = ra.address_nk
			join ref.store rst
				on s.store_id = rst.store_nk;
	end;
$$ language plpgsql;

create or replace procedure integ.store_load()
 as $$
 	begin
		delete from integ.store;
	
		insert into	integ.store
		(
			store_id,
			manager_staff_id,
			address_id,
			last_update
		)
		select 
			rs.store_sk as store_id,
			rms.staff_sk as manager_staff_id,
			address_id,
			last_update
		from
			ods.store s
			join ref.store rs
				on s.store_id = rs.store_nk
			join ref.staff rms
				on s.manager_staff_id = rms.staff_nk;
	end;
$$ language plpgsql;

create or replace procedure integ.payment_load()
as $$
	declare
		last_update_dt timestamp;
	begin
		-- дата и время последней измененной записи, загруженной в предыдущий раз
		last_update_dt = (
			select
				coalesce(max(p.last_update), '1900-01-01'::date)
			from
				integ.payment p
		);
	
		-- идентификаторы всех созданных, измененных или удаленных платежей с предыдущей загрузки из ods в integ
		create temporary table updated_integ_paym_id_list on commit drop as 
		select
			p.payment_id 
		from
			ods.payment p  
		where
			p.last_update > last_update_dt;
		
		-- удаляем из integ слоя все созданные, измененные или удаленные платежи с предыдущей загрузки из ods в integ
		delete from integ.payment p
		where
			p.payment_id in (
				select
					payment_id
				from
					updated_integ_paym_id_list
			);
		
		-- вставляем в integ слой все созданные, измененные или удаленные платежи с предыдущей загрузки из ods в integ
		insert into integ.payment
		(
			payment_id,
			staff_id,
			rental_id,
			amount,
			payment_date,
			last_update,
			deleted
		)
		select 
			rp.payment_sk as payment_id,
			rs.staff_sk as staff_id,
			rr.rental_sk as rental_id,
			amount,
			payment_date,
			last_update,
			deleted
		from
			ods.payment p
			join updated_integ_paym_id_list upd
				on upd.payment_id = p.payment_id
			join ref.payment rp
				on p.payment_id = rp.payment_nk 
			join ref.staff rs
				on p.staff_id = rs.staff_nk
			join ref.rental rr
				on p.rental_id = rr.rental_nk;
			
	end;
$$ language plpgsql;