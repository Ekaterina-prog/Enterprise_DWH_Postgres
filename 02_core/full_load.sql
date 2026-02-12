-- Общая процедура полной загрузки
-- Последовательно загружается staging и core слой

create or replace procedure full_load()
as $$
	begin
	    call staging.film_load();
	    call staging.inventory_load();
	    call staging.rental_load();
	    call staging.payment_load();
	    call staging.staff_load();
	    call staging.address_load();
	    call staging.city_load();
	    call staging.store_load();
	    
	    call core.fact_delete();
	    call core.load_core_inventory();
	    call core.load_core_staff();
	    call core.load_core_payment();
	    call core.load_core_rental();
	end;
$$ language plpgsql;

call full_load();


