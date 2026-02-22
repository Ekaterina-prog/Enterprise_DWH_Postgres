-- создаем линки

drop table if exists LinkFilmInventory;
create table LinkFilmInventory (
	LinkFilmInventoryHashKey varchar(32) primary key,
	LoadDate timestamp not null,
	RecordSource varchar(50) not null,
	HubFilmHashKey varchar(32) references HubFilm(HubFilmHashKey),
	HubInventoryHashKey varchar(32) references HubInventory(HubInventoryHashKey)
);

drop table if exists LinkRentalInventory;
create table LinkRentalInventory (
	LinkRentalInventoryHashKey varchar(32) primary key,
	LoadDate timestamp not null,
	RecordSource varchar(50) not null,
	HubRentalHashKey varchar(32) references HubRental(HubRentalHashKey),
	HubInventoryHashKey varchar(32) references HubInventory(HubInventoryHashKey)
);