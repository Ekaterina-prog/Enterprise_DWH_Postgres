-- создаем саттелиты

drop table if exists SatFilm;
create table SatFilm (
	HubFilmHashKey varchar(32) not null references HubFilm(HubFilmHashKey),
	LoadDate timestamp not null,
	LoadEndDate timestamp not null,
	RecordSource varchar(50) not null,
	HashDiff varchar(32) not null,
	
	Title varchar(255),
	Description text,
	ReleaseYear year,
	Length int2,
	Rating mpaa_rating,
	
	PRIMARY KEY (HubFilmHashKey, LoadDate)
);

drop table if exists SatFilmMon;
create table SatFilmMon (
	HubFilmHashKey varchar(32) not null references HubFilm(HubFilmHashKey),
	LoadDate timestamp not null,
	LoadEndDate timestamp not null,
	RecordSource varchar(50) not null,
	HashDiff varchar(32) not null,
	
	RentalDuration int2,
	RentalRate numeric(4, 2),
	ReplacementCost numeric(5, 2),
	
	PRIMARY KEY (HubFilmHashKey, LoadDate)
);

drop table if exists SatFilmInventory;
create table SatFilmInventory (
	LinkFilmInventoryHashKey varchar(32) not null references LinkFilmInventory(LinkFilmInventoryHashKey),
	LoadDate timestamp not null,
	LoadEndDate timestamp not null,
	RecordSource varchar(50) not null,
	
	PRIMARY KEY (LinkFilmInventoryHashKey, LoadDate)
);

drop table if exists SatInventory;
create table SatInventory (
	HubInventoryHashKey varchar(32) not null references HubInventory(HubInventoryHashKey),
	LoadDate timestamp not null,
	LoadEndDate timestamp not null,
	RecordSource varchar(50) not null,
	
	PRIMARY KEY (HubInventoryHashKey, LoadDate)
);

drop table if exists SatRentalInventory;
create table SatRentalInventory (
	LinkRentalInventoryHashKey varchar(32) not null references LinkRentalInventory(LinkRentalInventoryHashKey),
	LoadDate timestamp not null,
	LoadEndDate timestamp not null,
	RecordSource varchar(50) not null,
	
	PRIMARY KEY (LinkRentalInventoryHashKey, LoadDate)
);

drop table if exists SatRentalDate;
create table SatRentalDate (
	HubRentalHashKey varchar(32) not null references HubRental(HubRentalHashKey),
	LoadDate timestamp not null,
	LoadEndDate timestamp not null,
	RecordSource varchar(50) not null,
	
	RentalDate timestamp,
	
	PRIMARY KEY (HubRentalHashKey, LoadDate)
);

drop table if exists SatRentalReturnDate;
create table SatRentalReturnDate (
	HubRentalHashKey varchar(32) not null references HubRental(HubRentalHashKey),
	LoadDate timestamp not null,
	LoadEndDate timestamp not null,
	RecordSource varchar(50) not null,
	
	RentalReturnDate timestamp,
	
	PRIMARY KEY (HubRentalHashKey, LoadDate)
);