-- создание процедур staging слоя

create or replace function staging.get_last_update_table(table_name varchar) returns timestamp
as $$
	begin
		return coalesce( 
			(
				select
					max(update_dt)
				from
					staging.last_update lu
				where 
					lu.table_name = get_last_update_table.table_name
			),
			'1900-01-01'::date	
		);
	end;
$$ language plpgsql;


create or replace procedure staging.set_table_load_time(table_name varchar, current_update_dt timestamp default now())
as $$
	begin
		INSERT INTO staging.last_update
		(
			table_name, 
			update_dt
		)
		VALUES(
			table_name, 
			current_update_dt
		);
	end;
$$ language plpgsql;

create or replace procedure staging.film_load(current_update_dt timestamp)
 as $$
 	begin
		delete from staging.film;
	
		insert into staging.film
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
			fulltext,
			HubFilmHashKey,
			FilmHashDiff,
			FilmMonDiff,
			LoadDate,
			recordSource
		)
		select 
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
			fulltext,
			upper(md5(upper(trim(coalesce(film_id::text, ''))))) as HubFilmHashKey,
			upper(md5(upper(concat(
		    trim(coalesce(title::text, '')), ';',
		    trim(coalesce(description::text, '')), ';',
			trim(coalesce(release_year::text, '')), ';',
			trim(coalesce(length::text, '')), ';',
			trim(coalesce(rating::text, ''))
			)))) as FilmHashDiff,
			upper(md5(upper(concat(
		    trim(coalesce(rental_duration::text, '')), ';',
		   	trim(coalesce(rental_rate::text, '')), ';',
			trim(coalesce(replacement_cost::text, ''))
			)))) as FilmMonDiff,
			current_update_dt,
			'DVDRentalDB'
		from
			film_src.film;
		
		call staging.set_table_load_time('staging.film', current_update_dt);
	end;
$$ language plpgsql;

create or replace procedure staging.inventory_load(current_update_dt timestamp)
as $$
	begin
		delete from staging.inventory;
	
		insert into staging.inventory
		(
			inventory_id, 
			film_id, 
			store_id,
			last_update,
			deleted,
			HubInventoryHashKey,
			HubFilmHashKey,
			LinkFilmInventoryHashKey,
			LinkRentalInventoryHashKey,
			LoadDate,
			recordSource
		)
		select 
			inventory_id, 
			film_id, 
			store_id,
			last_update,
			deleted,
			upper(md5(upper(trim(coalesce(inventory_id::text, ''))))) as HubInventoryHashKey,
			upper(md5(upper(trim(coalesce(film_id::text, ''))))) as HubFilmHashKey,
			upper(md5(upper(concat(
		    trim(coalesce(film_id::text, '')),
		    ';',
		    trim(coalesce(inventory_id::text, ''))
			)))) as LinkFilmInventoryHashKey,
			upper(md5(upper(concat(
			trim(coalesce(film_id::text, '')),
			';',
			trim(coalesce(inventory_id::text, ''))
			)))) as LinkRentalInventoryHashKey,
			current_update_dt,
			'DVDRentalDB'
		from
			film_src.inventory i;
		
		call staging.set_table_load_time('staging.inventory', current_update_dt);
	end;
$$ language plpgsql;

create or replace procedure staging.rental_load(current_update_dt timestamp)
as $$
	declare 
		last_update_dt timestamp;
	begin
		last_update_dt = staging.get_last_update_table('staging.rental');
		
		delete from staging.rental;
	
		insert into staging.rental
		(
			rental_id, 
			rental_date, 
			inventory_id, 
			return_date, 
			staff_id,
			last_update,
			deleted,
			HubRentalHashKey,
			HubInventoryHashKey,
			HubStaffHashKey,
			LinkRentalInventoryHashKey,
			LoadDate,
			recordSource
		)
		select 
			rental_id, 
			rental_date, 
			inventory_id, 
			return_date, 
			staff_id,
			last_update,
			deleted,
			upper(md5(upper(trim(coalesce(rental_id::text, ''))))) as HubRentalHashKey,
			upper(md5(upper(trim(coalesce(inventory_id::text, ''))))) as HubInventoryHashKey,
			upper(md5(upper(trim(coalesce(staff_id::text, ''))))) as HubStaffHashKey,
	        upper(md5(upper(concat(
		    trim(coalesce(rental_id::text, '')),
		    ';',
		    trim(coalesce(inventory_id::text, ''))
			)))) as LinkRentalInventoryHashKey,
   			current_update_dt,
			'DVDRentalDB'
		from
			film_src.rental
		where 
			deleted >=last_update_dt
			or last_update>=last_update_dt;
		
		call staging.set_table_load_time('staging.rental', current_update_dt);
	end;
$$ language plpgsql;