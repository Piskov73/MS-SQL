--1.	Employee Address

	SELECT TOP (5)
		e.EmployeeID,e.JobTitle,e.AddressID,a.AddressText
	FROM  
		[Employees] AS e
	JOIN 
		Addresses AS a ON e.AddressID=a.AddressID
	ORDER BY 
		e.AddressID

--2.	Addresses with Towns
	
	
SELECT TOP(50)
		e.FirstName
		,e.LastName
		,t.[Name] AS [Town]
		,a.AddressText
	FROM
		[Employees]AS e
	JOIN 
		[Addresses] AS a ON e.AddressID=a.AddressID
	JOIN 
		[Towns] AS t ON t.TownID=a.TownID
	ORDER BY e.FirstName , e.LastName;

--3.	Sales Employee

	SELECT 
		  e.EmployeeID
		  ,E.FirstName
		  ,e.LastName
		  ,d.Name AS[DepartmentName]

	FROM [Employees] AS e 

	JOIN [Departments] AS d ON d.DepartmentID=e.DepartmentID

	WHERE d.Name='Sales'

	ORDER BY E.EmployeeID ;

--4.	Employee Departments

	SELECT TOP(5)
		e.EmployeeID
		,e.FirstName
		,e.Salary
		,d.[Name] AS [DepartmentName]

	FROM [Employees] AS e	

	JOIN [Departments] AS d ON e.DepartmentID=d.DepartmentID

	WHERE e.Salary>1500

	ORDER BY d.DepartmentID

--5.	Employees Without Project

	
	SELECT TOP (3)
		e.EmployeeID
		,e.FirstName

	FROM [Employees] AS e

	WHERE e.EmployeeID NOT IN (
		SELECT [EmployeeID]
		FROM [EmployeesProjects]) 

	ORDER BY e.EmployeeID

--06. Employees Hired After

	SELECT 
	e.FirstName
	,e.LastName
	,e.HireDate
	,d.[Name] 

	FROM [Employees] AS e

	JOIN [Departments] d ON e.DepartmentID=d.DepartmentID AND d.[Name] IN('Sales','Finance')

	WHERE e.HireDate>'1-1-1999'

	ORDER BY e.HireDate

--7.	Employees with Project

	SELECT TOP(5)
		e.EmployeeID
		,e.FirstName
		,P.[Name]
	FROM [Employees] AS e

	JOIN [EmployeesProjects] AS ep ON e.EmployeeID=ep.EmployeeID
	JOIN [Projects] AS p ON p.ProjectID=ep.ProjectID 
	WHERE p.StartDate>'2002-08-13' AND p.EndDate IS null
	ORDER BY e.EmployeeID

--08. Employee 24

	SELECT
	e.EmployeeID
	,e.FirstName
	,CASE WHEN p.StartDate>='2005-01-01' THEN NULL ELSE p.[Name]  END AS [ProjectName]
	FROM[Employees] AS e
	JOIN [EmployeesProjects] AS ep ON e.EmployeeID=ep.EmployeeID
	JOIN [Projects] AS p ON p.ProjectID=ep.ProjectID
	WHERE e.EmployeeID=24;

--09. Employee Manager
	SELECT
		e.EmployeeID
		,e.FirstName
		,e.ManagerID
		,m.FirstName

	FROM Employees AS e

	JOIN Employees AS m ON m.EmployeeID= e.ManagerID

	WHERE e.ManagerID IN(3,7)

	ORDER BY e.EmployeeID

--10.	Employees Summary

	SELECT TOP(50)
		e.EmployeeID
		,CONCAT_WS(' ',e.FirstName,e.LastName) AS EmployeeName
		,CONCAT_WS(' ',m.FirstName,m.LastName) AS ManagerName
		,d.[Name] AS DepartmentName
	FROM Employees AS e

	JOIN Employees AS m ON e.ManagerID=m.EmployeeID

	JOIN Departments AS d ON e.DepartmentID=d.DepartmentID

	ORDER BY e.EmployeeID

--11. Min Average Salary
	

	--Option 1

	SELECT TOP(1)
	 AVG(e.Salary) AS MinAverageSalary

	FROM Employees AS e

	JOIN Departments AS d ON e.DepartmentID=d.DepartmentID

	GROUP BY d.DepartmentID,d.Name

	ORDER BY MinAverageSalary

	--Option 2

	SELECT 
    MIN(AverageSalary) AS MinAverageSalary
FROM
    (SELECT 
         AVG(e.Salary) AS AverageSalary
     FROM 
         Employees AS e
     JOIN 
         Departments AS d ON e.DepartmentID = d.DepartmentID
     GROUP BY 
         d.DepartmentID, d.Name) AS DepartmentAverages;


--12. Highest Peaks in Bulgaria

USE Geography;

	SELECT
	c.CountryCode
	,m.MountainRange
	,p.PeakName
	,p.Elevation

	FROM Mountains AS m

	JOIN Peaks AS p ON p.MountainId=m.Id
	JOIN MountainsCountries mc ON mc.MountainId=m.Id
	JOIN Countries AS c ON c.CountryCode=mc.CountryCode

	WHERE c.CountryName='Bulgaria' AND p.Elevation>2835

	ORDER BY p.Elevation DESC

--13. Count Mountain Ranges

SELECT 
	c.CountryCode
	,COUNT (m.MountainRange)AS [MountainRanges]
FROM 
	Countries AS c
JOIN 
	MountainsCountries AS mc ON c.CountryCode=mc.CountryCode
JOIN 
	Mountains AS m ON m.Id=mc.MountainId
WHERE 
	c.CountryName IN ('United States','Russia','Bulgaria')
GROUP BY 
	(c.CountryCode)

	
--14. Countries With or Without Rivers

SELECT TOP(5)
	co.CountryName
	,r.RiverName
FROM Continents AS ct
JOIN 
	Countries AS co ON co.ContinentCode=ct.ContinentCode
LEFT JOIN 
	CountriesRivers AS cr ON cr.CountryCode=co.CountryCode
LEFT JOIN 
	Rivers AS r ON cr.RiverId=r.Id
WHERE ct.ContinentName='Africa'
ORDER BY co.CountryName

--15. Continents and Currencies
SELECT 
r.ContinentCode
,r.CurrencyCode
,r.CurrencyUsage
FROM(
		SELECT 
		c.ContinentCode
		,c.CurrencyCode
		, COUNT(c.CurrencyCode) AS CurrencyUsage
		,DENSE_RANK () OVER(PARTITION BY c.ContinentCode ORDER BY COUNT (c.CurrencyCode)DESC) AS [Rank]
		FROM Countries AS c
		GROUP BY c.ContinentCode,c.CurrencyCode
		HAVING COUNT (c.CurrencyCode)>1
		) AS r
WHERE r.[Rank]=1
ORDER BY r.ContinentCode

--16. Countries Without any Mountains

SELECT
COUNT(*)AS [Count]

FROM Countries AS c
LEFT JOIN MountainsCountries AS m ON m.CountryCode=c.CountryCode

WHERE m.MountainId IS NULL

--17. Highest Peak and Longest River by Country

SELECT TOP(5)
c.CountryName
, MAX(p.Elevation) AS HighestPeakElevation
,MAX(r.Length) AS LongestRiverLength

FROM Countries AS c 

LEFT JOIN MountainsCountries AS mc ON mc.CountryCode=c.CountryCode
LEFT JOIN Mountains AS m ON m.Id=mc.MountainId
LEFT JOIN Peaks AS p ON p.MountainId=m.Id
LEFT JOIN CountriesRivers AS cr ON cr.CountryCode=c.CountryCode
LEFT JOIN Rivers AS r ON r.Id=cr.RiverId
GROUP BY c.CountryName

ORDER BY HighestPeakElevation DESC,LongestRiverLength DESC ,c.CountryName


--18. Highest Peak Name and Elevation by Country
SELECT TOP (5)
Country
,CASE
	WHEN PeakName IS NULL THEN '(no highest peak)'
	ELSE PeakName
END AS [Highest Peak Name]
, CASE 
WHEN Elevation IS NULL THEN 0
ELSE Elevation
END AS [Highest Peak Elevation]

,CASE 
WHEN MountainRange IS NULL THEN '(no mountain)'
ELSE MountainRange
END AS Mountain

FROM(
	SELECT 
		c.CountryName AS Country
		,p.PeakName
		,p.Elevation
		,m.MountainRange
		,DENSE_RANK() OVER (PARTITION BY c.CountryName ORDER BY p.Elevation DESC  ) AS PeakRank

	FROM 
		Countries AS c

		LEFT JOIN MountainsCountries AS mc ON mc.CountryCode=c.CountryCode
		LEFT JOIN Mountains AS m ON m.Id=mc.MountainId
		LEFT JOIN Peaks AS p ON p.MountainId=m.Id
	) AS sel
WHERE PeakRank=1
ORDER BY Country,[Highest Peak Name]