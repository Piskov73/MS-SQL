--1.	Find Names of All Employees by First Name

SELECT [FirstName],[LastName]
FROM [Employees]
WHERE [FirstName] LIKE'Sa%';

--2.	Find Names of All Employees by Last Name 

SELEcT [FirstName],[LastName]
FROM [Employees]
WHERE [LastName] LIKE'%ei%';

--3.	Find First Names of All Employees

SELEcT [FirstName]
FROM [Employees]
WHERE [DepartmentID] IN(3,10)
AND YEAR (HireDate) BETWEEN 1995 AND 2005;

--4.	Find All Employees Except Engineers

SELECT [FirstName],[LastName]
FROM[Employees]
WHERE [JobTitle] NOT LIKE'%engineer%';

--5.	Find Towns with Name Length

SELECT [Name]
FROM [Towns]
WHERE LEN(Name) IN(5,6)
ORDER BY [Name]

--6.	Find Towns Starting With

SELECT[TownID],[Name]
FROM [Towns]
WHERE LEFT(Name,1)IN ('M','K','B','E')
ORDER BY[Name]

--7.	Find Towns Not Starting With

SELECT [TownID],[Name]
FROM [Towns]
WHERE LEFT(Name,1) NOT IN('R','B','D')
ORDER BY[Name];

--8.	Create View Employees Hired After 2000 Year

CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT [FirstName],[LastName]
FROM [Employees]
WHERE YEAR(HireDate)>2000;

--9.	Length of Last Name


SELECT[FirstName],[LastName]
FROM[Employees]
WHERE LEN(LastName)=5;

--10.	Rank Employees by Salary

SELECT [EmployeeID],[FirstName],[LastName],[Salary],
DENSE_RANK() OVER (PARTITION BY [Salary] ORDER BY [EmployeeID]  ) Rank
FROM [Employees]
WHERE [Salary] BETWEEN 10000 AND 50000
ORDER BY [Salary] DESC

--11.	Find All Employees with Rank 2


SELECT [EmployeeID],[FirstName],[LastName],[Salary],[Rank]

FROM (
SELECT 
	[EmployeeID],
	[FirstName],
	[LastName],
	[Salary],
	DENSE_RANK() OVER (PARTITION BY [Salary] ORDER BY[EmployeeID])AS Rank
FROM
	[Employees]
WHERE [Salary] BETWEEN 10000 AND 50000) AS RankedEmployees
WHERE Rank=2
ORDER BY [Salary] DESC;

--12.	Countries Holding 'A' 3 or More Times

USE Geography 

SELECT [CountryName] As 'Country Name',
       [IsoCode] AS 'ISO Code'
FROM [Countries]
WHERE LEN (LOWER ([CountryName]))-LEN (REPLACE(LOWER ([CountryName]),'a',''))>=3
ORDER BY [IsoCode];

-- 13 Mix of Peak and River Names

SELECT p.PeakName,r.RiverName,  LOWER(LEFT(P.PeakName, LEN(p.PeakName)-1 )+r.RiverName)AS Mix
FROM Peaks AS p, Rivers As r
WHERE RIGHT(p.PeakName,1)=LEFT(r.RiverName,1)
ORDER BY Mix;

--14.	Games from 2011 and 2012 Year

SELECT TOP(50) [Name],FORMAT([Start],'yyyy-MM-dd') AS Start
FROM [Games]
WHERE YEAR([Start]) BETWEEN 2011 AND 2012
ORDER BY [Start] ,[Name];

--15.	 User Email Providers

SELECT 
       [Username]
       , SUBSTRING(Email, CHARINDEX('@',Email)+1,LEN(Email) ) [Email Provider]
FROM 
	   [Users] 
ORDER BY
	[Email Provider],[Username]

	--16.	 Get Users with IP Address Like Pattern

SELECT [Username],[IpAddress] AS [IP Address]
FROM [Users]
WHERE [IpAddress] LIKE '___.1%.%.___'
ORDER BY [Username];

--17.	 Show All Games with Duration and Part of the Day

SELECT [Name] AS [Game],
CASE
    WHEN DATEPART (hour,[Start]) BETWEEN 0 AND 11 THEN 'Morning'
	WHEN DATEPART (hour , [Start]) BETWEEN 12 AND 17 THEN 'Afternoon'
	WHEN DATEPART (hour,[Start]) BETWEEN 18 AND 23 THEN 'Evening'

END AS [Part of the Day],

CASE
    WHEN [Duration]<=3 THEN'Extra Short'
	WHEN [Duration] BETWEEN 4 AND 6 THEN 'Short'
	WHEN [Duration] >6 THEN 'Long'
	ELSE 'Extra Long'
END AS [Duration]

FROM [Games]
ORDER BY [Name],[Duration];

USE Orders;

--18.	 Orders Table

SELECT [ProductName],[OrderDate],
DATEADD (day,3,[OrderDate])AS[Pay Due],
DATEADD (month,1,[OrderDate]) AS[Deliver Due]
FROM [Orders];



