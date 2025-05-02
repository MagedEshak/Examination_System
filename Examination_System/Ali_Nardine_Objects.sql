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
	END
	ELSE IF(@examTotalDegree < @minDegree)
	BEGIN
		PRINT 'Your Exam Total Degree Is Less Than Minimum Course Degree , Min Course Degree: ' + CAST(@minDegree AS VARCHAR);
	END
	ELSE
	BEGIN
		PRINT 'Your Exam Total Degree Is More Than Maximum Course Degree , Max Degree: ' + CAST(@maxDegree AS VARCHAR);
	END
END;


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

-----------------------------------------------------------------------
-----------------------------------------------------------------------

/*	Function To Calculate Exam Total Result By Exam ID */
CREATE FUNCTION GetExamTotalDegree(@ExamID int)
RETURNS INT
AS
BEGIN
	DECLARE @TotalDegree INT;

	SELECT @TotalDegree = SUM(EQ.QusetionDegree)
	FROM ExamQuestion EQ
	WHERE EQ.ExamId_FK = @ExamID

	RETURN @TotalDegree
END

-----------------------------------------------------------------------
-----------------------------------------------------------------------

/*	TO KNOW COURSE NAME BY QUESTION ID */
CREATE OR ALTER FUNCTION GetCourseNameByQuestionID(@QuestionId INT)
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @CourseName VARCHAR(20);

	SELECT @CourseName = C.CourseName 
FROM Course C, Question Q
WHERE C.CourseId = Q.CourseId_FK AND Q.QuestionId = @QuestionId

	RETURN @CourseName
END

-----------------------------------------------------------------------
-----------------------------------------------------------------------

/*	Function TO KNOW COURSE NAME BY EXAM ID */
CREATE OR ALTER FUNCTION GetCourseNameByExamID(@ExamId INT)
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @CourseName VARCHAR(20);
	DECLARE @QuestionId INT;

	SELECT TOP 1 @QuestionId =  EQ.QuestionId_FK
	FROM ExamQuestion EQ
	WHERE EQ.ExamId_FK = @ExamId

	SET @CourseName = dbo.GetCourseNameByQuestionID(@QuestionId)

	RETURN @CourseName
END
 
-----------------------------------------------------------------------
-----------------------------------------------------------------------


/*
	Creating View To Display All Students Exams Results
	- studnet id , course name , student result , total result , status
	- this view should be for instructor only
*/
CREATE OR ALTER VIEW view_StudentResults
AS
SELECT  SE.StudentId_FK,
		dbo.GetCourseNameByExamID(SE.ExamId_FK) AS 'Course', 
		SE.ExamTotalResult AS 'Degree',
		dbo.GetExamTotalDegree(SE.ExamId_FK) AS 'Total_Degree',
		CASE 
			WHEN (SE.ExamTotalResult < dbo.GetExamTotalDegree(SE.ExamId_FK)/2) THEN 'FAILED'
			ELSE 'PASSED'
		END 
		AS 'Status',
		E.ExamType
FROM StudentExam SE, Exam E
WHERE SE.ExamId_FK = E.ExamId

-----------------------------------------------------------------------
-----------------------------------------------------------------------


/*
	Creating Stored Procedure To Display Student Exams Results By Student ID
	-  course name , student result , total result , status
	- this view should be for Student
*/
CREATE OR ALTER Proc sp_StudentResults (@StudentId int)
AS
BEGIN
	SELECT SR.Course, SR.Degree, SR.Total_Degree, SR.Status 
	FROM StudentResults SR
	WHERE SR.StudentId_FK = @StudentId
END


-----------------------------------------------------------------------
-----------------------------------------------------------------------


/*	Function TO Correct Exam to A student and returns his degree */
CREATE FUNCTION CorrectStudentExam(@StudentId INT, @ExamId INT)
RETURNS INT
AS
BEGIN
	DECLARE @StudentDegree INT = 0;

	-- get student answer from StudentAnswer table 
	-- get the correct answer from Question table
	-- compare , if identical , increment @StudentDegree by question degree
	SELECT @StudentDegree +=  CASE	
			WHEN (SA.StudentAnswer = Q.CorrectAnswer) 
				 THEN EQ.QusetionDegree
			ELSE 0
			END
	FROM StudentAnswer SA, Question Q, ExamQuestion EQ
	WHERE SA.QuestionId_FK = Q.QuestionId
	AND Q.QuestionId = EQ.QuestionId_FK
	AND SA.StudentId_FK = @StudentId
	AND EQ.ExamId_FK = @ExamId 

	RETURN @StudentDegree;
END

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


 -----------------------------------------------------------------------
 -----------------------------------------------------------------------
 

/*	
	this proc to update StudentAnswer table by answers from student
	it takes student id, exam id, and table has (ques no, st answer)
*/
CREATE OR ALTER PROCEDURE UpdateStudentAnswers
    @StudentId INT,
	@ExamId INT,
    @QuestionID INT,
	@StudentAnswer VARCHAR(255)

AS
BEGIN
	DECLARE @CurrentTime DATETIME;
	DECLARE @StartTime DATETIME;
	DECLARE @EndTime DATETIME;

	SET @CurrentTime = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss.fff');

	SELECT @StartTime = E.StartTime, @EndTime = E.EndTime
	FROM Exam E
	WHERE E.ExamId = @ExamID

	IF(  @CurrentTime >=  @StartTime AND @CurrentTime <= @EndTime )
	BEGIN
		UPDATE StudentAnswer
		SET StudentAnswer  = @StudentAnswer
		WHERE	StudentAnswer.ExamId_FK = @ExamId
			AND StudentAnswer.StudentId_FK =  @StudentId
			AND StudentAnswer.QuestionId_FK = @QuestionID

		SELECT SA.QuestionId_FK 'Q.No', SA.StudentAnswer 'Answer'
		FROM StudentAnswer SA
		WHERE	SA.ExamId_FK = @ExamID
			AND SA.StudentId_FK = @StudentId
			AND SA.QuestionId_FK = @QuestionID
	END
	ELSE
		PRINT 'Not Permitted now'
END;

-----------------------------------------------------------------------
-----------------------------------------------------------------------


/*	
	this proc to open exam , it shows all exam questions
	and choices of each question
*/
CREATE OR ALTER PROC OpenExam @ExamID INT
AS
BEGIN
/* get start time and end time of exam*/
DECLARE @StartTime DATETIME;
DECLARE @EndTime DATETIME;
DECLARE @CurrentTime DATETIME;

SET @CurrentTime = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss.fff');

SELECT @StartTime = E.StartTime, @EndTime = E.EndTime
FROM Exam E
WHERE E.ExamId = @ExamID
	
IF(  @CurrentTime >=  @StartTime AND @CurrentTime <= @EndTime )
BEGIN
	SELECT  Q.QuestionId AS 'Q.No',
			Q.QuestionText 'Write True Or False',
			STRING_AGG(QC.ChoiceText , ' | ') AS 'True Or False'
	FROM Question Q, QuestionChoice QC
	WHERE Q.QuestionId = QC.QuestionId_FK AND Q.QuestionType = 'T/F'
	group by Q.QuestionId, Q.QuestionText

	SELECT  Q.QuestionId AS 'Q.No',
			Q.QuestionText 'Choose Correct Answer',
			STRING_AGG(QC.ChoiceText , '    |    ') 'Choices'
	FROM Question Q, QuestionChoice QC
	WHERE Q.QuestionId = QC.QuestionId_FK AND Q.QuestionType = 'mcq'
	group by Q.QuestionId, Q.QuestionText
END
ELSE IF(@CurrentTime >  @EndTime)
BEGIN
	PRINT 'EXAM HAS FINISHED'
END
ELSE IF(@CurrentTime <  @StartTime)
BEGIN
	PRINT 'EXAM HAS NO ACCESS NOW'
END
	
END


-----------------------------------------------------------------------
-----------------------------------------------------------------------

--	Test Cases 

EXEC OpenExam 20   -- student open exam with exam ID

EXEC UpdateStudentAnswers 1, 20, 1, 'true'
EXEC UpdateStudentAnswers 1, 20, 2, 'true' 
EXEC UpdateStudentAnswers 1, 20, 3, 'true' 
EXEC UpdateStudentAnswers 1, 20, 4, 'false' 
EXEC UpdateStudentAnswers 1, 20, 5, 'true' 
EXEC UpdateStudentAnswers 1, 20, 6, 'false' 

/* proc exec to see results */
Exec sp_StudentResults 1   -- student see his all exam results

SELECT * FROM view_StudentResults  -- instructor view , 

/*
	instructor -> put corrective exam , he will select student that have fialed
	in his course exam, (courseID, instructorID)
*/






