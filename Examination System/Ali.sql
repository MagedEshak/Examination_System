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

Go
-----------------------------------------------------------------------
-----------------------------------------------------------------------


/*	Function to get Course Max Degree By Question ID */
CREATE or ALTER FUNCTION GetCourseMaxDegree(@questionID INT)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @maxDegree SMALLINT;
	SELECT TOP 1
        @maxDegree = C.MaxDegree
    FROM Question Q JOIN Course C 
	ON Q.CourseId_FK = C.CourseId
	AND @questionID = Q.QuestionId
	RETURN @maxDegree
End



GO
-----------------------------------------------------------------------
-----------------------------------------------------------------------

/*	Function to get Course Min Degree By Question ID*/
CREATE or ALTER FUNCTION GetCourseMinDegree(@questionID INT)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @minDegree SMALLINT;
	SELECT TOP 1
        @minDegree = C.MinDegree
    FROM Question Q JOIN Course C 
	ON Q.CourseId_FK = C.CourseId
	AND @questionID = Q.QuestionId
	RETURN @minDegree
End

GO
-----------------------------------------------------------------------
-----------------------------------------------------------------------


/*	Function TO Correct Exam to A student and returns his degree */
CREATE OR ALTER FUNCTION CorrectStudentExam(@StudentId INT, @ExamId INT)
RETURNS INT
AS
BEGIN
	DECLARE @StudentDegree INT = 0;

	SELECT @StudentDegree +=  CASE	
			WHEN (SA.StudentAnswer = Q.CorrectAnswer) 
				 THEN EQ.QusetionDegree
			ELSE 0
			END
	FROM StudentAnswer SA, Question Q, ExamQuestion EQ
	WHERE SA.QuestionId_FK = Q.QuestionId
	AND Q.QuestionId = EQ.QuestionId_FK
	AND SA.StudentId_FK = @StudentId
	AND SA.ExamId_FK = @ExamId
	AND EQ.ExamId_FK = @ExamId;

	RETURN @StudentDegree;
END

SELECT DBO.CorrectStudentExam(1,2)

GO
-----------------------------------------------------------------------
-----------------------------------------------------------------------


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



 /*
	THIS PROC is used to create New Track In Specific Department
	Takes TrackName, And Department ID
 */
 CREATE OR ALTER PROC SP_AddTrackInDepartment @TrackName VARCHAR(100) , @DeptID INT
 AS
 BEGIN
	-- CHECK IF THE TRACK NAME IS ALREADY EXISTS OR NOT
	IF Exists(
		SELECT * 
		FROM Track T
		WHERE T.TrackName = @TrackName
	)
	BEGIN
		PRINT 'Track Is Alraedy Exists'
		RETURN
	END

	-- CHECK IF THE DEPARTMENT ID IS ALREADY EXISTS OR NOT
	IF NOT EXISTS (
		SELECT * FROM Department D
		WHERE D.DeptId = @DeptID
	)
	BEGIN
		PRINT 'DEPARTMENT NOT FOUND'
		RETURN
	END

	-- CREATE THE NEW TRACK
	INSERT INTO Track
	VALUES (@TrackName, @DeptID);

	DECLARE  @NewTrackId INT;
	SET @NewTrackId = SCOPE_IDENTITY()
	SELECT @NewTrackId AS 'TRACK NEW ID';
 END

-----------------------------------------------------------------------
-----------------------------------------------------------------------
 GO


/*
	THIS PROC is used to create New Intake 
	Takes Intake Desc, StartDate And EndDate 
*/
 CREATE OR ALTER PROC SP_AddIntake @Description VARCHAR(100) ,
						@StartDate DATE , @EndDate DATE
 AS
 BEGIN
	-- CHECK IF THE Intake Desc OR Start Date Are ALREADY EXIST OR NOT
	IF Exists(
		SELECT * 
		FROM Intake I
		WHERE I.StartDate = @StartDate 
			OR I.Description = @Description
	)
	BEGIN
		PRINT 'Intake Is Alraedy Exists'
		RETURN
	END

	-- CREATE THE NEW Intake
	INSERT INTO Intake
	VALUES (@Description, @StartDate, @EndDate);

	DECLARE  @NewIntakeId INT;
	SET @NewIntakeId = SCOPE_IDENTITY()
	SELECT @NewIntakeId AS 'Intake NEW ID';
 END


-----------------------------------------------------------------------
-----------------------------------------------------------------------