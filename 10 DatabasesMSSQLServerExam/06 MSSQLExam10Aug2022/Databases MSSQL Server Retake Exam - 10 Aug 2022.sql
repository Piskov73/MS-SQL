CREATE DATABASE NationalTouristSitesOfBulgaria

 --01. DDL


	CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY
	,Name VARCHAR (50) NOT NULL
	);



	CREATE TABLE Locations(
	Id INT PRIMARY KEY IDENTITY
	,Name VARCHAR (50) NOT NULL
	,Municipality VARCHAR (50) 
	,Province VARCHAR (50)
	);


	CREATE TABLE Sites(
	Id INT PRIMARY KEY IDENTITY
	,Name VARCHAR (100) NOT NULL
	,LocationId INT FOREIGN KEY REFERENCES Locations(Id) NOT NULL
	,CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL
	,Establishment VARCHAR (15) 
	);


	CREATE TABLE Tourists (
		Id INT PRIMARY KEY IDENTITY
	   ,Name VARCHAR (50) NOT NULL
	   ,Age INT CHECK(Age>=0 AND Age<=120) NOT NULL
	   ,PhoneNumber VARCHAR (20) NOT NULL
	   ,Nationality VARCHAR (30) NOT NULL
	   ,Reward VARCHAR (20) 
	);


	CREATE TABLE SitesTourists(
	TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL
	,SiteId INT FOREIGN KEY REFERENCES Sites(Id) NOT NULL
	PRIMARY KEY (TouristId,SiteId)
	);


	CREATE TABLE BonusPrizes(
	    Id INT PRIMARY KEY IDENTITY
	   ,Name VARCHAR (50) NOT NULL
	);



	CREATE TABLE TouristsBonusPrizes(
	TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL
	,BonusPrizeId INT FOREIGN KEY REFERENCES BonusPrizes(Id) NOT NULL
	PRIMARY KEY (TouristId,BonusPrizeId)
	);

	--02. Insert


	
	INSERT INTO Tourists(Name, Age, PhoneNumber, Nationality, Reward)
		VALUES
		 ('Borislava Kazakova', 52,	'+359896354244', 'Bulgaria', NULL)
		,('Peter Bosh',	48,	'+447911844141', 'UK',	NULL)
		,('Martin Smith', 29,	'+353863818592','Ireland',	'Bronze badge')
		,('Svilen Dobrev',	49,	'+359986584786', 'Bulgaria','Silver badge')
		,('Kremena Popova',	38,	'+359893298604',	'Bulgaria',	NULL);



	INSERT INTO Sites(Name,	LocationId,	CategoryId	,Establishment)
	VALUES
	('Ustra fortress',	90	,7,'X')
	,('Karlanovo Pyramids',	65,	7,	NULL)
	,('The Tomb of Tsar Sevt',	63,	8,	'V BC')
	,('Sinite Kamani Natural Park',	17,	1,	NULL)
	,('St. Petka of Bulgaria – Rupite',	92	,6	,'1994');

	--03. Update

	UPDATE Sites
	SET Establishment='not defined'
	WHERE Establishment IS NULL

	--04. Delete
	
	DELETE 
	FROM TouristsBonusPrizes
	WHERE BonusPrizeId=5

	DELETE
	FROM BonusPrizes
	WHERE Name  ='Sleeping bag'

	--05. Tourists

	

	SELECT
	Name
	,Age
	,PhoneNumber
	,Nationality
	FROM Tourists
	ORDER BY Nationality,Age DESC,Name

	--06. Sites with Their Location and Category

	SELECT
	s.Name AS Site
	,l.Name AS Location
	,s.Establishment
	,c.Name AS Category
	FROM Sites AS s 
	JOIN Locations AS l ON l.Id=s.LocationId
	JOIN Categories AS c ON c.Id=s.CategoryId
	ORDER BY Category DESC ,Location,Site

	--07. Count of Sites in Sofia Province
	
	

	SELECT
	l.Province
	,L.Municipality
	,l.Name AS Location
	,COUNT(s.Id) AS CountOfSites
	FROM Locations AS l
	JOIN Sites AS s ON s.LocationId=l.Id
	WHERE l.Province='Sofia'
	GROUP BY l.Province,l.Municipality,l.Name
	ORDER BY CountOfSites DESC,Location

	--08. Tourist Sites established BC

	

	SELECT
	s.Name AS Site
	,l.Name AS Location
	,l.Municipality
	,l.Province
	,Establishment
	FROM Sites AS s
	JOIN Locations AS l ON s.LocationId=l.Id
	WHERE l.Name NOT LIKE 'B%' 
	  AND l.Name NOT LIKE 'M%' 
	  AND l.Name NOT LIKE 'D%'
	  AND Establishment LIKE '%BC'
	ORDER BY Site

	--09. Tourists with their Bonus Prizes


	SELECT
	t.Name
	,t.Age
	,t.PhoneNumber
	,t.Nationality
	,ISNULL(bp.Name,'(no bonus prize)') AS Reward
	FROM Tourists AS t
	LEFT JOIN TouristsBonusPrizes AS tb ON tb.TouristId=t.Id
	LEFT JOIN BonusPrizes AS bp ON bp.Id=tb.BonusPrizeId
	ORDER BY t.Name

	--10. Tourists visiting History & Archaeology sites

	

	SELECT
	SUBSTRING(t.Name,CHARINDEX(' ',t.Name)+1,LEN(t.Name)) AS LastName
	,t.Nationality
	,t.Age
	,t.PhoneNumber
	FROM Tourists AS t
	JOIN SitesTourists AS st ON st.TouristId=t.Id
	JOIN Sites AS s ON s.Id=st.SiteId
	JOIN Categories AS c ON s.CategoryId=c.Id
	WHERE c.Name='History and archaeology'
	GROUP  BY SUBSTRING(t.Name,CHARINDEX(' ',t.Name)+1,LEN(t.Name))
	,t.Nationality
	,t.Age
	,t.PhoneNumber
	ORDER BY LastName

	--Second option

	SELECT DISTINCT
    SUBSTRING(t.Name, CHARINDEX(' ', t.Name) + 1, LEN(t.Name)) AS LastName,
    t.Nationality,
    t.Age,
    t.PhoneNumber
FROM Tourists AS t
JOIN SitesTourists AS st ON st.TouristId = t.Id
JOIN Sites AS s ON s.Id = st.SiteId
JOIN Categories AS c ON s.CategoryId = c.Id
WHERE c.Name = 'History and archaeology'
ORDER BY LastName ;

--11. Tourists Count on a Tourist Site

	CREATE FUNCTION udf_GetTouristsCountOnATouristSite (@Site VARCHAR(100)) 
	RETURNS INT
	AS
	BEGIN
	DECLARE @countTourists INT 
	SELECT @countTourists=
	COUNT(*) 
	FROM Sites AS s
	JOIN SitesTourists AS st ON s.Id=st.SiteId 
	WHERE s.Name=@Site
	RETURN @countTourists
	END;


	--12. Annual Reward Lottery

	
	CREATE PROCEDURE usp_AnnualRewardLottery
	@TouristName VARCHAR(50) 
	AS
	SELECT
	t.Name,
	CASE
	WHEN COUNT(*)>=100 THEN 'Gold badge'
	WHEN COUNT(*)>=50 THEN 'Silver badge'
	WHEN COUNT(*)>=25 THEN 'Bronze badge'
	ELSE NULL
	END AS Reward
	FROM Tourists AS t
	JOIN SitesTourists AS st ON t.Id=st.TouristId
	WHERE t.Name=@TouristName
	GROUP BY t.Name

	