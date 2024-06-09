﻿ CREATE DATABASE TouristAgency

 --01. DDL
	
	CREATE TABLE Countries(
	Id INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR (50) NOT NULL
	);


	

	CREATE TABLE Destinations (
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR (50) NOT NULL
	,CountryId INT FOREIGN KEY REFERENCES Countries(Id) NOT NULL
	);


	CREATE TABLE Rooms(
	 Id INT PRIMARY KEY IDENTITY
	,Type VARCHAR (40) NOT NULL
	,Price DECIMAL (18,2) NOT NULL
	,BedCount INT CHECK (BedCount> 0 AND BedCount<=10) NOT NULL
	);



	CREATE TABLE Hotels(
	 Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR (50) NOT NULL
	,DestinationId INT FOREIGN KEY REFERENCES Destinations(Id) NOT NULL
	);


	CREATE TABLE Tourists(
	 Id INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR (80) NOT NULL
	,PhoneNumber VARCHAR (20)NOT NULL
	,Email VARCHAR (80)
	,CountryId INT FOREIGN KEY REFERENCES Countries(Id) NOT NULL
	);


	CREATE TABLE Bookings(
	 Id INT PRIMARY KEY IDENTITY
	 ,ArrivalDate DATETIME2 NOT NULL
	 ,DepartureDate DATETIME2 NOT NULL
	 ,AdultsCount INT CHECK (AdultsCount>=1 AND AdultsCount<=10) NOT NULL
	 ,ChildrenCount INT CHECK (ChildrenCount>=0 AND ChildrenCount<=9) NOT NULL
	 ,TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL
	  ,HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL
	   ,RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL
	);


	CREATE TABLE HotelsRooms(
	HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL
	,RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL
	,PRIMARY KEY (HotelId,RoomId)
	);

	--02. Insert


	INSERT INTO Tourists([Name],PhoneNumber,Email,CountryId)
	VALUES
	 ('John Rivers','653-551-1555','john.rivers@example.com',6)
	,('Adeline Aglaé','122-654-8726','adeline.aglae@example.com',2)
	,('Sergio Ramirez','233-465-2876','s.ramirez@example.com',3)
	,('Johan Müller','322-876-9826','j.muller@example.com',7)
	,('Eden Smith','551-874-2234','eden.smith@example.com',	6);



	INSERT INTO Bookings(ArrivalDate, DepartureDate, AdultsCount, ChildrenCount, TouristId, HotelId, RoomId)
	VALUES
	('2024-03-01', '2024-03-11', 1,	0, 21, 3, 5)
	,('2023-12-28',	'2024-01-06', 2, 1, 22, 13, 3)
	,('2023-11-15', '2023-11-20',1,	2, 23, 19, 7);

	--03. Update

	

	UPDATE Bookings
	SET DepartureDate=DATEADD(DAY,1,DepartureDate)
	WHERE ArrivalDate>='2023-12-01'AND ArrivalDate<='2023-12-31'

	
	UPDATE Tourists
	SET Email=NULL
	WHERE Email LIKE '%MA%' 


	--04. Delete
	

	DELETE
	FROM Bookings
	WHERE TouristId IN(6,16,25)

	DELETE
	FROM Tourists
	WHERE [Name]LIKE '%Smith'

	--05. Bookings by Price of Room and Arrival Date

	SELECT 
	 FORMAT( ArrivalDate,'yyyy-MM-dd') AS 	ArrivalDate
	,AdultsCount
	,ChildrenCount
	FROM Bookings AS b
	JOIN Rooms AS r ON b.RoomId=r.Id
	ORDER BY r.Price DESC ,ArrivalDate

	--06. Hotels by Count of Bookings

	SELECT
	h.Id
	,h.Name 
	FROM Hotels AS h
	JOIN HotelsRooms AS hr ON hr.HotelId=h.Id
	JOIN Rooms AS r ON r.Id=hr.RoomId
	JOIN Bookings AS b ON b.HotelId =h.Id
	WHERE r.Type='VIP Apartment'
	GROUP BY h.Id ,h.Name 
	ORDER BY COUNT(b.Id) DESC

	--07. Tourists without Bookings

	SELECT
	t.Id
	,t.Name
	,t.PhoneNumber
	FROM Tourists AS t
	LEFT JOIN Bookings AS b ON b.TouristId=t.Id
	WHERE b.Id IS NULL
	ORDER BY t.Name 

	--08. First 10 Bookings



	SELECT TOP 10
	h.Name AS HotelName
	,d.Name AS DestinationName
	,c.Name AS CountryName
	FROM Bookings AS b
	JOIN Hotels AS h ON b.HotelId=h.Id
	JOIN Destinations AS d ON d.Id=h.DestinationId
	JOIN Countries AS c ON c.Id=d.CountryId
	WHERE ArrivalDate<'2023-12-31'AND h.Id%2=1
	ORDER BY CountryName,b.ArrivalDate


	--09. Tourists booked in Hotels
	
	SELECT
	h.Name AS HotelName
	,r.Price AS RoomPrice
	FROM Tourists AS t
	JOIN Bookings AS b ON t.Id=b.TouristId
	JOIN Hotels AS h ON h.Id=b.HotelId
	JOIN Rooms AS r ON r.Id =b.RoomId
	WHERE t.Name NOT LIKE'%EZ'
	ORDER BY RoomPrice DESC

	--10. Hotels Revenue
	
	SELECT 
	h.Name AS HotelName
	,SUM(DATEDIFF (DAY,ArrivalDate,DepartureDate)*r.Price) AS HotelRevenue
	FROM Bookings AS b
	JOIN Hotels AS h ON h.Id=b.HotelId
	JOIN Rooms AS r ON r.Id=b.RoomId
	GROUP BY h.Name
	ORDER BY HotelRevenue DESC

	--11. Rooms with Tourists

	CREATE OR ALTER FUNCTION udf_RoomsWithTourists(@name VARCHAR(40)) 
	RETURNS INT
	AS 
	BEGIN
	DECLARE @totalNumberTourists INT
	SELECT @totalNumberTourists=
	SUM(b.AdultsCount)+SUM(ChildrenCount) 
	FROM Bookings AS b
	JOIN Rooms AS r ON r.Id=b.RoomId
	WHERE r.[Type]=@name
	RETURN @totalNumberTourists
	END

	--12. Search for Tourists from a Specific Country

	
	CREATE PROCEDURE usp_SearchByCountry @country NVARCHAR(50)
	AS 
	SELECT
	t.Name
	,t.PhoneNumber
	,t.Email
	,COUNT(b.Id) AS CountOfBookings
	FROM Tourists AS t
	JOIN Countries AS c ON c.Id=t.CountryId
	JOIN Bookings AS b ON b.TouristId = t.Id
	WHERE c.Name=@country
	GROUP BY t.Name,t.PhoneNumber,t.Email
	ORDER BY t.Name, CountOfBookings DESC
	
