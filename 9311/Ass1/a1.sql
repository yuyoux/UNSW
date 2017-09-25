-- COMP9311 17s2 Assignment 1
-- Schema for OzCars
--
-- Date: 2017/8/15
-- Student Name: Xu Yuyou
-- Student ID: z5143390
--

-- Some useful domains; you can define more if needed.

create domain URLType as
	varchar(100) check (value like 'http://%');

create domain EmailType as
	varchar(100) check (value like '%@%.%');

create domain PhoneType as
	char(10) check (value ~ '[0-9]{10}');

create domain MechanicLicenseType as
        varchar(8) check (value like '[0-9A-Za-z]{8}');



-- EMPLOYEE

create table Employee (
	EID	serial, 
	TFN	char(9) not null,
	CHECK (TFN ~ '^[0-9]{9}$'),
	firstname	varchar(50) not null,
	lastname	varchar(50) not null,
    	Salary	integer not null check (Salary > 0),
	primary key(EID)
);

create table admin(
	EID	int references Employee(EID),
	primary key(EID)
);

create table Mechanic(
	EID	int references Employee(EID),
	license	MechanicLicenseType unique not null,
	primary key(EID)
);

create table Salesman(
	EID	int references Employee(EID),
	commRate	integer not null,
	CHECK (commRate between 5 and 20), 
	primary key(EID)
);


-- CLIENT

create table Client (
	CID	serial,
	name	varchar(100) not null,
	address	varchar(200) not null,
	phone	PhoneType not null,
	email	EmailType,
	primary key(CID)
);

create table Company(
	CID	int references Client(CID),
	ABN	char(11) not null,
	CHECK (ABN ~ '^[0-9]{11}$'),
	url	URLType,
	primary key(CID)
);



-- CAR

create domain CarLicenseType as
        varchar(6) check (value ~ '[0-9A-Za-z]{1, 6}');

create domain OptionType as varchar(12)
	check (value in ('sunroof','moonroof','GPS','alloy wheels','leather'));

create domain VINType as char(17) 
	check (value ~ '[0-9A-Z]{17}' and value !~ '%I%' and value !~ '%O%' and value !~ '%Q%');

create table Car(
	VIN	VINType,
	manufacturer	varchar(40) not null,
	model	varchar(40) not null,
	year	integer not null,
	CHECK (year >= 1970 and year <= 2099),
	primary key(VIN)
	
);

create table CarOptions(
	option	OptionType,
	VIN	VINType references Car(VIN),
	primary key(option, VIN) 
);

create table NewCar(
	VIN	VINType references Car(VIN),
	cost	numeric(8,2) not null,
	CHECK (cost > 0),
	charges	numeric(8,2) not null,
	CHECK (charges > 0),
	plateNumber	CarLicenseType not null,
	primary key(VIN)
);

create table UsedCar(
	VIN	VINType references Car(VIN),
	plateNumber	CarLicenseType unique not null,
	primary key(VIN)
);


-- Buy, Sell and Repair


create table RepairJob(
	VIN	VINType references UsedCar(VIN),
	number	integer,
	CHECK (number >= 1 and number <= 999),
	description	varchar(250),
	"date"	date,
	parts	numeric(8,2) not null,
	CHECK (parts > 0),
	work	numeric(8,2) not null,
	CHECK (work > 0),
	PaidBy	int not null,
	primary key(VIN, number),
	foreign key(PaidBy) references Client(CID)
);

create table Dose(
	EID	int references Mechanic(EID),
	number	integer,
	VIN	VINType,
	primary key(EID, VIN, number),
	foreign key(VIN, number) references RepairJob(VIN, number)
);


create table Buys(
	salesmanNO	int references Salesman(EID),
	VIN	VINType references UsedCar(VIN),
	seller	int references Client(CID),
	price	numeric(8,2) not null,
	CHECK (price > 0),
	"date"	date,
	comission	numeric(8,2) not null,
	CHECK (comission > 0),
	Primary Key(VIN, seller, "date")

);

create table Sells(
	salesmanNO	int references Salesman(EID),
	VIN	VINType references UsedCar(VIN),
	buyer	int references Client(CID),
	price	numeric(8,2) not null,
	CHECK (price > 0),
	"date"	date,
	comission	numeric(8,2) not null,
	CHECK (comission > 0),
	Primary Key(VIN, buyer, "date")
);

create table SellsNew(
	salesmanNO	int references Salesman(EID),
	VIN	VINType references NewCar(VIN),
	buyer	int references Client(CID),
	"date"	date,
	price	numeric(8,2) not null,
	CHECK (price > 0),
	comission	numeric(8,2) not null,
	CHECK	(comission > 0),
	plateNumber	CarLicenseType unique not null,
	Primary Key(VIN, buyer, "date")
);
