-- создаем процедуры загрузки линков

create or replace procedure datavault.link_film_inventory_load()
as $$
	begin
	    insert into datavault.linkfilminventory
	    (
	        linkfilminventoryhashkey,
			loaddate,
			recordsource,
			hubfilmhashkey,
			hubinventoryhashkey
	    )
	    select
			si.linkfilminventoryhashkey,
			si.loaddate,
			si.recordsource,
			si.hubfilmhashkey,
			si.hubinventoryhashkey
		from
			staging.inventory si
		where not exists (
		select
			1
		from
			datavault.linkfilminventory lfi
		where
			si.linkfilminventoryhashkey = lfi.linkfilminventoryhashkey
	        );
	end;
$$ language plpgsql;

create or replace procedure datavault.link_rental_inventory_load()
as $$
	begin
	    insert into datavault.linkrentalinventory
	    (
	        linkrentalinventoryhashkey,
	        loaddate,
	        recordsource,
	        hubrentalhashkey,
	        hubinventoryhashkey
	    )
	    select
	        sr.linkrentalinventoryhashkey,
	        sr.loaddate,
	        sr.recordsource,
	        sr.hubrentalhashkey,
	        sr.hubinventoryhashkey
	    from
	        staging.rental sr
	    where
	        not exists (
	            select
	                1
	            from
	                datavault.linkrentalinventory lri
	            where
	                sr.linkrentalinventoryhashkey = lri.linkrentalinventoryhashkey
	        );
	end;
$$ language plpgsql;