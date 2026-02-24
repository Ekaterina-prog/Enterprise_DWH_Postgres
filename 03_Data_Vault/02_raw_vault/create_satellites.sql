-- создаем саттелиты

create table dataVault.SatFilm (
	HubFilmHashKey varchar(32) not null references dataVault.HubFilm(HubFilmHashKey),
	LoadDate timestamp not null,
	LoadEndDate timestamp,
	RecordSource varchar(50) not null,
	HashDiff varchar(32) not null,
	
	Title varchar(255),
	Description text,
	ReleaseYear year,
	Length int2,
	Rating mpaa_rating,
	
	PRIMARY KEY (HubFilmHashKey, LoadDate)
);

create table dataVault.SatFilmMon (
	HubFilmHashKey varchar(32) not null references dataVault.HubFilm(HubFilmHashKey),
	LoadDate timestamp not null,
	LoadEndDate timestamp,
	RecordSource varchar(50) not null,
	HashDiff varchar(32) not null,
	
	RentalDuration int2,
	RentalRate numeric(4, 2),
	ReplacementCost numeric(5, 2),
	
	PRIMARY KEY (HubFilmHashKey, LoadDate)
);

create table dataVault.SatFilmInventory (
	LinkFilmInventoryHashKey varchar(32) not null references dataVault.LinkFilmInventory(LinkFilmInventoryHashKey),
	LoadDate timestamp not null,
	LoadEndDate timestamp,
	RecordSource varchar(50) not null,
	
	PRIMARY KEY (LinkFilmInventoryHashKey, LoadDate)
);

create table dataVault.SatInventory (
	HubInventoryHashKey varchar(32) not null references dataVault.HubInventory(HubInventoryHashKey),
	LoadDate timestamp not null,
	LoadEndDate timestamp,
	RecordSource varchar(50) not null,
	
	PRIMARY KEY (HubInventoryHashKey, LoadDate)
);

create table dataVault.SatRentalInventory (
	LinkRentalInventoryHashKey varchar(32) not null references dataVault.LinkRentalInventory(LinkRentalInventoryHashKey),
	LoadDate timestamp not null,
	LoadEndDate timestamp,
	RecordSource varchar(50) not null,
	
	PRIMARY KEY (LinkRentalInventoryHashKey, LoadDate)
);

create table dataVault.SatRentalDate (
	HubRentalHashKey varchar(32) not null references dataVault.HubRental(HubRentalHashKey),
	LoadDate timestamp not null,
	LoadEndDate timestamp,
	RecordSource varchar(50) not null,
	
	RentalDate timestamp,
	
	PRIMARY KEY (HubRentalHashKey, LoadDate)
);

create table dataVault.SatRentalReturnDate (
	HubRentalHashKey varchar(32) not null references dataVault.HubRental(HubRentalHashKey),
	LoadDate timestamp not null,
	LoadEndDate timestamp,
	RecordSource varchar(50) not null,
	
	RentalReturnDate timestamp,
	
	PRIMARY KEY (HubRentalHashKey, LoadDate)
);