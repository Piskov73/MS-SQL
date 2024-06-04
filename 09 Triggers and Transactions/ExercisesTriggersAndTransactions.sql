--1.	Create Table Logs

CREATE TABLE Logs (
	LogId INT PRIMARY KEY IDENTITY
	,AccountId INT NOT NULL
	,OldSum MONEY 
	,NewSum MONEY
);

CREATE OR ALTER TRIGGER trg_LogAccountSumChange
ON Accounts AFTER UPDATE 
AS
BEGIN
INSERT INTO Logs(AccountId,OldSum,NewSum)
SELECT
i.Id
,d.Balance
,i.Balance
FROM inserted AS i
JOIN deleted AS d ON i.Id=d.Id
WHERE d.Balance!=i.Balance
END;


--02. Create Table Emails

CREATE TABLE NotificationEmails(
	Id INT PRIMARY KEY IDENTITY
	,Recipient INT
	,[Subject] NVARCHAR (100)
	,Body NVARCHAR (200)

);

CREATE OR ALTER TRIGGER trg_EmailBalanceChange
ON Logs AFTER INSERT
AS
BEGIN
INSERT INTO NotificationEmails (Recipient,[Subject],Body)
SELECT
i.AccountId
,'Balance change for account: '+CAST(i.AccountId AS NVARCHAR (50))
,'On '+CONVERT(NVARCHAR , GETDATE(),120)+' your balance was changed from '
+CAST (i.OldSum AS NVARCHAR (50))+' to '+CAST(i.NewSum AS NVARCHAR(50))+'.'
FROM inserted AS i
END;


--03. Deposit Money

CREATE OR ALTER PROCEDURE usp_DepositMoney @AccountId INT,@MoneyAmount DECIMAL (18,4)
AS
BEGIN TRANSACTION 
BEGIN TRY

IF @MoneyAmount<0
BEGIN
ROLLBACK TRANSACTION
RETURN
END
UPDATE Accounts
SET Balance+=@MoneyAmount
WHERE Id=@AccountId
COMMIT
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH


--04. Withdraw Money Procedure

CREATE OR ALTER  PROCEDURE usp_WithdrawMoney @AccountId INT,@MoneyAmount MONEY
AS
BEGIN TRANSACTION 

BEGIN TRY

IF @MoneyAmount<0
BEGIN
ROLLBACK TRANSACTION
RETURN
END

UPDATE Accounts
SET Balance-=@MoneyAmount
WHERE Id=@AccountId
COMMIT TRANSACTION

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

END  CATCH

--05. Money Transfer

CREATE OR ALTER PROCEDURE  usp_TransferMoney @SenderId INT,@ReceiverId INT , @Amount MONEY
AS
BEGIN TRANSACTION
EXEC usp_WithdrawMoney @SenderId,@Amount
EXEC usp_DepositMoney @ReceiverId,@Amount
COMMIT

--08. Employees with Three Projects

CREATE OR ALTER PROCEDURE usp_AssignProject @emloyeeId INT ,@projectID INT
AS
DECLARE @numbProject INT;
	BEGIN TRANSACTION
	
	   SELECT @numbProject=
		COUNT(ProjectID) 
		FROM EmployeesProjects
		WHERE EmployeeID=@emloyeeId
		GROUP BY EmployeeID
	
		IF @numbProject>=3
		BEGIN 
		ROLLBACK
		 RAISERROR('The employee has too many projects!', 16, 1);
		RETURN
		END
		INSERT INTO EmployeesProjects(EmployeeID,ProjectID)
		VALUES(@emloyeeId,@projectID)
		COMMIT TRANSACTION
	

	--09. Delete Employees



	CREATE TABLE Deleted_Employees (
	EmployeeId  INT PRIMARY KEY IDENTITY
	,FirstName NVARCHAR (50)
	,LastName NVARCHAR (50)
	,MiddleName NVARCHAR (50)
	,JobTitle NVARCHAR (50)
	,DepartmentId INT
	,Salary MONEY
	)

	CREATE TRIGGER trg_DeletedEmployees
	ON [Employees] AFTER DELETE 
	AS 
	INSERT INTO Deleted_Employees(FirstName,LastName,MiddleName,JobTitle,DepartmentId,Salary)
	SELECT
	d.FirstName,d.LastName,d.MiddleName,d.JobTitle,d.DepartmentID,d.Salary
	FROM deleted AS d

	

