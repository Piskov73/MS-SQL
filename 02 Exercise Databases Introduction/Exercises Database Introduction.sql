USE [Minions]

--1	Create Database--

CREATE DATABASE [Minions];

--2	Create Tables--

CREATE TABLE [Minions](

[Id] INT PRIMARY KEY,

[Name] VARCHAR (50) NOT NULL,

[Age]  INT 

);

CREATE TABLE[Towns](

[Id] INT PRIMARY KEY,

[Name] VARCHAR(50) NOT NULL

);

--3	Alter Minions Table--

ALTER TABLE [Minions]

ADD [TownId]  INT FOREIGN KEY REFERENCES [Towns](Id) 

--4 Insert Records in Both Tables--

INSERT INTO [Towns] ([Id],[Name])
VALUES 
(1,'Sofia'),
(2,'Plovdiv'),
(3,'Varna');

INSERT INTO [Minions] ([Id],[Name],[Age],[TownId])

VALUES
(1,'Kevin',22,1),
(2,'Bob',15,3),
(3,'Steward',NULL,2);

--5 Truncate Table Minions--

DELETE FROM [Minions]

--6.	Drop All Tables--

DROP TABLE [Minions]

DROP TABLE [Towns]

/* 7	Create Table People*/
	

	CREATE TABLE [People](

	[Id] INT PRIMARY KEY IDENTITY,

	[Name] NVARCHAR (200) NOT NULL,

	[Picture] VARBINARY (MAX),
	CONSTRAINT CHK_PictureSise CHECK(DATALENGTH([Picture])<=2097152),

	[Height] DECIMAL(3,2),

	[Weight] DECIMAL (5,2),

	[Gender] CHAR(1) NOT NULL CHECK([Gender] IN ('m','f')),

	[Birthdate] DATETIME2 NOT NULL,

	[Biography] VARCHAR(MAX)

	);

	INSERT INTO [People]([Name],[Height],[Weight],[Gender],[Birthdate])

	VALUES
	('Name1',1.87,Null,'m','1999-07-05'),
	('Name2',1.77,Null,'m','1990-08-14'),
	('Name3',1.67,Null,'m','1980-09-25'),
	('Name4',1.60,Null,'f','1970-10-28'),
	('Name5',1.50,Null,'f','1979-11-01')

	/*8.	Create Table Users*/


	CREATE TABLE [Users](

	[Id] INT PRIMARY KEY IDENTITY,

	[Username] VARCHAR (30) UNIQUE NOT NULL,

	[Password] VARCHAR (26) UNIQUE NOT NULL,

	[ProfilePicture] VARBINARY (MAX),
	CONSTRAINT CHK_SizeProfilePicture CHECK(DATALENGTH([ProfilePicture])<=900000),

	[LastLoginTime] DATETIME ,

	[IsDeleted] BIT 
	)


	INSERT INTO [Users] ([Username],[Password],[IsDeleted])
	VALUES
	('Tuing','123456',0),
	('REuytr','REWQaqsYT',1),
	('KIUYTRtre','12343457483647',0),
	('yrgfkp;','123456irubskduro',0),
	('Matrye','123ofjryh456',0)


	--	9 Change Primary Key

	

	DELETE FROM [Users];
	
	SELECT Name

	FROM sys.key_constraints

	WHERE TYPE='PK' AND parent_object_id = OBJECT_ID('Users');

	ALTER TABLE [Users] DROP CONSTRAINT PK__Users__3214EC07F010B90E;

	ALTER TABLE [Users] ADD CONSTRAINT RK_Users PRIMARY  KEY CLUSTERED ([Id],[Username]);

	--10 Add Check Constraint
  
  ALTER TABLE [Users] 
  ADD CONSTRAINT CHK_LenghtPassword 
  CHECK (LEN([Password])>=5);


  --11.	Set Default Value of a Field

  ALTER TABLE [Users] 
  ADD CONSTRAINT DF_LastLoginTime DEFAULT  GETDATE() FOR [LastLoginTime];

  --12.	Set Unique Field

ALTER TABLE [Users] DROP CONSTRAINT RK_Users;

ALTER TABLE [Users] ADD CONSTRAINT PK_Users PRIMARY KEY CLUSTERED ([Id]);

ALTER TABLE [Users] ADD CONSTRAINT CHK_LengthUsername
CHECK (LEN([Username])>=3);


--13.	Movies Database

CREATE DATABASE [Movies];

USE [Movies];



CREATE TABLE [Directors] (
[Id] INT PRIMARY KEY IDENTITY,
[DirectorName] NVARCHAR(50) NOT NULL,
[Notes] NVARCHAR(MAX)
);

CREATE TABLE [Genres](
[Id] INT PRIMARY KEY IDENTITY,
[GenreName] NVARCHAR(50) NOT NULL,
[Notes] NVARCHAR(MAX)
);

CREATE TABLE[Categories](
[Id] INT PRIMARY KEY IDENTITY,
[CategoryName] NVARCHAR(50) NOT NULL,
[Notes] NVARCHAR(MAX)
);



CREATE TABLE [Movies](
[Id] INT PRIMARY KEY IDENTITY,
[Title] NVARCHAR(50) NOT NULL,
[DirectorId] INT FOREIGN KEY REFERENCES [Directors]([Id]) NOT NULL,
[CopyrightYear] DATE NOT NULL,
[Length] DECIMAL(3,2),
[GenreId] INT FOREIGN KEY REFERENCES[Genres]([Id]) NOT NULL,
[CategoryId] INT FOREIGN KEY REFERENCES[Categories]([Id]),
[Rating] DECIMAL(3,1),
[Notes] NVARCHAR(MAX)
);


INSERT INTO [Directors] ([DirectorName])
VALUES 
('[DirectorName1]'),
('[DirectorName2]'),
('[DirectorName3]'),
('[DirectorName4]'),
('[DirectorName5]');

INSERT INTO [Genres]([GenreName])
VALUES
('Драма'),
('Комедия'),
('Екшън'),
('Трилър'),
('Научна фантастика');

INSERT INTO [Categories]([CategoryName])
VALUES
('Романтичен'),
('Ужаси'),
('Фантастичен'),
('Анимация'),
('Документален');


INSERT INTO [Movies]([Title],[DirectorId],[CopyrightYear],[Length],[GenreId],[CategoryId],[Rating])
VALUES
('Title1',1,'1587',2.30,1,1,5.9),
('Title2',2,'1687',1.30,2,2,6.9),
('Title3',3,'1787',0.30,3,NULL,9.9),
('Title4',4,'1887',2.55,4,4,NULL),
('Title5',5,'1987',2.37,5,5,5.9);

--14. Car Rental Database

CREATE DATABASE [CarRental]

USE [CarRental];


CREATE TABLE [Categories](
[Id] INT PRIMARY KEY IDENTITY,
[CategoryName] NVARCHAR(50) NOT NULL,
[DailyRate] DECIMAL(6,2) NOT NULL,
[WeeklyRate] DECIMAL(6,2) NOT NULL,
[MonthlyRate] DECIMAL (6,2) NOT NULL,
[WeekendRate] DECIMAL (6,2) NOT NULL
);

CREATE TABLE [Cars](
[Id] INT PRIMARY KEY IDENTITY,
[PlateNumber] VARCHAR(30) NOT NULL,
[Manufacturer] VARCHAR(30) NOT NULL,
[Model] VARCHAR(30) NOT NULL,
[CarYear] DATE NOT NULL,
[CategoryId] INT FOREIGN KEY REFERENCES [Categories]([Id]) NOT NULL,
[Doors] INT NOT NULL,
[Picture] VARBINARY(MAX),
[Condition] VARCHAR(MAX),
[Available] BIT NOT NULL
);

CREATE TABLE [Employees](
[Id] INT PRIMARY KEY IDENTITY,
[FirstName] NVARCHAR(50) NOT NULL,
[LastName] NVARCHAR(50) NOT NULL,
[Title] NVARCHAR(50) NOT NULL,
[Notes] NVARCHAR(MAX)
);

CREATE TABLE[Customers](
[Id] INT PRIMARY KEY IDENTITY,
[DriverLicenceNumber] VARCHAR(50) NOT NULL,
[FullName] NVARCHAR(200) NOT NULL,
[Address] NVARCHAR (500) NOT NULL,
[City] NVARCHAR(100) NOT NULL,
[ZIPCode] NVARCHAR(50) NOT NULL,
[Notes] NVARCHAR(MAX)
);

CREATE TABLE[RentalOrders](
[Id] INT PRIMARY KEY IDENTITY,
[EmployeeId] INT FOREIGN KEY REFERENCES [Employees]([Id]) NOT NULL,
[CustomerId] INT FOREIGN KEY REFERENCES [Customers]([Id]) NOT NULL,
[CarId] INT FOREIGN KEY REFERENCES [Cars]([Id]) NOT NULL,
[TankLevel] INT NOT NULL,
[KilometrageStart] INT NOT NULL,
[KilometrageEnd] INT NOT NULL,
[TotalKilometrage] AS [KilometrageEnd]-[KilometrageStart],
[StartDate] DATE NOT NULL,
[EndDate] DATE NOT NULL,
[TotalDays] AS (DATEDIFF(DAY,[StartDate],[EndDate])),
[RateApplied] DECIMAL(5,2) NOT NULL,
[TaxRate] DECIMAL(4,2) NOT NULL,
[OrderStatus] NVARCHAR(MAX),
[Notes] NVARCHAR(MAX)
);

INSERT INTO [Categories] ([CategoryName],[DailyRate],[WeeklyRate],[MonthlyRate],[WeekendRate])
     VALUES
	        ('[CategoryName1]',20,30,40,50),
			('[CategoryName2]',30,40,50,60),
			('[CategoryName3]',40,50,60,70);

INSERT INTO [Cars]([PlateNumber],[Manufacturer],[Model],[CarYear],[CategoryId],[Doors],[Available])
VALUES
('CA1111AS','Manufacturer1','Model1','2000',1,3,1),
('CA2222AS','Manufacturer2','Model2','2010',1,3,1),
('CA3333AS','Manufacturer3','Model3','2020',1,3,1);

INSERT INTO [Employees]([FirstName],[LastName],[Title])
VALUES
('FirstName1','LastName1','Title1'),
('FirstName2','LastName2','Title2'),
('FirstName3','LastName3','Title3');

INSERT INTO [Customers]([DriverLicenceNumber],[FullName],[Address],[City],[ZIPCode])
VALUES
('DriverNumber1','FullName1','Address1','City1','ZIPCode1'),
('DriverNumber2','FullName2','Address2','City2','ZIPCode2'),
('DriverNumber3','FullName3','Address3','City3','ZIPCode3');

INSERT INTO [RentalOrders] ([EmployeeId],[CustomerId],[CarId],[TankLevel],
            [KilometrageStart],[KilometrageEnd],[StartDate],[EndDate],[RateApplied],[TaxRate])
	 VALUES
	        (1,1,1,20,100000,100100,'2000-01-15','2000-01-20',25.20,12.50),
			(2,2,2,30,100000,100200,'2000-02-15','2000-02-20',35.20,22.50),
			(3,3,3,40,100000,100300,'2000-10-15','2000-11-20',45.20,32.50);

--15. Hotel Database

CREATE DATABASE [Hotel];

USE [Hotel];



CREATE TABLE [Employees](
[Id] INT PRIMARY KEY IDENTITY,
[FirstName] VARCHAR(50) NOT NULL,
[LastName] VARCHAR(50) NOT NULL,
[Title] VARCHAR(50) NOT NULL,
[Notes] VARCHAR(MAX)
);



CREATE TABLE [Customers](
[AccountNumber]  INT PRIMARY KEY IDENTITY,
[FirstName] NVARCHAR(50) NOT NULL,
[LastName] NVARCHAR(50) NOT NULL,
[PhoneNumber] VARCHAR(30) NOT NULL,
[EmergencyName] NVARCHAR (100) NOT NULL,
[EmergencyNumber] NVARCHAR(30) NOT NULL,
[Notes] NVARCHAR (MAX)
);


CREATE TABLE [RoomStatus](
[Id] INT PRIMARY KEY IDENTITY,
[RoomStatus] NVARCHAR(50) UNIQUE NOT NULL,
[Notes] NVARCHAR(MAX)
);


CREATE TABLE[RoomTypes] (
[Id] INT PRIMARY KEY IDENTITY,
[RoomType] NVARCHAR(50) UNIQUE NOT NULL,
[Notes] NVARCHAR(MAX)
);


CREATE TABLE [BedTypes](
[Id] INT PRIMARY KEY IDENTITY,
[BedType] NVARCHAR (50) UNIQUE NOT NULL,
[Notes] NVARCHAR(MAX)
);


CREATE TABLE[Rooms](
[Id] INT PRIMARY KEY IDENTITY,
[RoomNumber] NVARCHAR(20) UNIQUE NOT NULL,
[RoomType] INT FOREIGN KEY REFERENCES[RoomTypes]([Id]) NOT NULL,
[BedType] INT FOREIGN KEY REFERENCES[BedTypes]([Id]) NOT NULL,
[Rate] DECIMAL(5,2) NOT NULL,
[RoomStatus] INT FOREIGN KEY REFERENCES[RoomStatus]([Id]) NOT NULL,
[Notes] NVARCHAR(MAX)
);

CREATE TABLE[Payments](
[Id] INT PRIMARY KEY IDENTITY,
[EmployeeId] INT FOREIGN KEY REFERENCES [Employees]([Id]) NOT NULL,
[PaymentDate] datetime2 NOT NULL,
[AccountNumber] INT FOREIGN KEY REFERENCES [Customers]([AccountNumber]) NOT NULL,
[FirstDateOccupied] DATETIME2 NOT NULL,
[LastDateOccupied] DATETIME2 NOT NULL,
[TotalDays] AS (DATEDIFF(DAY,[FirstDateOccupied],[LastDateOccupied])),
[AmountCharged] DECIMAL (6,2) NOT NULL,
[TaxRate] DECIMAL(3,2) NOT NULL,
[TaxAmount] AS([AmountCharged]*[TaxRate]),
[PaymentTotal] AS([AmountCharged]*[TaxRate]+[AmountCharged]),
[Notes] NVARCHAR (MAX)
);

CREATE TABLE[Occupancies](
[Id] INT PRIMARY KEY IDENTITY,
[EmployeeId] INT FOREIGN KEY REFERENCES [Employees]([Id]) NOT NULL,
[DateOccupied] DATETIME2 NOT NULL,
[AccountNumber] INT FOREIGN KEY REFERENCES [Customers]([AccountNumber]) NOT NULL,
[RoomNumber] INT FOREIGN KEY REFERENCES [Rooms]([Id]) NOT NULL,
[RateApplied] DECIMAL (6,2) NOT NULL,
[PhoneCharge] NVARCHAR(20) NOT NULL,
[Notes] NVARCHAR (MAX)
);



INSERT INTO[Employees] ([FirstName],[LastName],[Title])
VALUES
('FirstName1','LastName1','Title1'),
('FirstName2','LastName2','Title2'),
('FirstName3','LastName3','Title3');


INSERT INTO [Customers]([FirstName],[LastName],[PhoneNumber],[EmergencyName],[EmergencyNumber])
VALUES
('FirstName1','LastName1','PhoneNumber1','EmergencyName1','EmergencyNumber1'),
('FirstName2','LastName2','PhoneNumber2','EmergencyName2','EmergencyNumber2'),
('FirstName3','LastName3','PhoneNumber3','EmergencyName3','EmergencyNumber3');



INSERT INTO [RoomStatus]([RoomStatus])
VALUES
('RoomStatus1'),
('RoomStatus2'),
('RoomStatus3');


INSERT INTO[RoomTypes]([RoomType])
VALUES
('RoomType1'),
('RoomType2'),
('RoomType3');

INSERT INTO [BedTypes]([BedType])
VALUES
('BedType1'),
('BedType2'),
('BedType3');


INSERT INTO [Rooms]([RoomNumber],[RoomType],[BedType],[Rate],[RoomStatus])
VALUES
('[RoomNumber1]',1,1,12.50,1),
('[RoomNumber2]',2,2,22.50,2),
('[RoomNumber3]',3,3,32.50,3);



INSERT INTO[Payments]([EmployeeId],[PaymentDate],[AccountNumber],[FirstDateOccupied],[LastDateOccupied],[AmountCharged],[TaxRate])
VALUES
(1,'2024-07-05',1,'2024-07-21','2024-07-23',100,0.05),
(2,'2024-07-05',2,'2024-07-21','2024-07-28',100,0.05),
(3,'2024-07-05',3,'2024-07-21','2024-07-30',100,0.05);


--	Occupancies (Id, EmployeeId, DateOccupied, AccountNumber, RoomNumber, RateApplied, PhoneCharge, Notes)

INSERT INTO [Occupancies]([EmployeeId],[DateOccupied],[AccountNumber],[RoomNumber],[RateApplied],[PhoneCharge])
VALUES
(1,'2024-07-05',1,1,10.25,'08988888'),
(2,'2024-07-05',2,2,10.25,'08988888'),
(3,'2024-07-05',3,3,10.25,'08988888');


--16.	Create SoftUni Database

CREATE DATABASE [SoftUni];

USE [SoftUni];

--•	Towns (Id, Name)

CREATE TABLE [Towns](
[Id] INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(70) NOT NULL,
);

--•	Addresses (Id, AddressText, TownId)

CREATE TABLE[Addresses] (
[Id] INT PRIMARY KEY IDENTITY,
[AddressText] NVARCHAR(1000) NOT NULL,
[TownId] INT FOREIGN KEY REFERENCES[Towns]([Id])  NOT NULL,
);

--•	Departments (Id, Name)

CREATE TABLE [Departments](
[Id] INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR (100) NOT NULL
);



CREATE TABLE [Employees] (
[Id] INT PRIMARY KEY IDENTITY,
[FirstName] NVARCHAR (50) NOT NULL,
[MiddleName] NVARCHAR (50) NOT NULL,
[LastName] NVARCHAR (50) NOT NULL,
[JobTitle] NVARCHAR (50) NOT NULL,
[DepartmentId] INT FOREIGN KEY REFERENCES [Departments]([Id]) NOT NULL,
[HireDate] NVARCHAR(10) NOT NULL,
[Salary] DECIMAL(7,2) NOT NULL,
[AddressId] INT FOREIGN KEY REFERENCES [Addresses]([Id]) 
);



--18.	Basic Insert


INSERT INTO [Towns]([Name])
VALUES
('Sofia'),('Plovdiv'),('Varna'),('Burgas');



INSERT INTO[Departments]([Name])
VALUES
('Engineering'),('Sales'),('Marketing'),('Software Development'),('Quality Assurance');



INSERT INTO [Employees] ([FirstName],[MiddleName],[LastName],[JobTitle],[DepartmentId],[HireDate],[Salary])
VALUES
('Ivan','Ivanov','Ivanov','.NET Developer',4,'01/02/2013',3500.00),
('Petar','Petrov','Petrov','Senior Engineer',1,'02/03/2004',4000.00),
('Maria','Petrova','Ivanova','Intern',5,'28/08/2016',525.25),
('Georgi','Teziev','Ivanov','CEO',2,'09/12/2007',3000.00),
('Peter','Pan','Pan','Intern',3,'28/08/2016',599.88);

--19. Basic Select All Fields

SELECT * FROM [Towns];

SELECT * FROM [Departments];

SELECT * FROM [Employees];

--20. Basic Select All Fields and Order Them

SELECT * FROM[Towns] ORDER BY [Name];
SELECT *FROM[Departments] ORDER BY [Name];
SELECT *FROM [Employees] ORDER BY [Salary] DESC;

--21. Basic Select Some Fields

SELECT [Name] FROM [Towns] ORDER BY[Name];
SELECT [Name] FROM [Departments] ORDER BY [Name];
SELECT [FirstName],[LastName],[JobTitle],[Salary] FROM [Employees] ORDER BY [Salary] DESC;

--22. Increase Employees Salary

UPDATE [Employees]
SET [Salary]=[Salary]*1.1;

SELECT [Salary] FROM [Employees];

--23. Decrease Tax Rate

USE Hotel 

UPDATE [Payments]
SET[TaxRate]-=0.03;

SELECT [TaxRate] FROM [Payments];