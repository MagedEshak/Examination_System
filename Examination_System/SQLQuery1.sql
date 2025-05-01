use Examination;
GO
CREATE or alter PROCEDURE AddExamWithAutoQuestions
    @CourseID INT,
    @InstructorID INT,
    @ExamType VARCHAR(10),
    @StartTime DATETIME,
    @EndTime DATETIME,
    @Mode VARCHAR(10), -- 'Auto' or 'Manual'
    @NumQuestions INT = NULL, -- Used only in Auto mode
    @ManualQuestionIDs NVARCHAR(MAX) = NULL -- Comma-separated list for manual
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert Exam
    INSERT INTO Exam (ExamType, StartTime, EndTime, TotalTime, InstructorId_FK)
    VALUES (
        @ExamType,
        @StartTime,
        @EndTime,
        DATEDIFF(MINUTE, @StartTime, @EndTime),
        @InstructorID
    );

    DECLARE @ExamID INT = SCOPE_IDENTITY();

    IF @Mode = 'Auto'
    BEGIN
        -- Insert random questions from question pool
        INSERT INTO dbo.ExamQuestion (ExamId_FK, QuestionId_FK)
        SELECT TOP (@NumQuestions) @ExamID, QuestionID
        FROM Question
        WHERE CourseId_FK = @CourseID
        ORDER BY NEWID();
    END
    ELSE IF @Mode = 'Manual' AND @ManualQuestionIDs IS NOT NULL
    BEGIN
        -- Create temporary table to hold parsed question IDs
        CREATE TABLE #QuestionIDs (QuestionID INT);

        -- Insert parsed QuestionIDs using STRING_SPLIT
        INSERT INTO #QuestionIDs (QuestionID)
        SELECT TRY_CAST(value AS INT)
        FROM STRING_SPLIT(@ManualQuestionIDs, ',')
        WHERE ISNUMERIC(value) = 1;

        -- Insert into ExamQuestion
        INSERT INTO dbo.ExamQuestion (ExamId_FK, QuestionId_FK)
        SELECT @ExamID, QuestionID FROM #QuestionIDs;

        DROP TABLE #QuestionIDs;
    END
    ELSE
    BEGIN
        THROW 51000, 'Invalid Mode or missing ManualQuestionIDs', 1;
    END

    -- Return the new exam ID
    SELECT @ExamID AS CreatedExamID;
END;

GO

CREATE VIEW vw_InstructorQuestions AS
SELECT
    I.InstructorID,
    C.CourseID,
    C.CourseName,
    Q.QuestionId      AS QuestionID,
    Q.QuestionType    AS QuestionType,
    Q.QuestionText,
    Q.CorrectAnswer,
    QC.ChoiceText     AS ChoiceText
FROM
    Instructor I
    INNER JOIN InstructorTeachCourse ITC
        ON I.InstructorID = ITC.InstructorID_FK
    INNER JOIN Course C
        ON ITC.CourseID_FK = C.CourseID
    INNER JOIN Question Q
        ON C.CourseID     = Q.CourseID_FK
    LEFT JOIN QuestionChoice QC
        ON Q.QuestionId   = QC.QuestionId_FK;

-- 1. Total number of questions in an exam
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
GO

-- 2. Total possible marks for an exam (sums each question�s weight)
CREATE OR ALTER FUNCTION dbo.fn_ExamTotalMarks
(
    @ExamID INT
)
RETURNS INT
AS
BEGIN
    RETURN (
        SELECT ISNULL(SUM(EQ.QusetionDegree), 0)
        FROM dbo.ExamQuestion EQ
        WHERE EQ.ExamID_FK = @ExamID
    );
END;
GO


-- 3. Student�s raw score (sum of weights for correctly answered questions)
CREATE OR ALTER FUNCTION dbo.fn_StudentRawScore
(
    @StudentID INT,
    @ExamID    INT
)
RETURNS INT
AS
BEGIN
    RETURN (
        SELECT ISNULL(SUM(EQ.QusetionDegree), 0)
        FROM dbo.StudentExam SE
        JOIN dbo.StudentAnswer SA
          ON SE.ExamId_FK = SA.ExamId_FK
		JOIN dbo.ExamQuestion EQ
          ON SA.ExamId_FK= EQ.ExamId_FK
		JOIN dbo.Question Q
          ON EQ.QuestionId_FK= Q.QuestionId
        WHERE SE.StudentID_FK = @StudentID
          AND SE.ExamID_FK    = @ExamID
          AND SA.StudentAnswer = Q.CorrectAnswer
    );
END;
GO

-- 4. Student�s percentage score
CREATE OR ALTER FUNCTION dbo.fn_StudentPercentage
(
    @StudentID INT,
    @ExamID    INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE 
        @Raw    INT = dbo.fn_StudentRawScore(@StudentID, @ExamID),
        @Total  INT = dbo.fn_ExamTotalMarks(@ExamID);

    IF @Total = 0
        RETURN 0.00;

    RETURN CAST(100.0 * @Raw / @Total AS DECIMAL(5,2));
END;
GO

-- 5. Student�s letter grade (customize cutoffs as needed)
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
GO


--exec AddExamWithAutoQuestions 1 , 1, 'exam','1-5-2025:13:00;00' ,'1-5-2025:14:00;00' ,
