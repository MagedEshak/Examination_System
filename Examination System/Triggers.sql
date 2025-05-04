------
CREATE TRIGGER trg_InstructorRoleValidation
ON Instructor
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @UserId INT;
	DECLARE @ROLE_ VARCHAR(20);

	SELECT @UserId = I.UserId_FK
	FROM inserted I

	SELECT @ROLE_ = U.Role_
	FROM Users U
	WHERE u.UserId = @UserId

	IF(@ROLE_ = 'instructor')
	BEGIN
		INSERT INTO Instructor
		select HireDate, UserId_FK from inserted
	END

	ELSE
	BEGIN
		PRINT 'NOT PERMITTED'
	END
END


go

CREATE TRIGGER trg_StudentRoleValidation
ON student
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @UserId INT;
	DECLARE @ROLE_ VARCHAR(20);

	SELECT @UserId = I.UserId_FK
	FROM inserted I

	SELECT @ROLE_ = U.Role_
	FROM Users U
	WHERE u.UserId = @UserId

	IF(@ROLE_ = 'student')
	BEGIN
		INSERT INTO Student
		select City, Street, BuildingNumber, UserId_FK
		from inserted
	END

	ELSE
	BEGIN
		PRINT 'NOT PERMITTED'
	END
END

go

CREATE TRIGGER trg_ManagerRoleValidation
ON TrainingManager
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @UserId INT;
	DECLARE @ROLE_ VARCHAR(20);

	SELECT @UserId = I.UserId_FK
	FROM inserted I

	SELECT @ROLE_ = U.Role_
	FROM Users U
	WHERE u.UserId = @UserId

	IF(@ROLE_ = 'training manager')
	BEGIN
		INSERT INTO TrainingManager
		select UserId_FK from inserted
	END

	ELSE
	BEGIN
		PRINT 'NOT PERMITTED'
	END
END