-- создаем процедуры загрузки хабов

create or replace procedure datavault.hub_film_load()
as $$
begin
    insert into datavault.hubfilm (
        hubfilmhashkey,
        loaddate,
        recordsource,
        filmid
    )
    select
        s.hubfilmhashkey,
        s.loaddate,
        s.recordsource,
        s.film_id
    from (
        select
            sf.hubfilmhashkey,
            sf.loaddate,
            sf.recordsource,
            sf.film_id
        from
            staging.film sf
        where
            sf.film_id not in (
                select
                    hf.filmid
                from
                    datavault.hubfilm hf
            )
        union
        select
            si.hubfilmhashkey,
            si.loaddate,
            si.recordsource,
            si.film_id
        from
            staging.inventory si
        where
            si.film_id not in (
                select
                    hf.filmid
                from
                    datavault.hubfilm hf
            )
    ) s;
end;
$$ language plpgsql;

create or replace procedure datavault.hub_inventory_load()
as $$
	begin
	    insert into datavault.hubinventory 
		(
	        hubinventoryhashkey,
	        loaddate,
	        recordsource,
	        inventoryid
	    )
	    select
	        s.hubinventoryhashkey,
	        s.loaddate,
	        s.recordsource,
	        s.inventory_id
	    from (
	        select
	            si.hubinventoryhashkey,
	            si.loaddate,
	            si.recordsource,
	            si.inventory_id
	        from
	            staging.inventory si
	        where
	            si.inventory_id not in (
	                select
	                    hi.inventoryid
	                from
	                    datavault.hubinventory hi
	            )
	        union
	        select
	            sr.hubinventoryhashkey,
	            sr.loaddate,
	            sr.recordsource,
	            sr.inventory_id
	        from
	            staging.rental sr
	        where
	            sr.inventory_id not in (
	                select
	                    hi.inventoryid
	                from
	                    datavault.hubinventory hi
	            )
	    ) s;
	end;
$$ language plpgsql;

create or replace procedure datavault.hub_rental_load()
as $$
	begin
	    insert into datavault.hubrental
		(
	        hubrentalhashkey,
	        loaddate,
	        recordsource,
	        rentalid
	    )
	    select
	        s.hubrentalhashkey,
	        s.loaddate,
	        s.recordsource,
	        s.rental_id
	    from (
	        select
	            sr.hubrentalhashkey,
	            sr.loaddate,
	            sr.recordsource,
	            sr.rental_id
	        from
	            staging.rental sr
	        where
	            sr.rental_id not in (
	                select
	                    hr.rentalid
	                from
	                    datavault.hubrental hr
	            )
	        ) s;
	end;
$$ language plpgsql;