-- полная процедура загрузки данных

create or replace procedure full_load()
as $$
	declare
		current_update_dt timestamp = now();
	begin
		call staging.film_load(current_update_dt);
		call staging.inventory_load(current_update_dt);
		call staging.rental_load(current_update_dt);

		call dataVault.hub_film_load();
		call datavault.hub_inventory_load();
		call datavault.hub_rental_load();

		call datavault.link_film_inventory_load();
		call datavault.link_rental_inventory_load();

		call datavault.sat_film_load(current_update_dt);
		call datavault.sat_filmmon_load(current_update_dt);
	end;
$$ language plpgsql;

call full_load();
