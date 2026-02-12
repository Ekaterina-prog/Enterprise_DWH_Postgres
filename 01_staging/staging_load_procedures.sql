-- Процедуры загрузки данных из источника в staging слой
-- Реализована полная перезапись данных (full reload)

create or replace procedure staging.film_load()
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
			fulltext
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
			fulltext
	    from 
			film_src.film;
	end;
$$ language plpgsql;

create or replace procedure staging.inventory_load()
as $$
	begin
	    delete from staging.inventory;
	
	    insert into staging.inventory 
		(
			inventory_id, 
			film_id, 
			store_id
		)
	    select 
			inventory_id, 
			film_id, 
			store_id
	    from 
			film_src.inventory;
	end;
$$ language plpgsql;

create or replace procedure staging.rental_load()
as $$
	begin
	    delete from staging.rental;
	
	    insert into staging.rental 
		(
	        rental_id,
			rental_date,
			inventory_id,
			customer_id,
			return_date,
			staff_id
	    )
	    select 
			rental_id,
			rental_date,
			inventory_id,
			customer_id,
			return_date,
			staff_id
	    from 
			film_src.rental;
	end;
$$ language plpgsql;

create or replace procedure staging.payment_load()
as $$
	begin
	    delete from staging.payment;
	
	    insert into staging.payment 
		(
			payment_id,
			customer_id,
			staff_id,
			rental_id,
			amount,
			paymentdate
	    )
	    select 
			payment_id,
			customer_id,
			staff_id,
			rental_id,
			amount,
			paymentdate
	    from 
			film_src.payment;
	end;
$$ language plpgsql;

create or replace procedure staging.staff_load()
as $$
	begin
	    delete from staging.staff;
	
	    insert into staging.staff 
		(
			staff_id, 
			first_name, 
			last_name, 
			store_id
		)
	    select 
			staff_id,
			first_name,
			last_name,
			store_id
	    from 
			film_src.staff;
	end;
$$ language plpgsql;

create or replace procedure staging.address_load()
as $$
	begin
	    delete from staging.address;
	
	    insert into staging.address 
		(
			address_id, 
			address, 
			district, 
			city_id
		)
	    select 
				address_id, 
				address, 
				district, 
				city_id
	    from 
			film_src.address;
	end;
$$ language plpgsql;

create or replace procedure staging.city_load()
as $$
	begin
	    delete from staging.city;
	
	    insert into staging.city 
		(
			city_id, 
			city
		)
	    select 
			city_id, 
			city
	    from 
			film_src.city;
	end;
$$ language plpgsql;

create or replace procedure staging.store_load()
as $$
	begin
	    delete from staging.store;
	
	    insert into staging.store 
		(
			store_id, 
			address_id
		)
	    select 
			store_id, 
			address_id
	    from 
			film_src.store;
	end;
$$ language plpgsql;
