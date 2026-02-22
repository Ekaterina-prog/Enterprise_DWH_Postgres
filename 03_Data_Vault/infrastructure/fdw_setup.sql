-- устанавливаем расширерение, для подключений к внешним БД
create extension postgres_fdw;

-- создаем сервер, к которому будем подключатся из БД
create server film_pg foreign data wrapper postgres_fdw options (
host 'localhost',
dbname 'dvdrental',
port '5432'
);

-- маппируем пользователя, который будет подключатсяк внешней БД
create user mapping for postgres server film_pg options (
user 'postgres',
password '******'
);

-- создаем схему в хранилище Data Vault под название film_src
drop schema if exists film_src;
create schema film_src authorization postgres;

-- создаем типы данных mpaa_rating, year
drop type if exists mpaa_rating;

create type public.mpaa_rating as enum (
'G',
'PG',
'PG-13',
'R',
'NC-17');

create domain public.year as integer check(VALUE >= 1901
and VALUE <= 2155);

-- подключаем схему film_src
import foreign schema public
from
server film_pg
into
	film_src;

