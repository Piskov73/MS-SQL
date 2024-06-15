
CREATE DATABASE Service

USE Service

	--01. DDL

	

	CREATE TABLE Users(
	Id INT PRIMARY KEY IDENTITY
	,Username VARCHAR(30) UNIQUE NOT NULL
	,Password VARCHAR(50)  NOT NULL
	,Name VARCHAR(50)
	,Birthdate DATETIME 
	,Age INT CHECK(Age BETWEEN 14 AND 110)
	,Email VARCHAR(50)  NOT NULL
	);


	CREATE TABLE Departments(
	Id INT PRIMARY KEY IDENTITY
	,Name VARCHAR(50)  NOT NULL
	);

	CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY
	,FirstName VARCHAR(25) 
	,LastName VARCHAR(25) 
	,Birthdate DATETIME 
	,Age INT CHECK(Age BETWEEN 14 AND 110)
	,DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
	);



	CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY
	,Name VARCHAR(50) NOT NULL
	,DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
	);


	CREATE TABLE Status(
	Id INT PRIMARY KEY IDENTITY
	,Label VARCHAR(50) NOT NULL
	);


	CREATE TABLE Reports(
	Id INT PRIMARY KEY IDENTITY
	,CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL
	,StatusId INT FOREIGN KEY REFERENCES Status(Id) NOT NULL
	,OpenDate DATETIME NOT NULL
	,CloseDate DATETIME
	,Description VARCHAR (200)  NOT NULL
	,UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
	,EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) 
	);

	--02. Insert


	INSERT INTO Employees(FirstName, LastName, Birthdate,DepartmentId)
	VALUES
	('Marlo', 'O''Malley','1958-9-21', 1)
	,('Niki','Stanaghan', '1969-11-26', 4)
	,('Ayrton', 'Senna', '1960-03-21', 9)
	,('Ronnie',	'Peterson',	'1944-02-14',	9)
	,('Giovanna',	'Amati',	'1959-07-20',	5);

	

	INSERT INTO Reports(CategoryId,	StatusId,	OpenDate,	CloseDate,Description,	UserId,	EmployeeId)
	VALUES
	(1,1,'2017-04-13',NULL,		'Stuck Road on Str.133'	,6	,2)
	,(6,	3,	'2015-09-05',	'2015-12-06','Charity trail running',	3	,5)
	,(14,2, '2015-09-07',NULL,	'Falling bricks on Str.58',	5,	2)
	,(4,	3,	'2017-07-03', '2017-07-06','Cut off streetlight on Str.11',	1,	1);


	--03. Update

	
	UPDATE Reports
	SET CloseDate=GETDATE()
	WHERE CloseDate IS NULL

	--04. Delete

	DELETE
	FROM Reports
	WHERE StatusId=4

	--05. Unassigned Reports


	SELECT
	Description
	,FORMAT(r.OpenDate,'dd-MM-yyyy') AS OpenDate
	FROM Reports AS r
	WHERE EmployeeId IS  NULL
	ORDER BY r.OpenDate,[Description]

	--06. Reports & Categories

	

	SELECT 
	r.Description
	,c.Name
	FROM Reports AS r
	JOIN Categories AS c ON r.CategoryId=c.Id
	ORDER BY r.Description,c.Name

	--07. Most Reported Category

	SELECT  TOP 5
	Name AS CategoryName
	,COUNT(*) AS ReportsNumber
	FROM Categories AS c
	JOIN Reports AS r ON r.CategoryId=c.Id
	GROUP BY Name
	ORDER BY COUNT(*) DESC,Name

	--08. Birthday Report

	--Username	CategoryName

	SELECT
	u.Username AS Username
	,c.Name AS CategoryName
	
	FROM Users AS u
	JOIN Reports AS r ON u.Id=r.UserId
	JOIN Categories AS c ON r.CategoryId=c.Id
	WHERE MONTH(r.OpenDate)=MONTH(u.Birthdate) AND DAY(r.OpenDate)=DAY(u.Birthdate)
	ORDER BY Username,CategoryName

	--09. User per Employee
	
	SELECT
	CONCAT_WS(' ',e.FirstName,e.LastName) AS FullName
	,COUNT(r.UserId) AS UsersCount
	FROM Employees AS e
    LEFT JOIN Reports AS r ON r.EmployeeId=e.Id
	GROUP BY e.FirstName,e.LastName
	ORDER BY UsersCount DESC,FullName

	--10. Full Info

	--Employee	Department	Category	Description	OpenDate	Status	User

	SELECT
	IIF (e.FirstName IS NULL AND e.LastName IS NULL ,'None',CONCAT_WS(' ',e.FirstName,e.LastName)) AS Employee
	,IIF(d.Name IS NULL ,'None',d.Name) AS Department
	,IIf(c.Name IS NULL,'None',c.Name) AS Category
	,r.Description
	,FORMAT (r.OpenDate,'dd.MM.yyyy') AS OpenDate
	,s.Label AS Status
	,u.Name AS [User]
	FROM Reports AS r
	LEFT JOIN Employees AS e ON r.EmployeeId=e.Id
	LEFT JOIN Departments AS d ON e.DepartmentId=d.Id
	LEFT JOIN Categories AS c ON r.CategoryId=c.Id
	JOIN Status AS  s ON r.StatusId=s.Id
	jOIN Users AS u ON r.UserId=u.Id
	ORDER BY e.FirstName DESC , e.LastName DESC ,d.Name,c.Name,r.Description,r.OpenDate,s.Label,u.Name


	--11. Hours to Complete

	CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME) 
	RETURNS INT
	AS
	BEGIN
	DECLARE @result INT
	SELECT @result=
	DATEDIFF(HOUR,@StartDate,@EndDate)
	FROM Reports
	WHERE CloseDate BETWEEN @StartDate AND @EndDate
	RETURN IIF(@result IS NULL , 0,@result)
	END

	--12. Assign Employee

CREATE PROCEDURE usp_AssignEmployeeToReport
    @EmployeeId INT,
    @ReportId INT
AS
BEGIN
    
    DECLARE @employeeDeptId INT;
    DECLARE @reportDeptId INT;

   
    BEGIN TRANSACTION;

    
    SELECT @employeeDeptId = e.DepartmentId
    FROM Employees AS e
    WHERE e.Id = @EmployeeId;

    
    SELECT @reportDeptId = c.DepartmentId
    FROM Reports AS r
    JOIN Categories AS c ON r.CategoryId = c.Id
    WHERE r.Id = @ReportId;

    
    IF @employeeDeptId = @reportDeptId
    BEGIN
        
        UPDATE Reports
        SET EmployeeId = @EmployeeId
        WHERE Id = @ReportId;

       
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
      
        ROLLBACK TRANSACTION;

       
        THROW 50000, 'Employee doesn''t belong to the appropriate department!', 1;
    END
END;








	