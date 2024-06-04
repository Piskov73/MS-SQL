CREATE DATABASE Boardgames

 -- 1. DDL (30 pts)

	CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR (50) NOT NULL
	);


	CREATE TABLE Addresses(
	Id INT PRIMARY KEY IDENTITY
	,StreetName NVARCHAR(100) NOT NULL
	,StreetNumber INT NOT NULL
	,Town VARCHAR (30) NOT NULL
	,Country VARCHAR (50) NOT NULL
	,ZIP INT NOT NULL
	);


	CREATE TABLE Publishers(
	Id INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR(30) NOT NULL
	,AddressId INT NOT NULL FOREIGN KEY REFERENCES Addresses(Id)
	,Website NVARCHAR(40) 
	,Phone NVARCHAR (20) 
	);
	
	
	CREATE TABLE PlayersRanges(
	Id INT PRIMARY KEY IDENTITY
	,PlayersMin INT NOT NULL
	,PlayersMax INT NOT NULL
	);


	
	CREATE TABLE Boardgames(
	Id  INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR (30) NOT NULL
	,YearPublished INT NOT NULL
	,Rating DECIMAL (5,2) NOT NULL
	,CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(Id)
	,PublisherId INT NOT NULL FOREIGN KEY REFERENCES Publishers(Id)
	,PlayersRangeId INT NOT NULL FOREIGN KEY REFERENCES PlayersRanges(Id)
	);


	CREATE TABLE Creators(
	Id  INT PRIMARY KEY IDENTITY
	,FirstName NVARCHAR (30) NOT NULL
	,LastName NVARCHAR (30) NOT NULL
	,Email NVARCHAR (30) NOT NULL
	);


	CREATE TABLE CreatorsBoardgames(
	CreatorId INT NOT NULL FOREIGN KEY REFERENCES Creators(Id)
	,BoardgameId INT NOT NULL FOREIGN KEY REFERENCES Boardgames(Id)
	PRIMARY KEY(CreatorId,BoardgameId)
	);


	--2.	Insert



	 INSERT INTO Boardgames([Name],YearPublished,Rating,CategoryId,PublisherId,PlayersRangeId)
	 VALUES 
	 ('Deep Blue',2019,	5.67,1,	15 ,7)
	 ,('Paris',	2016,	9.78,	7,	1,	5)
	 ,('Catan: Starfarers',	2021,	9.87	,7	,13	,6)
	 ,('Bleeding Kansas',	2020,	3.25,	3,	7,	4)
	 ,('One Small Step',	2019,	5.75,	5,	9,	2);


	INSERT INTO Publishers([Name],	AddressId,	Website,	Phone)
	VALUES
	('Agman Games',	5	,'www.agmangames.com',	'+16546135542')
	,('Amethyst Games',	7,	'www.amethystgames.com',	'+15558889992')
	,('BattleBooks',	13	,'www.battlebooks.com',	'+12345678907');

	--03. Update

	

	UPDATE  PlayersRanges
	SET PlayersMax=3
	WHERE PlayersMin=2 AND PlayersMax=2

	

	UPDATE Boardgames
	SET [Name]= CONCAT([Name],'V2')
	WHERE YearPublished>=2020

	--04. Delete
	SELECT*
	FROM Addresses
	WHERE Town LIKE 'L%'

	SELECT*
	FROM Publishers
	WHERE AddressId=5

	SELECT *
	FROM Boardgames
	WHERE PublisherId IN (1,16)


	DELETE CreatorsBoardgames
	WHERE BoardgameId IN (1,16,31,47)

	
	DELETE Boardgames
	WHERE PublisherId IN (1,16)

	DELETE Publishers
	WHERE AddressId=5

	DELETE Addresses
	WHERE Town LIKE 'L%'
	
	--05. Boardgames by Year of Publication

	SELECT 
	[Name]
	,Rating
	FROM Boardgames
	ORDER BY YearPublished ,[Name] DESC

	--06. Boardgames by Category


	SELECT 
	b.Id
	,b.[Name]
	,b.YearPublished
	,c.[Name]AS CategoryName
	FROM Boardgames AS b
	JOIN  Categories AS c ON c.Id=b.CategoryId
	WHERE c.Name IN('Strategy Games','Wargames')
	ORDER BY YearPublished DESC


	--07. Creators without Boardgames

	SELECT 
	c.Id
	,CONCAT_WS(' ',c.FirstName,c.LastName) AS CreatorName
	,c.Email
	
	FROM Creators AS c
	LEFT JOIN CreatorsBoardgames AS cb ON c.Id=cb.CreatorId
	WHERE cb.BoardgameId IS NULL
	ORDER BY CreatorName


	--08. First 5 Boardgames


	SELECT TOP 5
	b.[Name]
	,b.Rating
	,c.[Name] AS CategoryName
	FROM Boardgames AS b
	JOIN Categories AS c ON c.Id=b.CategoryId
	JOIN PlayersRanges pr ON b.PlayersRangeId=pr.Id
	WHERE (b.Rating>7.00 AND b.[Name] LIKE '%a%' ) OR
			(b.Rating>7.50 AND pr.PlayersMin=2 AND pr.PlayersMax=5 )
	ORDER BY b.[Name], b.Rating DESC

	--09. Creators with Emails
	SELECT
	FullName
	,s.Email
	,s.Rating
	FROM(
	SELECT
	CONCAT_WS(' ',c.FirstName,c.LastName) AS FullName
	,c.Email as Email
	,b.Rating as Rating
	,RANK() OVER (PARTITION  BY c.Email ORDER BY b.Rating DESC) AS	rangEmail
	FROM Creators AS c
	JOIN CreatorsBoardgames AS cb ON c.Id=cb.CreatorId
	JOIN Boardgames AS b ON b.Id=cb.BoardgameId
	WHERE Email LIKE '%.COM')  AS s
	WHERE rangEmail=1
	ORDER BY FullName


	--10. Creators by Rating

	SELECT 
	c.LastName
	,CEILING( AVG(b.Rating) )AS AverageRating
	,p.[Name] AS PublisherName
	FROM Creators AS c
	JOIN CreatorsBoardgames AS cb ON cb.CreatorId=c.Id
	JOIN Boardgames AS b ON cb.BoardgameId=b.Id
	JOIN Publishers AS p ON b.PublisherId=p.Id
	WHERE p.[Name]='Stonemaier Games'
	GROUP BY c.LastName ,p.[Name]
	ORDER BY AVG(b.Rating) DESC



	--11. Creator with Boardgames

	CREATE  FUNCTION udf_CreatorWithBoardgames(@name NVARCHAR (30)) 
	     RETURNS INT 
	              AS
	           BEGIN
	          RETURN (
	          SELECT
	           COUNT (cb.BoardgameId)
	            FROM Creators  
				  AS c
	            JOIN CreatorsBoardgames 
				  AS cb 
				  ON cb.CreatorId=c.Id
	           WHERE FirstName=@name)
	             END ;

	--12. Search for Boardgame with Specific Category
	CREATE OR ALTER PROCEDURE usp_SearchByCategory(@category VARCHAR(50) ) 
	AS
	SELECT
	       b.[Name]
	       ,b.YearPublished
	       ,b.Rating
		   ,c.[Name] AS CategoryName
		   ,p.[Name] AS PublisherName
		,CONCAT_WS(' ',pr.PlayersMin,'people') MinPlayers
		,CONCAT_WS(' ',pr.PlayersMax,'people') MaxPlayers
	  FROM Boardgames AS b
	  JOIN Categories AS c ON c.Id=b.CategoryId
	  JOIN Publishers p ON b.PublisherId=p.Id
	  JOIN PlayersRanges pr ON b.PlayersRangeId=pr.Id
	  WHERE c.[Name]=@category
	  ORDER BY p.[Name] ,b.YearPublished DESC
	 
	 
	