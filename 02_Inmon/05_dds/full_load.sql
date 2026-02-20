-- полная загрузка данных

create or replace procedure full_load()
as $$
	declare
		current_update_dt timestamp = now();
	begin
		call staging.film_load(current_update_dt);
		call staging.inventory_load(current_update_dt);
		call staging.rental_load(current_update_dt);
		call staging.address_load(current_update_dt);
		call staging.city_load(current_update_dt);
		call staging.staff_load(current_update_dt);
		call staging.store_load(current_update_dt);
		call staging.payment_load(current_update_dt);
		
		call ods.film_load();
		call ods.inventory_load();
		call ods.rental_load();
		call ods.address_load();
		call ods.city_load();
		call ods.staff_load();
		call ods.store_load();
		call ods.payment_load();
		
		call ref.film_id_sync();
		call ref.inventory_id_sync();
		call ref.rental_id_sync();
		call ref.address_id_sync();
		call ref.city_id_sync();
		call ref.staff_id_sync();
		call ref.store_id_sync();
		call ref.payment_id_sync();
	
		call integ.film_load();
		call integ.inventory_load();
		call integ.rental_load();
		call integ.address_load();
		call integ.city_load();
		call integ.staff_load();
		call integ.store_load();
		call integ.payment_load();
	
		call dds.film_load();
		call dds.inventory_load();
		call dds.rental_load();
		call dds.address_load();
		call dds.city_load();
		call dds.staff_load();
		call dds.store_load();
		call dds.payment_load();
	end;
$$ language plpgsql;

call full_load();