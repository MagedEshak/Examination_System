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

<<<<<<< HEAD
------------------------------------------------------------------
=======

go

>>>>>>> fa9232f50da850361fd8ae058f557f41bc9ba3b1
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
<<<<<<< HEAD
----------------------------------------------------------------
=======

go

>>>>>>> fa9232f50da850361fd8ae058f557f41bc9ba3b1
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
---------------------------------------------------------------------
/*
	this trigger will prevent instructor to insert two identical  
	Questions in the same Exam

	this trigger will prevent instructor to insert an exam 
	if total degree of the exam is less than Course MinDegree
	or heigher than Course MaxDegree
	- we use two functions inside it
		1- GetCourseMaxDegree
		2- GetCourseMinDegree
*/
CREATE OR ALTER TRIGGER trg_EnsureExamTotalDegreeAndQuestionUniqness
ON ExamQuestion
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @minDegree SMALLINT;
    DECLARE @maxDegree SMALLINT;
	DECLARE @QuestionID INT;
	DECLARE @examTotalDegree SMALLINT;
	DECLARE @Flag int = 0;
	Declare @ExamID int ;
	
	SELECT @ExamID = I.ExamId_FK
	FROM inserted I

	-- Checking identical questions in the same exam
	-- if there are no identical questions , flag = 0
	-- if there is one at least , flag != 0
	SELECT @Flag = EQ.ExamId_FK		-- if query returns any row , then flag != 0
	FROM INSERTED I, ExamQuestion EQ
	where I.ExamId_FK = EQ.ExamId_FK 
	AND I.QuestionId_FK = EQ.QuestionId_FK

	SELECT
		@QuestionID = I.QuestionId_FK
	FROM INSERTED I

	SET @minDegree = dbo.GetCourseMinDegree(@QuestionID);
	SET @maxDegree = dbo.GetCourseMaxDegree(@QuestionID);

	SELECT @examTotalDegree = SUM(I.QusetionDegree)
	FROM INSERTED I
	
	IF(@Flag = 0 AND @examTotalDegree >= @minDegree 
				 AND @examTotalDegree <= @maxDegree)
	BEGIN
		INSERT INTO ExamQuestion
		SELECT * FROM INSERTED

		PRINT 'Exam Created Successfully';
	END
	ELSE IF(@Flag != 0)
	BEGIN
		PRINT 'There are identical questions in the same exam';
		DELETE FROM  Exam  WHERE Exam.ExamId = @ExamID;
	END
	ELSE IF(@examTotalDegree < @minDegree)
	BEGIN
		PRINT 'Your Exam Total Degree Is Less Than Minimum Course Degree , Min Course Degree: ' + CAST(@minDegree AS VARCHAR);
		DELETE FROM  Exam  WHERE Exam.ExamId = @ExamID;
	END
	ELSE
	BEGIN
		PRINT 'Your Exam Total Degree Is More Than Maximum Course Degree , Max Degree: ' + CAST(@maxDegree AS VARCHAR);
		DELETE FROM  Exam  WHERE Exam.ExamId = @ExamID;
	END
END;
---------------------------------------------------------------------
/*
	this trigger updates StudentExam table 
	it stores automatically his Exam result
*/
 CREATE OR ALTER TRIGGER trg_UpdateStudentExamWithResult
 ON StudentAnswer
 AFTER UPDATE
 AS
 BEGIN
	DECLARE @StudentId INT;
	DECLARE @ExamId INT;
	
	SELECT TOP 1 @StudentId = I.StudentId_FK, @ExamId =  I.ExamId_FK
	FROM INSERTED I

	UPDATE StudentExam
	SET 
		ExamTotalResult = 
		dbo.CorrectStudentExam(@StudentId, @ExamId)
	WHERE StudentId_FK = @StudentId
	AND ExamId_FK = @ExamId
 END
-------------------------------------------------------------------
CREATE TRIGGER trg_ValidateStudentTrackIntake
ON StudentTrackIntake
INSTEAD OF INSERT
AS
BEGIN
	IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN StudentTrackIntake STI
          ON i.StudentId_FK = STI.StudentId_FK
         AND i.EnrollmentDate = STI.EnrollmentDate
         AND i.TrackId_FK <> STI.TrackId_FK
    )
    BEGIN
        RAISERROR('Student cannot be in two tracks on the same enrollment date.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN StudentTrackIntake STI 
          ON i.StudentId_FK = STI.StudentId_FK
         AND i.EnrollmentDate = STI.EnrollmentDate
         AND i.IntakeId_FK <> STI.IntakeId_FK
    )
    BEGIN
        RAISERROR('Student cannot be in two intakes on the same enrollment date.', 16, 1);
        RETURN;
    END

    -- If all checks pass, insert data
    INSERT INTO StudentTrackIntake(StudentId_FK, TrackId_FK, IntakeId_FK, EnrollmentDate)
    SELECT StudentId_FK, TrackId_FK, IntakeId_FK, EnrollmentDate
    FROM inserted;

END
------------------------------------------------------------------