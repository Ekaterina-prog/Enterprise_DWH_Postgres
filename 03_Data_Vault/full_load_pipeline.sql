-- полная процедура загрузки данных

create or replace procedure full_load()
as $$
	declare
		current_update_dt timestamp = now();
	begin
		call staging.film_load(current_update_dt);
		call staging.inventory_load(current_update_dt);
		call staging.rental_load(current_update_dt);
	end;
$$ language plpgsql;

call full_load();
