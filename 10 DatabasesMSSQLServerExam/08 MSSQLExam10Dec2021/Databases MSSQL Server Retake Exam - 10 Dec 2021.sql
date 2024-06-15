CREATE DATABASE Airport

USE Airport

--01. DDL
CREATE TABLE Passengers(
	Id INT PRIMARY KEY IDENTITY 
	,FullName VARCHAR (100)UNIQUE NOT NULL
	,Email VARCHAR (50)UNIQUE NOT NULL
	);


	CREATE TABLE Pilots(
	Id INT PRIMARY KEY IDENTITY 
	,FirstName VARCHAR (30)UNIQUE NOT NULL
	,LastName VARCHAR (30)UNIQUE NOT NULL
	,Age TINYINT CHECK(Age BETWEEN 21 AND 62) NOT NULL
	,Rating FLOAT CHECK(Rating BETWEEN 0.0 AND  10.0)
	);



	CREATE TABLE AircraftTypes(
	Id INT PRIMARY KEY IDENTITY 
	,TypeName VARCHAR (30)UNIQUE NOT NULL
	);

	

	CREATE TABLE Aircraft(
	Id INT PRIMARY KEY IDENTITY
	,Manufacturer VARCHAR (25) NOT NULL
	,Model VARCHAR (30) NOT NULL
	,[Year] INT NOT NULL
	,FlightHours INT 
	,Condition CHAR NOT NULL
	,TypeId INT FOREIGN KEY REFERENCES AircraftTypes(Id) NOT NULL
	);

	CREATE TABLE PilotsAircraft(
	AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL
	,PilotId INT FOREIGN KEY REFERENCES Pilots(Id) NOT NULL
	PRIMARY KEY (AircraftId,PilotId)
	);


	CREATE TABLE Airports(
	Id INT PRIMARY KEY IDENTITY
	,AirportName VARCHAR (70) UNIQUE NOT NULL
	,Country VARCHAR (100) UNIQUE NOT NULL
	);
	

	CREATE TABLE FlightDestinations(
	Id INT PRIMARY KEY IDENTITY
	,AirportId INT FOREIGN KEY REFERENCES Airports(Id) NOT NULL
	,[Start] DATETIME NOT NULL
	,AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL
	,PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL
	,TicketPrice DECIMAL(18,2) DEFAULT 15  NOT NULL 
	);

	--2.	Insert

	INSERT INTO Passengers (FullName,Email)
	SELECT
	CONCAT_WS(' ',FirstName,LastName) AS 	FullName  
	,CONCAT(FirstName,LastName,'@gmail.com')AS 	Email 
	FROM Pilots
	WHERE Id BETWEEN 5 AND 15


	--03. Update

	
	UPDATE Aircraft
	SET Condition='A'
	WHERE (Condition ='C' OR Condition='B' ) AND (FlightHours IS NULL OR FlightHours<=100) AND [Year]>=2013

	--04. Delete

	DELETE
	FROM Passengers
	WHERE LEN (FullName)<=10

	--05. Aircraft

	--Manufacturer	Model	FlightHours	Condition

	SELECT
	Manufacturer
	,Model
	,FlightHours
	,Condition
	FROM Aircraft
	ORDER BY FlightHours DESC

	--06. Pilots and Aircraft

	--FirstName	LastName	Manufacturer	Model	FlightHours

	SELECT
	p.FirstName
	,p.LastName
	,a.Manufacturer
	,a.Model
	,a.FlightHours
	FROM Pilots AS p
	JOIN PilotsAircraft AS pa ON p.Id=pa.PilotId
	JOIN Aircraft AS a ON pa.AircraftId=a.Id
	WHERE a.FlightHours IS NOT NULL AND A.FlightHours<=304
	ORDER BY a.FlightHours DESC, p.FirstName

	--07. Top 20 Flight Destinations

	--DestinationId	Start	FullName	AirportName	TicketPrice

	SELECT TOP 20
	f.Id AS DestinationId
	,f.Start
	,p.FullName
	,a.AirportName
	,f.TicketPrice
	FROM FlightDestinations AS f
	JOIN Airports AS a ON f.AirportId=a.Id
	JOIN Passengers AS p ON f.PassengerId=p.Id
	WHERE DATEPART(DAY, f.Start) % 2 = 0 
	ORDER BY f.TicketPrice DESC,a.AirportName;

	--08. Number of Flights for Each Aircraft

	--AircraftId	Manufacturer	FlightHours	FlightDestinationsCount	AvgPrice

	SELECT
	a.Id
	,a.Manufacturer
	,a.FlightHours
	,COUNT(fd.Id)AS FlightDestinationsCount
	,ROUND(AVG(fd.TicketPrice), 2) AS AvgPrice
	FROM Aircraft AS a
	JOIN FlightDestinations AS fd ON fd.AircraftId=a.Id
	GROUP BY a.Id,a.Manufacturer,a.FlightHours
	HAVING COUNT(fd.Id)>1
	ORDER BY FlightDestinationsCount DESC ,a.Id

	--09. Regular Passengers

	--FullName	CountOfAircraft	TotalPayed

	SELECT 
	p.FullName
	,COUNT(fd.Id) AS CountOfAircraft
	,SUM(fd.TicketPrice) AS TotalPayed
	FROM Passengers AS p
	JOIN FlightDestinations AS fd ON fd.PassengerId=p.Id
	WHERE SUBSTRING(p.FullName,2,1)='a'
	GROUP BY p.FullName
	HAVING COUNT(fd.Id)>1
	ORDER BY p.FullName

	--10. Full Info for Flight Destinations



	SELECT 
	a.AirportName
	,fd.Start
	,fd.TicketPrice
	,p.FullName
	,ai.Manufacturer
	,ai.Model
	FROM FlightDestinations AS fd
	JOIN Airports AS a ON a.Id=fd.AirportId
	JOIN Passengers AS p ON p.Id =fd.PassengerId
	JOIN Aircraft AS ai ON ai.Id=fd.AircraftId
	WHERE DATEPART(HOUR,fd.Start) BETWEEN 6.00 AND 20.00 AND fd.TicketPrice>2500
	ORDER BY ai.Model

	--11. Find all Destinations by Email Address
	CREATE OR ALTER FUNCTION  udf_FlightDestinationsByEmail(@email VARCHAR(50)) 
	RETURNS INT
	AS 
	BEGIN
	DECLARE @countsDestinations INT
	SELECT @countsDestinations=
	COUNT(f.Id)
	FROM Passengers AS p
	JOIN FlightDestinations AS f ON p.Id=f.PassengerId
	WHERE p.Email=@email
	GROUP BY p.Id
	IF @countsDestinations IS NULL
	SET @countsDestinations=0

	RETURN @countsDestinations
	END

	--12. Full Info for Airports

	--AirportName	FullName	LevelOfTickerPrice	Manufacturer	Condition	TypeName
	CREATE PROCEDURE usp_SearchByAirportName 	@airportName VARCHAR(70)
	AS
	SELECT
	a.AirportName
	,p.FullName
	,CASE
	WHEN f.TicketPrice<= 400 THEN 'Low'
	WHEN f.TicketPrice<= 1500 THEN 'Medium' 
	ELSE 'High' 
	END AS LevelOfTickerPrice
	,ai.Manufacturer
	,ai.Condition
	,at.TypeName
	FROM Airports AS a
	JOIN FlightDestinations AS f ON f.AirportId=a.Id
	JOIN Passengers AS p ON p.Id=f.PassengerId
	JOIN Aircraft AS ai ON ai.Id=f.AircraftId
	JOIN AircraftTypes AS at ON at.Id=ai.TypeId
	WHERE a.AirportName=@airportName
	ORDER BY ai.Manufacturer	,p.FullName
