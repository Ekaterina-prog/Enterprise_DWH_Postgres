-- создаем хабы

drop table if exists HubFilm;
create table HubFilm (
	HubFilmHashKey varchar(32) primary key,
	LoadDate timestamp not null,
	RecordSource varchar(50) not null,
	FilmID int not null
);

drop table if exists HubInventory;
create table HubInventory (
	HubInventoryHashKey varchar(32) primary key,
	LoadDate timestamp not null,
	RecordSource varchar(50) not null,
	InventoryID int not null
);

drop table if exists HubRental;
create table HubRental (
	HubRentalHashKey varchar(32) primary key,
	LoadDate timestamp not null,
	RecordSource varchar(50) not null,
	RentalID int not null
);
