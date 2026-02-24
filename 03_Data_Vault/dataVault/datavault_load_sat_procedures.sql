-- создаем процедуры загрузки саттелитов

create or replace procedure datavault.sat_film_load(current_update_dt timestamp)
as $$
	begin
    	insert into datavault.satfilm
    	(
	        hubfilmhashkey,
			loaddate,
			loadenddate,
			recordsource,
			hashdiff,
			title,
			description,
			releaseyear,
			length,
			rating
	    )
	    select
			sf.hubfilmhashkey,
			sf.loaddate,
			null as loadenddate,
			sf.recordsource,
			sf.filmhashdiff,
			sf.title,
			sf.description,
			sf.release_year,
			sf.length,
			sf.rating
		from
			staging.film sf
			left join datavault.satfilm sat
			    on sf.hubfilmhashkey = sat.hubfilmhashkey
				and sat.loadenddate is null
		where
			sat.hubfilmhashkey is null
			or sat.hashdiff <> sf.filmhashdiff;
			
		with updated_sat as (
			select
				f.hubfilmhashkey,
				f.loaddate,
				cf.loaddate as loadenddate
			from
				datavault.satfilm f
			join datavault.satfilm cf
			    on f.hubfilmhashkey = cf.hubfilmhashkey
				and cf.loaddate > f.loaddate
				and f.loadenddate is null
				and cf.loadenddate is null
		)
		update
			datavault.satfilm as sat
		set
			loadenddate = s.loadenddate
		from
			updated_sat s
		where
			sat.hubfilmhashkey = s.hubfilmhashkey
			and sat.loaddate = s.loaddate;
		
		with deleted_sat as (
			select
				s.hubfilmhashkey,
				s.loaddate,
				current_update_dt as loadenddate
			from
				datavault.satfilm s
				left join staging.film f
			        on s.hubfilmhashkey = f.hubfilmhashkey
			where
				f.hubfilmhashkey is null
				and s.loadenddate is null
		)
		update
			datavault.satfilm as sat
		set
			loadenddate = s.loadenddate
		from
			deleted_sat s
		where
			sat.hubfilmhashkey = s.hubfilmhashkey
			and sat.loaddate = s.loaddate;

	end;
$$ language plpgsql;

create or replace procedure datavault.sat_filmmon_load(current_update_dt timestamp)
as $$
	begin
	    insert into datavault.satfilmmon 
		(
	        hubfilmhashkey,
			loaddate,
			loadenddate,
			recordsource,
			hashdiff,
			rentalduration,
			rentalrate,
			replacementcost
	    )
	    select
			sf.hubfilmhashkey,
			sf.loaddate,
			null as loadenddate,
			sf.recordsource,
			sf.filmmonhashdiff,
			sf.rental_duration,
			sf.rental_rate,
			sf.replacement_cost
		from
			staging.film sf
			left join datavault.satfilmmon sat
	            on sf.hubfilmhashkey = sat.hubfilmhashkey
				and sat.loadenddate is null
		where
			sat.hubfilmhashkey is null
			or sat.hashdiff <> sf.filmmonhashdiff;

		with updated_sat as (
			select
				f.hubfilmhashkey,
				f.loaddate,
				cf.loaddate as loadenddate
			from
				datavault.satfilmmon f
			join datavault.satfilmmon cf
			            on
				f.hubfilmhashkey = cf.hubfilmhashkey
				and cf.loaddate > f.loaddate
				and f.loadenddate is null
				and cf.loadenddate is null
			)
		update
			datavault.satfilmmon as sat
		set
			loadenddate = s.loadenddate
		from
			updated_sat s
		where
			sat.hubfilmhashkey = s.hubfilmhashkey
			and sat.loaddate = s.loaddate;

		with deleted_sat as (
			select
				s.hubfilmhashkey,
				s.loaddate,
				current_update_dt as loadenddate
			from
				datavault.satfilmmon s
			left join staging.film f
			            on
				s.hubfilmhashkey = f.hubfilmhashkey
			where
				f.hubfilmhashkey is null
				and s.loadenddate is null
			)
		update
			datavault.satfilmmon as sat
		set
			loadenddate = s.loadenddate
		from
			deleted_sat s
		where
			sat.hubfilmhashkey = s.hubfilmhashkey
			and sat.loaddate = s.loaddate;
	end;
$$ language plpgsql;