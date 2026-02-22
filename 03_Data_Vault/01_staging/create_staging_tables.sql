--создание таблиц staging слоя

drop table if exists staging.last_update;
create table staging.last_update (
	table_name varchar(50) not null,
	update_dt timestamp not null
);

drop table if exists staging.film;
CREATE TABLE staging.film (
	film_id int NOT NULL,
	title varchar(255) NOT NULL,
	description text NULL,
	release_year year NULL,
	language_id int2 NOT NULL,
	rental_duration int2 NOT NULL,
	rental_rate numeric(4,2) NOT NULL,
	length int2 NULL,
	replacement_cost numeric(5,2) NOT NULL,
	rating mpaa_rating NULL,
	last_update timestamp NOT NULL,
	special_features _text NULL,
	fulltext tsvector NOT NULL
);

drop table if exists staging.inventory;
CREATE TABLE staging.inventory (
	inventory_id int NOT NULL,
	film_id int2 NOT NULL,
	store_id int2 NOT NULL,
	last_update timestamp NOT NULL,
	deleted timestamp NULL
);

drop table if exists staging.rental;
CREATE TABLE staging.rental (
	rental_id int NOT NULL,
	rental_date timestamp NOT NULL,
	inventory_id int4 NOT NULL,
	return_date timestamp NULL,
	staff_id int2 NOT NULL,
	last_update timestamp NOT NULL,
	deleted timestamp NULL
);