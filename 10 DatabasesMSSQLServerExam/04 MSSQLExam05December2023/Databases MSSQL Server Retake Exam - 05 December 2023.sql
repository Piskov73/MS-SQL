CREATE DATABASE RailwaysDb

	--01. DDL
 
   CREATE TABLE Passengers(
     Id INT PRIMARY KEY IDENTITY
    ,[Name] NVARCHAR (80) NOT NULL
   );

   CREATE TABLE Towns(
     Id INT PRIMARY KEY IDENTITY
    ,[Name] VARCHAR (30) NOT NULL
   );

 

	CREATE TABLE RailwayStations(
	  Id INT PRIMARY KEY IDENTITY
     ,[Name] VARCHAR (50) NOT NULL
     ,TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL
	);

	CREATE TABLE  Trains(
	  Id INT PRIMARY KEY IDENTITY
	 ,HourOfDeparture VARCHAR(5) NOT NULL
	 ,HourOfArrival VARCHAR(5) NOT NULL
	 ,DepartureTownId INT  FOREIGN KEY REFERENCES Towns(Id) NOT NULL
	 ,ArrivalTownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL
	);

	

	CREATE TABLE TrainsRailwayStations(
	  TrainId INT  FOREIGN KEY REFERENCES Trains(Id) NOT NULL
	 ,RailwayStationId INT  FOREIGN KEY REFERENCES RailwayStations(Id) NOT NULL
	 ,PRIMARY KEY(TrainId,RailwayStationId)
	);


	CREATE TABLE MaintenanceRecords(
	  Id INT PRIMARY KEY IDENTITY
	 ,DateOfMaintenance DATE NOT NULL
	 ,Details VARCHAR (2000) NOT NULL
	 ,TrainId INT  FOREIGN KEY REFERENCES Trains(Id) NOT NULL
	);



	CREATE TABLE Tickets(
	  Id INT PRIMARY KEY IDENTITY
	 ,Price DECIMAL (18,2) NOT NULL
	 ,DateOfDeparture DATE NOT NULL
	 ,DateOfArrival DATE NOT NULL
	 ,TrainId INT  FOREIGN KEY REFERENCES Trains(Id) NOT NULL
	 ,PassengerId INT  FOREIGN KEY REFERENCES Passengers(Id) NOT NULL
	);

	--02. Insert



	INSERT INTO Trains(HourOfDeparture,HourOfArrival,DepartureTownId,ArrivalTownId)
	VALUES
	('07:00','19:00',1,3)
	,('08:30','20:30',5,6)
	,('09:00','21:00',4,8)
	,('06:45','03:55',27,7)
	,('10:15','12:15',15,5);
	


	INSERT INTO TrainsRailwayStations(TrainId,RailwayStationId)
	VALUES
	(36,1),(36,4),(36,31),(36,57),(36,7),(36,13),(37,54)
	,(37,60),(37,16),(38,10),(38,50),(38,52),(38,22),(39,68)
	,(39,3),(39,31),(39,19),(40,41),(40,7),(40,52),(40,13);



	INSERT INTO Tickets(Price,DateOfDeparture,DateOfArrival,TrainId,PassengerId)
	VALUES
	(90.00,'2023-12-01','2023-12-01',36,1)
	,(115.00,'2023-08-02','2023-08-02',37,2)
	,(160.00,'2023-08-03','2023-08-03',38,3)
	,(255.00,'2023-09-01','2023-09-02',39,21)
	,(95.00,'2023-09-02','2023-09-03',40,22);

	--03. Update

	

	UPDATE Tickets
	SET
	DateOfDeparture=DATEADD(DAY,7,DateOfDeparture)
	,DateOfArrival=DATEADD(DAY,7,DateOfArrival)
	WHERE DateOfDeparture>'2023-10-31'


	--04. Delete
	

	DELETE 
	FROM TrainsRailwayStations
	WHERE TrainId=7

	DELETE
	FROM MaintenanceRecords
	WHERE TrainId=7

	DELETE
	FROM Tickets
	WHERE TrainId=7

	DELETE 
	FROM Trains
	WHERE DepartureTownId=3


	--05. Tickets by Price and Date Departure

	SELECT 
	DateOfDeparture
	,Price
	FROM Tickets
	ORDER BY Price,DateOfDeparture DESC


	--06. Passengers with their Tickets

		SELECT 
			 p.Name AS 	PassengerName
			,t.Price AS 	TicketPrice
			,t.DateOfDeparture
			,t.TrainId AS 	TrainID
		FROM Tickets AS t
			JOIN Passengers AS p ON t.PassengerId=p.Id
		ORDER BY t.Price DESC,p.Name



		--07. Railway Stations without Passing Trains

	SELECT
	    t.Name AS Town
		,rs.Name RailwayStation
	  FROM RailwayStations AS rs
	  LEFT JOIN TrainsRailwayStations AS tr ON tr.RailwayStationId=rs.Id
	  JOIN Towns AS t ON rS.TownId=t.Id
	  WHERE tr.TrainId IS NULL
	  ORDER BY t.Name,rs.Name

	--08. First 3 Trains Between 08:00 and 08:59

	
	SELECT TOP 3
	t.Id AS TrainId
	,t.HourOfDeparture
	,ti.Price AS TicketPrice
	,tow.Name AS Destination
	FROM Trains AS t
	JOIN Towns AS tow ON t.ArrivalTownId=tow.Id
	JOIN Tickets AS ti ON ti.TrainId=t.Id
	WHERE CONVERT(time,t.HourOfDeparture) >= '8:00'AND CONVERT(time,t.HourOfDeparture)<='08:59'AND ti.Price>50.00
	ORDER BY ti.Price

	--09. Count of Passengers Paid More Than Average

	SELECT 
	t.Name AS TownName
	,COUNT(*) AS PassengersCount
	FROM Towns AS t
	JOIN Trains AS tr ON tr.ArrivalTownId =t.Id
	JOIN Tickets AS ti ON ti.TrainId=tr.Id
	WHERE ti.Price>76.99
	GROUP BY t.Name 
	ORDER BY TownName

	--10. Maintenance Inspection with Town and Station

	

	SELECT 
	t.Id AS TrainID
	, tow.Name AS DepartureTown
	,mr.Details
	FROM Trains AS t
	JOIN Towns AS tow ON t.DepartureTownId=tow.Id
	JOIN MaintenanceRecords AS mr ON mr.TrainId=t.Id
	WHERE mr.Details LIKE '%inspection%'
	ORDER BY t.Id

	--11. Towns with Trains

	CREATE FUNCTION udf_TownsWithTrains(@name VARCHAR (30)) 
	    RETURNS INT 
	             AS 
	          BEGIN
	        DECLARE @result INT
	         SELECT  @result=
	          COUNT (*)
	           FROM Trains AS t
	           JOIN Towns AS tw ON tw.Id=t.DepartureTownId OR tw.Id=t.ArrivalTownId
	          WHERE tw.Name=@name 
	         RETURN @result
	            END


	--12. Search Passengers travelling to Specific Town

	
	CREATE  PROCEDURE usp_SearchByTown @townName VARCHAR(30)
	AS 
	SELECT
	p.Name AS  PassengerName
	,ti.DateOfDeparture
	,tr.HourOfDeparture
	FROM Towns AS tow
	JOIN Trains AS tr ON tr.ArrivalTownId=tow.Id
	JOIN Tickets AS ti ON ti.TrainId=tr.Id
	JOIN Passengers AS p ON p.Id=ti.PassengerId
	WHERE tow.Name=@townName
	ORDER BY ti.DateOfDeparture DESC,PassengerName
	

	