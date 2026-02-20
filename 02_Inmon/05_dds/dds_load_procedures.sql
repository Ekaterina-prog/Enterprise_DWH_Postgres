-- создание процедур dds слоя

create or replace procedure dds.film_load()
as $$
	begin
		-- список id новых фильмов
		create temporary table film_new_id_list on commit drop as
		select
			rf.film_sk as film_id
		from
			ref.film rf
			left join dds.film f
				on rf.film_sk = f.film_id
		where 
			f.film_id is null;
		
		-- вставляем новые фильмы
		INSERT INTO dds.film
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
			special_features,
			fulltext,
			date_effective_from,
			date_effective_to,
			is_active,
			hash
		)
		select
			f.film_id,
			title,
			description,
			release_year,
			language_id,
			rental_duration,
			rental_rate,
			length,
			replacement_cost,
			rating,
			special_features,
			fulltext,
			'1900-01-01'::date as date_effective_from,
			'9999-01-01'::date as date_effective_to,
			true as is_active,
		
			md5(f::text) as hash
			
		from
			integ.film f
			join film_new_id_list nf
				on f.film_id = nf.film_id;
			
		-- id удаленных фильмов
		create temporary table film_deleted_id_list on commit drop as
		select 
			f.film_id
		from
			dds.film f 
			left join integ.film inf
				on f.film_id = inf.film_id 
		where 
			inf.film_id is null;
		
		-- помечаем удаленные фильмы
		update dds.film f
		set 
			is_active = false,
			date_effective_to = now()
		from 
			film_deleted_id_list fd
		where
			fd.film_id = f.film_id 
			and f.is_active is true;
		
		-- находим id измененных фильмов
		create temporary table film_update_id_list on commit drop as
		select
			inf.film_id 
		from
			dds.film f 
			join integ.film inf
				on f.film_id = inf.film_id 
		where
			f.is_active is true
			and f.hash <> md5(inf::text);
		
		-- помечаем неактуальными предущие строки по измененным фильмам
		update dds.film f
		set
			is_active = false,
			date_effective_to = inf.last_update 
		from
			integ.film inf
			join film_update_id_list upf
				on upf.film_id = inf.film_id
		where 
			inf.film_id = f.film_id
			and f.is_active is true;
		
		-- добавляем новые строки по измененным фильмам
		INSERT INTO dds.film
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
			special_features,
			fulltext,
			date_effective_from,
			date_effective_to,
			is_active,
			hash
		)
		select
			f.film_id,
			title,
			description,
			release_year,
			language_id,
			rental_duration,
			rental_rate,
			length,
			replacement_cost,
			rating,
			special_features,
			fulltext,
			last_update as date_effective_from,
			'9999-01-01'::date as date_effective_to,
			true as is_active,
		
			md5(f::text) as hash
			
		from
			integ.film f
			join film_update_id_list upf
				on f.film_id = upf.film_id;
	end;
$$ language plpgsql;

create or replace procedure dds.inventory_load()
as $$
	begin
		-- список id новых компакт дисков
		create temporary table inventory_new_id_list on commit drop as
		select
			ri.inventory_sk as inventory_id
		from
			ref.inventory ri
			left join dds.inventory i
				on ri.inventory_sk = i.inventory_id
		where 
			i.inventory_id is null;
		
		-- вставляем новые компакт диски
		INSERT INTO dds.inventory
		(
			inventory_id,
			film_id,
			store_id,
			
			date_effective_from,
			date_effective_to,
			is_active,
			
			hash
		)
		select
			i.inventory_id,
			film_id,
			store_id,
			'1900-01-01'::date as date_effective_from,
			'9999-01-01'::date as date_effective_to,
			true as is_active,
		
			md5(i::text) as hash
			
		from
			integ.inventory i
			join inventory_new_id_list ni
				on i.inventory_id = ni.inventory_id;
			

		-- id удаленных компакт дисков
		create temporary table inventory_deleted_id_list on commit drop as
		select 
			i.inventory_id,
			ini.deleted 
		from
			dds.inventory i 
			left join integ.inventory ini
				on i.inventory_id = ini.inventory_id 
		where 
			ini.inventory_id is null;
		
		-- помечаем удаленные компакт диски
		update dds.inventory i
		set 
			is_active = false,
			date_effective_to = id.deleted
		from 
			inventory_deleted_id_list id
		where
			id.inventory_id = i.inventory_id 
			and i.is_active is true;
		
		-- находим id измененных компакт дисков
		create temporary table inventory_update_id_list on commit drop as
		select
			ini.inventory_id 
		from
			dds.inventory i
			join integ.inventory ini
				on i.inventory_id = ini.inventory_id 
		where
			i.is_active is true
			and i.hash <> md5(ini::text);
		
		-- помечаем неактуальными предущие строки по измененным компакт дискам
		update dds.inventory i
		set
			is_active = false,
			date_effective_to = ini.last_update 
		from
			integ.inventory ini
			join inventory_update_id_list upi
				on upi.inventory_id = ini.inventory_id
		where 
			ini.inventory_id = i.inventory_id
			and i.is_active is true;
		
		-- добавляем новые строки по измененным компакт дискам
		INSERT INTO dds.inventory
		(
			inventory_id,
			film_id,
			store_id,
			
			date_effective_from,
			date_effective_to,
			is_active,
			
			hash
		)
		select
			i.inventory_id,
			film_id,
			store_id,
			last_update as date_effective_from,
			'9999-01-01'::date as date_effective_to,
			true as is_active,
		
			md5(i::text) as hash
			
		from
			integ.inventory i
			join inventory_update_id_list upi
				on i.inventory_id = upi.inventory_id;
	end;
$$ language plpgsql;

create or replace procedure dds.rental_load()
as $$
	declare
		last_update_dt timestamp;
	begin
		-- дата и время последней измененной записи, загруженной в предыдущий раз
		last_update_dt = (
			select
				coalesce(max(r.last_update), '1900-01-01'::date)
			from
				dds.rental r
		);
	
		-- идентификаторы всех созданных, измененных или удаленных фактов сдачи в аренду с предыдущей загрузки из integ в dds
		create temporary table updated_dds_rent_id_list on commit drop as 
		select
			r.rental_id 
		from
			integ.rental r 
		where
			r.last_update > last_update_dt;
		
		-- удаляем из dds слоя все созданные, измененные или удаленные факты сдачи в аренду с предыдущей загрузки из integ в dds
		delete from dds.rental r
		where
			r.rental_id in (
				select
					rental_id
				from
					updated_dds_rent_id_list
			);
		
		-- вставляем в integ слой все созданные, измененные или удаленные факты сдачи в аренду с предыдущей загрузки из ods в integ
		insert into dds.rental
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
			r.rental_id,
			rental_date,
			inventory_id,
			return_date,
			staff_id,
			last_update,
			deleted
		from 
			integ.rental r
			join updated_dds_rent_id_list upd
				on upd.rental_id = r.rental_id;
	end;
$$ language plpgsql;

create or replace procedure dds.address_load()
as $$
	begin
		-- список id новых адресов
		create temporary table address_new_id_list on commit drop as
		select
			ra.address_sk as address_id
		from
			ref.address ra
			left join dds.address a
				on ra.address_sk = a.address_id
		where 
			a.address_id is null;
		
		-- вставляем новые адреса
		INSERT INTO dds.address
		(
			address_id,
			address,
			address2,
			district,
			city_id,
			postal_code,
			phone,
			
			date_effective_from,
			date_effective_to,
			is_active,
			hash
		)
		select
			a.address_id,
			address,
			address2,
			district,
			city_id,
			postal_code,
			phone,
			'1900-01-01'::date as date_effective_from,
			'9999-01-01'::date as date_effective_to,
			true as is_active,
		
			md5(a::text) as hash
			
		from
			integ.address a
			join address_new_id_list na
				on a.address_id = na.address_id;
			
		-- id удаленных адресов
		create temporary table address_deleted_id_list on commit drop as
		select 
			a.address_id
		from
			dds.address a 
			left join integ.address ina
				on a.address_id = ina.address_id 
		where 
			ina.address_id is null;
		
		-- помечаем удаленные адреса
		update dds.address a
		set 
			is_active = false,
			date_effective_to = now()
		from 
			address_deleted_id_list fa
		where
			fa.address_id = a.address_id 
			and a.is_active is true;
		
		-- находим id измененных адресов
		create temporary table address_update_id_list on commit drop as
		select
			ina.address_id 
		from
			dds.address a 
			join integ.address ina
				on a.address_id = ina.address_id 
		where
			a.is_active is true
			and a.hash <> md5(ina::text);
		
		-- помечаем неактуальными предущие строки по измененным адресам
		update dds.address a
		set
			is_active = false,
			date_effective_to = ina.last_update 
		from
			integ.address ina
			join address_update_id_list upa
				on upa.address_id = ina.address_id
		where 
			ina.address_id = a.address_id
			and a.is_active is true;
		
		-- добавляем новые строки по измененным адресам
		INSERT INTO dds.address
		(
			address_id,
			address,
			address2,
			district,
			city_id,
			postal_code,
			phone,
			
			date_effective_from,
			date_effective_to,
			is_active,
			hash
		)
		select
			a.address_id,
			address,
			address2,
			district,
			city_id,
			postal_code,
			phone,
			
			last_update as date_effective_from,
			'9999-01-01'::date as date_effective_to,
			true as is_active,
		
			md5(a::text) as hash
			
		from
			integ.address a
			join address_update_id_list upa
				on a.address_id = upa.address_id;
	end;
$$ language plpgsql;

create or replace procedure dds.city_load()
as $$
	begin
		-- список id новых городов
		create temporary table city_new_id_list on commit drop as
		select
			rc.city_sk as city_id
		from
			ref.city rc
			left join dds.city c
				on rc.city_sk = c.city_id
		where 
			c.city_id is null;
		
		-- вставляем новые города
		INSERT INTO dds.city
		(
			city_id,
			city,
			
			date_effective_from,
			date_effective_to,
			is_active,
			hash
		)
		select
			c.city_id,
			city,
			'1900-01-01'::date as date_effective_from,
			'9999-01-01'::date as date_effective_to,
			true as is_active,
		
			md5(c::text) as hash
			
		from
			integ.city c
			join city_new_id_list nc
				on c.city_id = nc.city_id;
			
		-- id удаленных городов
		create temporary table city_deleted_id_list on commit drop as
		select 
			c.city_id
		from
			dds.city c
			left join integ.city inc
				on c.city_id = inc.city_id 
		where 
			inc.city_id is null;
		
		-- помечаем удаленные города
		update dds.city c
		set 
			is_active = false,
			date_effective_to = now()
		from 
			city_deleted_id_list fc
		where
			fc.city_id = c.city_id 
			and c.is_active is true;
		
		-- находим id измененных городов
		create temporary table city_update_id_list on commit drop as
		select
			inc.city_id
		from
			dds.city c
			join integ.city inc
				on c.city_id = inc.city_id 
		where
			c.is_active is true
			and c.hash <> md5(inc::text);
		
		-- помечаем неактуальными предущие строки по измененным городам
		update dds.city c
		set
			is_active = false,
			date_effective_to = inc.last_update 
		from
			integ.city inc
			join city_update_id_list upc
				on upc.city_id = inc.city_id
		where 
			inc.city_id = c.city_id
			and c.is_active is true;
		
		-- добавляем новые строки по измененным городам
		INSERT INTO dds.city
		(
			city_id,
			city,
			
			date_effective_from,
			date_effective_to,
			is_active,
			hash
		)
		select
			c.city_id,
			city,
			last_update as date_effective_from,
			'9999-01-01'::date as date_effective_to,
			true as is_active,
		
			md5(c::text) as hash
			
		from
			integ.city c
			join city_update_id_list upc
				on c.city_id = upc.city_id;
	end;
$$ language plpgsql;

create or replace procedure dds.staff_load()
as $$
	begin
		-- список id новых сотрудников
		create temporary table staff_new_id_list on commit drop as
		select
			rs.staff_sk as staff_id
		from
			ref.staff rs
			left join dds.staff s
				on rs.staff_sk = s.staff_id
		where 
			s.staff_id is null;
		
		-- вставляем новых сотрудников
		INSERT INTO dds.staff
		(
			staff_id,
			first_name,
			last_name,
			address_id,
			email,
			store_id,
			active,
			username,
			picture,
			
			date_effective_from,
			date_effective_to,
			is_active,
			
			hash
		)
		select
			s.staff_id,
			first_name,
			last_name,
			address_id,
			email,
			store_id,
			active,
			username,
			picture,
			'1900-01-01'::date as date_effective_from,
			'9999-01-01'::date as date_effective_to,
			true as is_active,
			md5(s::text) as hash
			
		from
			integ.staff s
			join staff_new_id_list ns
				on s.staff_id = ns.staff_id;
			

		-- id удаленных сотрудников
		create temporary table staff_deleted_id_list on commit drop as
		select 
			s.staff_id,
			ins.deleted 
		from
			dds.staff s
			left join integ.staff ins
				on s.staff_id = ins.staff_id 
		where 
			ins.staff_id is null;
		
		-- помечаем удаленных сотрудников
		update dds.staff s
		set 
			is_active = false,
			date_effective_to = sd.deleted
		from 
			staff_deleted_id_list sd
		where
			sd.staff_id = s.staff_id 
			and s.is_active is true;
		
		-- находим id измененных сотрудников
		create temporary table staff_update_id_list on commit drop as
		select
			ins.staff_id 
		from
			dds.staff s
			join integ.staff ins
				on s.staff_id = ins.staff_id 
		where
			s.is_active is true
			and s.hash <> md5(ins::text);
		
		-- помечаем неактуальными предущие строки по измененным сотрудникам
		update dds.staff s
		set
			is_active = false,
			date_effective_to = ins.last_update 
		from
			integ.staff ins
			join staff_update_id_list ups
				on ups.staff_id = ins.staff_id
		where 
			ins.staff_id = s.staff_id
			and s.is_active is true;
		
		-- добавляем новые строки по измененным сотрудникам
		INSERT INTO dds.staff
		(
			staff_id,
			first_name,
			last_name,
			address_id,
			email,
			store_id,
			active,
			username,
			picture,
			
			date_effective_from,
			date_effective_to,
			is_active,
			
			hash
		)
		select
			s.staff_id,
			first_name,
			last_name,
			address_id,
			email,
			store_id,
			active,
			username,
			picture,
			last_update as date_effective_from,
			'9999-01-01'::date as date_effective_to,
			true as is_active,
			md5(s::text) as hash
			
		from
			integ.staff s
			join staff_update_id_list ups
				on s.staff_id = ups.staff_id;
	end;
$$ language plpgsql;

create or replace procedure dds.store_load()
as $$
	begin
		-- список id новых магазинов
		create temporary table store_new_id_list on commit drop as
		select
			rs.store_sk as store_id
		from
			ref.store rs
			left join dds.store s
				on rs.store_sk = s.store_id
		where 
			s.store_id is null;
		
		-- вставляем новые магазины
		INSERT INTO dds.store
		(
			store_id,
			manager_staff_id,
			address_id,
			
			date_effective_from,
			date_effective_to,
			is_active,
			hash
		)
		select
			s.store_id,
			manager_staff_id,
			address_id,
			'1900-01-01'::date as date_effective_from,
			'9999-01-01'::date as date_effective_to,
			true as is_active,
			md5(s::text) as hash
			
		from
			integ.store s
			join store_new_id_list ns
				on s.store_id = ns.store_id;
			
		-- id удаленных магазинов
		create temporary table store_deleted_id_list on commit drop as
		select 
			s.store_id
		from
			dds.store s
			left join integ.store ins
				on s.store_id = ins.store_id 
		where 
			ins.store_id is null;
		
		-- помечаем удаленные магазины
		update dds.store s
		set 
			is_active = false,
			date_effective_to = now()
		from 
			store_deleted_id_list fs
		where
			fs.store_id = s.store_id 
			and s.is_active is true;
		
		-- находим id измененных магазинов
		create temporary table store_update_id_list on commit drop as
		select
			ins.store_id
		from
			dds.store s
			join integ.store ins
				on s.store_id = ins.store_id 
		where
			s.is_active is true
			and s.hash <> md5(ins::text);
		
		-- помечаем неактуальными предущие строки по измененным магазинам
		update dds.store s
		set
			is_active = false,
			date_effective_to = ins.last_update 
		from
			integ.store ins
			join store_update_id_list ups
				on ups.store_id = ins.store_id
		where 
			ins.store_id = s.store_id
			and s.is_active is true;
		
		-- добавляем новые строки по измененным магазинам
		INSERT INTO dds.store
		(
			store_id,
			manager_staff_id,
			address_id,
			
			date_effective_from,
			date_effective_to,
			is_active,
			hash
		)
		select
			s.store_id,
			manager_staff_id,
			address_id,
			last_update as date_effective_from,
			'9999-01-01'::date as date_effective_to,
			true as is_active,
			md5(s::text) as hash
			
		from
			integ.store s
			join store_update_id_list ups
				on s.store_id = ups.store_id;
	end;
$$ language plpgsql;

create or replace procedure dds.payment_load()
as $$
	declare
		last_update_dt timestamp;
	begin
		-- дата и время последней измененной записи, загруженной в предыдущий раз
		last_update_dt = (
			select
				coalesce(max(p.last_update), '1900-01-01'::date)
			from
				dds.payment p
		);
	
		-- идентификаторы всех созданных, измененных или удаленных фактов сдачи в аренду с предыдущей загрузки из integ в dds
		create temporary table updated_dds_paym_id_list on commit drop as 
		select
			p.payment_id 
		from
			integ.payment p
		where
			p.last_update > last_update_dt;
		
		-- удаляем из dds слоя все созданные, измененные или удаленные факты сдачи в аренду с предыдущей загрузки из integ в dds
		delete from dds.payment p
		where
			p.payment_id in (
				select
					payment_id
				from
					updated_dds_paym_id_list
			);
		
		-- вставляем в integ слой все созданные, измененные или удаленные факты сдачи в аренду с предыдущей загрузки из ods в integ
		insert into dds.payment
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
			p.payment_id,
			staff_id,
			rental_id,
			amount,
			payment_date,
			last_update,
			deleted
		from 
			integ.payment p
			join updated_dds_paym_id_list upd
				on upd.payment_id = p.payment_id;
	end;
$$ language plpgsql;