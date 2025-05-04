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
go
/*	TO KNOW COURSE NAME BY QUESTION ID */
CREATE OR ALTER FUNCTION GetCourseNameByQuestionID(@QuestionId INT)
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @CourseName VARCHAR(20);

	SELECT @CourseName = C.CourseName 
	FROM Course C, Question Q
	WHERE Q.CourseId_FK = C.CourseId  
	AND Q.QuestionId = @QuestionId

	RETURN @CourseName
END

-----------------------------------------------------------------------
go

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
go

/*
	Creating View To Display All Students Exams Results
	- studnet id , course name , student result , total result , status
	- this view should be for instructor only
*/
select * from view_StudentResults
go
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


/*
	Creating Stored Procedure To Display Student Exams Results By Student ID
	-  course name , student result , total result , status
	- this view should be for Student
*/
go
CREATE OR ALTER Proc sp_StudentResults (@StudentId int)
AS
BEGIN
	SELECT SR.Course, SR.Degree, SR.Total_Degree, SR.Status 
	FROM view_StudentResults SR
	WHERE SR.StudentId_FK = @StudentId
END

EXEC sp_StudentResults 1


--------------------------------------------------------------------

/*	
	this proc to update StudentAnswer table by answers from student
	it takes student id, exam id, and table has (ques no, st answer)
*/
go
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