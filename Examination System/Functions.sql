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
----------------------------------------------------------------
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
------------------------------------------------------------------
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
------------------------------------------------------------------
/* this function returns Eligible students for specific exam*/
CREATE OR ALTER FUNCTION dbo.fn_GetEligibleStudentsForExam
(
    @ExamID INT
)
RETURNS @StudentIdsTable TABLE
(
    StudentId INT
)
AS
BEGIN
    DECLARE @ExamType VARCHAR(10);
    DECLARE @InstructorId INT;
    DECLARE @CourseName VARCHAR(20);

    -- Get Exam Type
    SELECT @ExamType = E.ExamType
    FROM Exam E
    WHERE E.ExamId = @ExamID;

    -- Get Instructor ID
    SELECT @InstructorId = E.InstructorId_FK
    FROM Exam E
    WHERE E.ExamId = @ExamID;

    -- Get Course Name associated with the exam
    SELECT TOP 1 @CourseName = C.CourseName
    FROM Instructor I
    JOIN Exam E ON E.InstructorId_FK = I.InstructorId
    JOIN ExamQuestion EQ ON EQ.ExamId_FK = E.ExamId
    JOIN Question Q ON Q.QuestionId = EQ.QuestionId_FK
    JOIN Course C ON C.CourseId = Q.CourseId_FK
    WHERE I.InstructorId = @InstructorId;

    -- Insert eligible students based on exam type
    IF (@ExamType = 'exam')
    BEGIN
        INSERT INTO @StudentIdsTable (StudentId)
        SELECT DISTINCT s.StudentId
        FROM Exam e
        INNER JOIN InstructorTeachCourse itc ON e.InstructorId_FK = itc.InstructorId_FK
        INNER JOIN StudentTakeCourse stc ON itc.CourseId_FK = stc.CourseId_FK
        INNER JOIN Student s ON stc.StudentId_FK = s.StudentId
        WHERE e.ExamId = @ExamID;
    END
	-- corrective
    ELSE
    BEGIN
        INSERT INTO @StudentIdsTable (StudentId)
        SELECT StudentId_FK
        FROM view_StudentResults SR
        WHERE SR.Status = 'FAILED'
          AND SR.Course = @CourseName;
    END

    RETURN;
END;
------------------------------------------------------------------
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
------------------------------------------------------------------
CREATE FUNCTION dbo.fn_ExamTotalQuestions
(
    @ExamID INT
)
RETURNS INT
AS
BEGIN
    RETURN (
        SELECT COUNT(*) 
        FROM dbo.ExamQuestion EQ
        WHERE EQ.ExamID_FK = @ExamID
    );
END;
------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_StudentPercentage
(
    @StudentID INT,
    @ExamID    INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE 
        @Raw    INT = dbo.CorrectStudentExam(@StudentID, @ExamID),
        @Total  INT = dbo.GetExamTotalDegree(@ExamID);

    IF @Total = 0
        RETURN 0.00;

    RETURN CAST(100.0 * @Raw / @Total AS DECIMAL(5,2));
END;
------------------------------------------------------------------
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
------------------------------------------------------------------
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
------------------------------------------------------------------
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