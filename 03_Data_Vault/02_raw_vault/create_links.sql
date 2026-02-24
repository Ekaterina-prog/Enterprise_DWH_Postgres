-- создаем линки

create table dataVault.LinkFilmInventory (
	LinkFilmInventoryHashKey varchar(32) primary key,
	LoadDate timestamp not null,
	RecordSource varchar(50) not null,
	HubFilmHashKey varchar(32) references dataVault.HubFilm(HubFilmHashKey),
	HubInventoryHashKey varchar(32) references dataVault.HubInventory(HubInventoryHashKey)
);

create table dataVault.LinkRentalInventory (
	LinkRentalInventoryHashKey varchar(32) primary key,
	LoadDate timestamp not null,
	RecordSource varchar(50) not null,
	HubRentalHashKey varchar(32) references dataVault.HubRental(HubRentalHashKey),
	HubInventoryHashKey varchar(32) references dataVault.HubInventory(HubInventoryHashKey)
);