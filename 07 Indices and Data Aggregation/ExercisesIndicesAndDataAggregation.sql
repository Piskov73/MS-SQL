--1. Records' Count

 SELECT
	     COUNT (*) AS [Count]
   FROM  [WizzardDeposits] AS wd

 --02. Longest Magic Wand

 SELECT 
		MAX(MagicWandSize) AS [LongestMagicWand]
   FROM [WizzardDeposits]

 --03. Longest Magic Wand per Deposit Groups

  SELECT 
		[DepositGroup]
		,MAX (MagicWandSize) AS LongestMagicWand
    FROM [WizzardDeposits]
GROUP BY [DepositGroup]

--4. Smallest Deposit Group Per Magic Wand Size

  SELECT TOP (2)
		     DepositGroup
        FROM WizzardDeposits
    GROUP BY DepositGroup
    ORDER BY AVG (MagicWandSize)

 --5. Deposits Sum

     SELECT 
			DepositGroup
			,SUM (DepositAmount) AS TotalSum
       FROM WizzardDeposits
   GROUP BY DepositGroup

 --6. Deposits Sum for Ollivander Family
 
  SELECT 
		 DepositGroup
		 ,SUM(DepositAmount)AS TotalSum
    FROM WizzardDeposits 
GROUP BY DepositGroup,MagicWandCreator
  HAVING MagicWandCreator='Ollivander family'


--Option two
  SELECT
		 DepositGroup
		 ,SUM(DepositAmount)AS TotalSum
	FROM(
		SELECT 
				DepositGroup
			   ,DepositAmount
		  FROM WizzardDeposits
		 WHERE MagicWandCreator='Ollivander family'
		) AS filtrr
	GROUP BY DepositGroup

 --7. Deposits Filter
 SELECT
		 DepositGroup
		,TotalSum
 FROM
	 (
	SELECT
		   DepositGroup
		   ,SUM(DepositAmount) AS TotalSum
	FROM(
		SELECT 
			   DepositGroup
	          ,DepositAmount
	      FROM WizzardDeposits
	     WHERE MagicWandCreator='Ollivander family'
		 ) AS f
	GROUP BY DepositGroup) AS fs
	WHERE TotalSum<150000
	ORDER BY TotalSum DESC ;



	--Option two
SELECT
	   DepositGroup
	  ,TotalSum
  FROM
		    (SELECT 
			        DepositGroup
			       ,SUM(DepositAmount) AS TotalSum
               FROM WizzardDeposits
           GROUP BY DepositGroup ,MagicWandCreator
             HAVING MagicWandCreator='Ollivander family') AS odf
   WHERE TotalSum<150000
ORDER BY TotalSum DESC;



--8.  Deposit Charge

	SELECT 
		   DepositGroup
		  ,MagicWandCreator
		  ,MIN(DepositCharge) AS MinDepositCharge
	  FROM WizzardDeposits
  GROUP BY DepositGroup,MagicWandCreator
  ORDER BY MagicWandCreator,DepositGroup;

  --9. Age Groups
  SELECT
         AgeGroup
		 ,COUNT(*)AS WizardCount
    FROM
			( SELECT
			   CASE
			         WHEN Age <=10 THEN '[0-10]'
					 WHEN Age <=20 THEN '[11-20]'
					 WHEN Age <=30 THEN '[21-30]'
					 WHEN Age <=40 THEN '[31-40]'
					 WHEN Age <=50 THEN '[41-50]'
					 WHEN Age <=60 THEN '[51-60]'
					 ELSE '[60+]'
			    END AS AgeGroup
			   FROM WizzardDeposits) AS sa
GROUP BY AgeGroup 

--10. First Letter
SELECT
       FirstLetter
  FROM (
		SELECT 
			    LEFT(FirstName,1 )AS FirstLetter
		   FROM WizzardDeposits
		  WHERE DepositGroup='Troll Chest'
       ) AS fl
GROUP BY FirstLetter

ORDER BY FirstLetter 

--11. Average Interest

SELECT 
		 DepositGroup
		,IsDepositExpired
		,AVG (DepositInterest) AS AverageInterest

    FROM WizzardDeposits
   WHERE DepositStartDate>'1985/01/01'
GROUP BY DepositGroup,IsDepositExpired
ORDER BY DepositGroup DESC,IsDepositExpired


--12. *Rich Wizard, Poor Wizard
SELECT 
SUM([Difference]) AS SumDifference
FROM
	(
		SELECT 
		       wds.FirstName AS[Host Wizard]
			   ,wds.DepositAmount AS[Host Wizard Deposit]
		      ,wdf.FirstName AS[Guest Wizard]
			  ,wdf.DepositAmount AS [Guest Wizard Deposit]
			  ,wds.DepositAmount-wdf.DepositAmount AS [Difference]
		  FROM WizzardDeposits AS wdf
		        JOIN WizzardDeposits AS wds ON wdf.Id=wds.Id+1) AS ds

	--Option two
SELECT 
SUM([Difference]) AS SumDifference
 FROM
	 (
	SELECT
		   FirstName AS [Host Wizard]
		  ,DepositAmount AS [Host Wizard Deposit]
		  ,LEAD (FirstName) OVER (ORDER BY Id) AS [Guest Wizard]
		  ,LEAD (DepositAmount) OVER (ORDER BY Id) AS [Guest Wizard Deposit]
		  ,DepositAmount-LEAD (DepositAmount) OVER (ORDER BY Id) AS [Difference]
	  FROM WizzardDeposits) AS [Filter];
		
		--Option three

	SELECT
	       SUM([Difference]) AS SumDifference
	FROM
		(
		SELECT
		       DepositAmount-LEAD(DepositAmount) OVER (ORDER BY Id) AS [Difference]
		  FROM WizzardDeposits) AS f

--13. Departments Total Salaries

  SELECT 
         DepartmentID
        ,SUM(Salary) AS TotalSalary
    FROM Employees 
GROUP BY DepartmentID
ORDER BY DepartmentID;

--14. Employees Minimum Salaries

    SELECT 
	       DepartmentID
		   ,MIN(Salary)AS MinimumSalary
	  FROM Employees
	  WHERE DepartmentID IN(2,5,7) AND HireDate>'01/01/2000'
	  GROUP BY DepartmentID
	  ORDER BY DepartmentID

--15. Employees Average Salaries

	SELECT *
	INTO NewEmployees
	FROM Employees
	WHERE Salary>30000;

	DELETE
	FROM NewEmployees
	WHERE ManagerID=42;

    UPDATE NewEmployees
	SET Salary=Salary+5000
	WHERE DepartmentID =1;

	SELECT 
	DepartmentID
	,AVG(Salary)ASAverageSalary
	FROM NewEmployees
	GROUP BY DepartmentID
	ORDER BY DepartmentID;


--16. Employees Maximum Salaries
     SELECT
            DepartmentID
           ,MaxSalary
       FROM
			(SELECT
			       DepartmentID
			      ,MAX(Salary)AS MaxSalary
			  FROM Employees
		  GROUP BY DepartmentID) AS filterMaxSalary
	WHERE MaxSalary<30000 OR MaxSalary>70000
	ORDER BY DepartmentID ;
	
--17. Employees Count Salaries

	SELECT 
	       COUNT(FirstName)AS Count
      FROM Employees
  GROUP BY ManagerID
    HAVING ManagerID IS NULL



	--18. *3rd Highest Salary
SELECT
    DepartmentID
    ,MAX(Salary) AS ThirdHighestSalary
FROM
(
    SELECT
        DepartmentID
        ,Salary
        ,DENSE_RANK()
            OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS Rank
    FROM Employees
) AS r
WHERE Rank = 3
GROUP BY DepartmentID


	
	SELECT
    DepartmentID
	,MAX (Salary) as ThirdHighestSalary
FROM (
    SELECT
        DepartmentID,
        Salary,
        DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS dr
    FROM Employees
) AS f
WHERE dr = 3
GROUP BY DepartmentID


--19. **Salary Challenge
	SELECT TOP (10)
			e.FirstName
			,e.LastName
			,e.DepartmentID
	  FROM Employees AS e

			JOIN (
					SELECT
					       DepartmentID
				          ,AVG(Salary) AS [as]
					  FROM Employees 
				  GROUP BY DepartmentID
					  ) AS AvgSalary ON AvgSalary.DepartmentID=e.DepartmentID
	 WHERE e.Salary>AvgSalary.[as]
	


	SELECT TOP(10)
	e.FirstName,
	e.LastName,
	e.DepartmentID
FROM Employees AS e
JOIN
(
	SELECT
		e.DepartmentID
		,AVG(e.Salary) AS AverageSalary
	FROM Employees AS e
	GROUP BY e.DepartmentID
) AS avgSalary
	ON e.DepartmentID = avgSalary.DepartmentID
WHERE e.Salary > avgSalary.AverageSalary