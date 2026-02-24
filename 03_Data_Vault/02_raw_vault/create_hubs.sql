-- создаем хабы

create table dataVault.HubFilm (
	HubFilmHashKey varchar(32) primary key,
	LoadDate timestamp not null,
	RecordSource varchar(50) not null,
	FilmID int not null
);

create table dataVault.HubInventory (
	HubInventoryHashKey varchar(32) primary key,
	LoadDate timestamp not null,
	RecordSource varchar(50) not null,
	InventoryID int not null
);

create table dataVault.HubRental (
	HubRentalHashKey varchar(32) primary key,
	LoadDate timestamp not null,
	RecordSource varchar(50) not null,
	RentalID int not null
);