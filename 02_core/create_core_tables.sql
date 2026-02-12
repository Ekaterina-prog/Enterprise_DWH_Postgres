-- Создание таблиц core слоя (звездная схема по Кимбалу)

-- Создание схемы core
create schema if not exists core;

-- Удаление существующих таблиц (если есть)
drop table if exists core.fact_payment;
drop table if exists core.fact_rental;
drop table if exists core.dim_inventory;
drop table if exists core.dim_staff;

-- Таблица измерения инвентарь фильмов
create table core.dim_inventory(
    inventory_pk serial primary key,
    inventory_id integer not null,
    film_id integer not null,
    title varchar(255) not null,
    rental_duration int2 not null,
    rental_rate numeric(4,2) not null,
    length int2,
    rating varchar(10)
);

-- Таблица измерения сотрудники
create table core.dim_staff (
    staff_pk serial primary key,
    staff_id integer not null,
    first_name varchar(45) not null,
    last_name varchar(45) not null,
    address varchar(50) not null,
    district varchar(20) not null,
    city_name varchar(50) not null
);

-- Таблица фактов платежи
create table core.fact_payment (
    payment_pk serial primary key,
    payment_id integer not null,
    amount numeric(7,2) not null,
    payment_date date not null,
    inventory_fk integer not null references core.dim_inventory(inventory_pk),
    staff_fk integer not null references core.dim_staff(staff_pk)
);

-- Таблица фактов аренды
create table core.fact_rental (
    rental_pk serial primary key,
    rental_id integer not null,
    inventory_fk integer not null references core.dim_inventory(inventory_pk),
    staff_fk integer not null references core.dim_staff(staff_pk),
    rental_date date not null,
    return_date date,
    cnt int2 not null,
    amount numeric(7,2)
);
