use Examination;
 /* IN CASE IF EXAM CREATED SUCCESSFULLY*/    
 CREATE OR ALTER PROC AssignStudentsToExam @ExamID INT, @StudentList VARCHAR(MAX)
 AS
 BEGIN
	DECLARE @EligibleStudents TABLE (StudentId INT);

	INSERT INTO @EligibleStudents (StudentId)
	SELECT TRY_CAST(value AS INT)
	FROM STRING_SPLIT(@StudentList, ',')
	WHERE TRY_CAST(value AS INT) IS NOT NULL;

	INSERT INTO StudentAnswer (StudentId_FK, QuestionId_FK, ExamId_FK)
	SELECT 
		S.StudentId, 
		Q.QuestionId_FK,
		@ExamID
	FROM @EligibleStudents S
	CROSS JOIN (
		SELECT EQ.QuestionId_FK
		FROM ExamQuestion EQ 
		WHERE EQ.ExamId_FK = @ExamID
	) Q;


	INSERT INTO StudentExam(StudentId_FK, ExamId_FK)
	SELECT DISTINCT SA.StudentId_FK, SA.ExamId_FK
	FROM StudentAnswer SA
	WHERE SA.ExamId_FK = @ExamID
	
 END


 EXEC GetStudentExamSchedule 15

CREATE PROCEDURE dbo.GetStudentExamSchedule
    @StudentId INT
AS
BEGIN
    SELECT
        e.ExamId,
        e.ExamType,
        u.FirstName + ' ' + u.LastName AS InstructorName,
        (
            SELECT STRING_AGG(c2.CourseName, ', ') 
            WITHIN GROUP (ORDER BY c2.CourseName)
            FROM (
                SELECT DISTINCT c.CourseName
                FROM dbo.ExamQuestion eq2
                JOIN dbo.Question q2 ON eq2.QuestionId_FK = q2.QuestionId
                JOIN dbo.Course c ON q2.CourseId_FK = c.CourseId
                WHERE eq2.ExamId_FK = e.ExamId
            ) AS c2
        ) AS CoursesCovered,
        e.StartTime,
        e.EndTime,
        e.TotalTime
    FROM dbo.StudentExam se
    JOIN dbo.Exam e ON se.ExamId_FK = e.ExamId
    JOIN dbo.Instructor i ON e.InstructorId_FK = i.InstructorId
    JOIN dbo.Users u ON i.UserId_FK = u.UserId
    WHERE se.StudentId_FK = @StudentId
END
GO


EXEC dbo.GetStudentExamSchedule @StudentId = 1;



---------------------------------------------------------
--Students letter grade (customize cutoffs as needed)
CREATE OR ALTER FUNCTION dbo.fn_StudentGrade
(
    @StudentID INT,
    @ExamID    INT
)
RETURNS CHAR(2)
AS
BEGIN
    DECLARE @Pct DECIMAL(5,2) = dbo.fn_StudentPercentage(@StudentID, @ExamID);

    RETURN CASE
        WHEN @Pct >= 90 THEN 'A'
        WHEN @Pct >= 80 THEN 'B'
        WHEN @Pct >= 70 THEN 'C'
        WHEN @Pct >= 60 THEN 'D'
        ELSE               'F'
    END;
END;


CREATE PROCEDURE dbo.GetCourseQuestions
    @CourseId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Q.QuestionId      AS QuestionID,
        Q.QuestionType    AS QuestionType,
        Q.QuestionText    AS QuestionText,
        Q.CorrectAnswer   AS CorrectAnswer,
        COALESCE(
          STRING_AGG(QC.ChoiceText, '  |  ')
            WITHIN GROUP (ORDER BY QC.ChoiceText),
          ''  -- empty string if no choices
        ) AS ChoiceText
    FROM dbo.Question Q
    LEFT JOIN dbo.QuestionChoice QC
      ON Q.QuestionId = QC.QuestionId_FK
    WHERE Q.CourseId_FK = @CourseId
    GROUP BY
        Q.QuestionId,
        Q.QuestionType,
        Q.QuestionText,
        Q.CorrectAnswer
    ORDER BY Q.QuestionId;
END
GO

EXEC dbo.GetCourseQuestions @CourseId = 1;

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
		FROM Question Q, QuestionChoice QC, ExamQuestion EQ
		WHERE Q.QuestionId = QC.QuestionId_FK 
		AND EQ.ExamId_FK = @ExamID
		AND EQ.QuestionId_FK = Q.QuestionId
		AND Q.QuestionType = 'T/F'
		group by Q.QuestionId, Q.QuestionText

		SELECT  Q.QuestionId AS 'Q.No',
				Q.QuestionText 'Choose Correct Answer',
				STRING_AGG(QC.ChoiceText , '    |    ') 'Choices'
		FROM Question Q, QuestionChoice QC, ExamQuestion EQ
		WHERE Q.QuestionId = QC.QuestionId_FK 
		AND EQ.ExamId_FK = @ExamID
		AND EQ.QuestionId_FK = Q.QuestionId
		AND Q.QuestionType = 'mcq'
		group by Q.QuestionId, Q.QuestionText
	END

	ELSE IF(@CurrentTime >  @EndTime)
	BEGIN
		PRINT 'EXAM HAS FINISHED'
	END

	ELSE IF(@CurrentTime <  @StartTime)
	BEGIN
		PRINT 'EXAM HAS NO ACCESS NOW'
	END
	
END








