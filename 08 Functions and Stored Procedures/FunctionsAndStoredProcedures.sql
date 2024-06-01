--01. Employees with Salary Above 35000

CREATE OR ALTER PROCEDURE usp_GetEmployeesSalaryAbove35000 
					   AS
				    BEGIN

					      SELECT 
					             FirstName
					            ,LastName
					        FROM Employees
					       WHERE Salary>35000
	                  END;

	--02. Employees with Salary Above Number

CREATE OR ALTER  PROC usp_GetEmployeesSalaryAboveNumber 
						   @SalariLevel DECIMAL(18,4)
  AS
  BEGIN
		SELECT 
		       FirstName
		      ,LastName
		  FROM Employees
		 WHERE Salary>=@SalariLevel
    END;

	--03. Town Names Starting With

CREATE OR ALTER PROC usp_GetTownsStartingWith 
				     @Starting NVARCHAR(50)
AS
BEGIN
		SELECT
		      [Name]
		 FROM Towns
		 WHERE [Name] LIKE @Starting+'%'

END;


--04. Employees from Town

CREATE OR ALTER PROC usp_GetEmployeesFromTown 
  @TaunName NVARCHAR(50)
  AS
  BEGIN
		SELECT
			   FirstName AS[First Name]
			   ,LastName AS [Last Name]
		  FROM Employees AS e
		INNER  JOIN Addresses AS a ON a.AddressID=e.AddressID
		INNER JOIN Towns AS t ON t.TownID=a.TownID
		  WHERE t.Name=@TaunName
    END;

	

	--05. Salary Level Function

	CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4)) 
	RETURNS NVARCHAR(20)
	AS 
	BEGIN
		IF @salary<30000
		RETURN 'Low'
		ELSE IF @salary<=50000
		RETURN 'Average'
		RETURN 'High'
	END;

	--06. Employees by Salary Level
	CREATE OR ALTER PROC usp_EmployeesBySalaryLevel (@salaryLevel NVARCHAR(20))
	AS
	BEGIN
		SELECT 
		FirstName AS [First Name]
		,LastName AS [Last Name]
		FROM Employees
		WHERE dbo.ufn_GetSalaryLevel(Salary)=@salaryLevel

	END;

	--07. Define Function

	CREATE OR ALTER FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(50) , @word NVARCHAR(200)) 
	RETURNS BIT 
	AS 
	BEGIN
		DECLARE @i INT=1
		WHILE  @i<= LEN (@word)
		BEGIN
			DECLARE @ch NVARCHAR(1)= SUBSTRING(@word,@i,1)
			IF CHARINDEX(@ch, @setOfLetters)=0
			RETURN 0
			SET @i+=1
		END
		RETURN 1
	END;

	SELECT dbo.ufn_IsWordComprised('ABV','c' ) AS Result

	--08. *Delete Employees and Departments



	CREATE OR ALTER PROCEDURE usp_DeleteEmployeesFromDepartment @departmentId INT
AS
BEGIN
  DECLARE @employeesIdDelete TABLE (Id INT)
  INSERT INTO @employeesIdDelete (Id)
  SELECT EmployeeID
  FROM Employees
  WHERE DepartmentID=@departmentId

  ALTER TABLE Departments
  ALTER COLUMN ManagerID INT

  UPDATE Departments
  SET ManagerID=NULL
  WHERE ManagerID IN(SELECT * FROM @employeesIdDelete)

  UPDATE Employees
  SET ManagerID=NULL
  WHERE ManagerID IN(SELECT * FROM @employeesIdDelete)

 

 DELETE FROM EmployeesProjects
 WHERE EmployeeID IN (SELECT * FROM @employeesIdDelete)

 DELETE FROM Employees
 WHERE DepartmentID=@departmentId


 DELETE FROM Departments
 WHERE DepartmentID=@departmentId

 SELECT 
 COUNT(*) 
 FROM Employees
 WHERE DepartmentID=@departmentId
END;

--09. Find Full Name

CREATE PROCEDURE usp_GetHoldersFullName 
AS 
BEGIN
	SELECT 
	CONCAT_WS(' ',FirstName,LastName) AS [Full Name]
	FROM AccountHolders
END;


--10. People with Balance Higher Than

CREATE OR ALTER PROC usp_GetHoldersWithBalanceHigherThan @parameter DECIMAL(20,6)
AS
BEGIN
	SELECT 
	ah.FirstName AS [First Name]
	,ah.LastName AS [Last Name]
	
	FROM AccountHolders AS ah
	JOIN (
	SELECT 
	AccountHolderId
	,SUM(Balance) AS TotalSum
	FROM Accounts
	GROUP BY AccountHolderId
	) AS sas ON ah.Id=sas.AccountHolderId
	WHERE TotalSum>@parameter
	ORDER BY ah.FirstName,ah.LastName

END;

--11. Future Value Function

CREATE FUNCTION  ufn_CalculateFutureValue (@sum DECIMAL(14,4), @rate FLOAT,@years  INT)
RETURNS DECIMAL (24,4)
AS
BEGIN
	RETURN @sum * POWER((1 + @rate), @years)
END;

--12. Calculating Interest
GO
CREATE PROCEDURE usp_CalculateFutureValueForAccount @accountId INT,@rate FLOAT
AS
BEGIN
	SELECT 
	ac.Id AS [Account Id]
	,ah.FirstName AS [First Name]
	,ah.LastName AS [Last Name]
	,ac.Balance AS [Current Balance]
	,dbo.ufn_CalculateFutureValue(ac.Balance,@rate,5)AS[Balance in 5 years]
	
	FROM AccountHolders AS ah
	JOIN Accounts AS ac ON ah.Id=ac.AccountHolderId
	WHERE ac.Id=@accountId
END;
GO
--13. *Cash in User Games Odd Rows
CREATE OR ALTER FUNCTION ufn_CashInUsersGames (@GameName NVARCHAR(50))
RETURNS TABLE 
AS
RETURN
	SELECT
	Sum(sg.Cash) AS SumCash
	FROM
		(
		SELECT 
		ug.Cash
		,ROW_NUMBER() OVER (ORDER BY ug.Cash DESC) AS RowNumber
		FROM UsersGames AS ug
		JOIN Games AS g ON ug.GameId=g.Id
		WHERE g.Name=@GameName) AS sg
	WHERE sg.RowNumber%2=1



	

	 

