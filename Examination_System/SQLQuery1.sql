use Examination;

GO
CREATE OR ALTER PROCEDURE AddExamWithQuestions
    @CourseID              INT,
    @InstructorID          INT,
    @ExamType              VARCHAR(10),
    @StartTime             DATETIME2,
    @EndTime               DATETIME2,
    @Mode                  VARCHAR(10),           -- 'Auto' or 'Manual'
    @NumQuestions          INT         = NULL,    -- Used only in Auto mode
    @ManualQuestionList    NVARCHAR(MAX)= NULL,   -- new: 'QID=Degree,QID=Degree,...'
    @ManualQuestionIDs     NVARCHAR(MAX)= NULL,   -- legacy: comma list of IDs
    @QuestionDegree        TINYINT      = 1       -- uniform degree (Auto or legacy Manual)

AS
BEGIN
    SET NOCOUNT ON;

    ----------------------------------------------------
    -- 1) Create the Exam
    INSERT INTO dbo.Exam
      (ExamType, StartTime, EndTime, TotalTime, InstructorId_FK)
    VALUES
      (@ExamType,
       @StartTime,
       @EndTime,
       DATEDIFF(MINUTE, @StartTime, @EndTime),
       @InstructorID);

    DECLARE @ExamID INT = SCOPE_IDENTITY();

    ----------------------------------------------------
    -- 2) Insert ExamQuestion rows
    IF @Mode = 'Auto'
    BEGIN
        -- pick random questions, assign uniform degree
        INSERT INTO dbo.ExamQuestion
          (ExamId_FK, QuestionId_FK, QusetionDegree)
        SELECT TOP(@NumQuestions)
          @ExamID,
          q.QuestionID,
          @QuestionDegree
        FROM dbo.Question AS q
        WHERE q.CourseId_FK = @CourseID
        ORDER BY NEWID();
    END
    ELSE IF @Mode = 'Manual'
    BEGIN
        ----------------------------------------------------------------
        -- 2a) Per-question degree list provided?
        IF @ManualQuestionList IS NOT NULL
        BEGIN
            -- parse QID=Degree pairs
            DECLARE @tblQ TABLE (QuestionID INT, QDegree TINYINT);

            INSERT INTO @tblQ (QuestionID, QDegree)
            SELECT
                TRY_CAST(LEFT(item, CHARINDEX('=',item)-1) AS INT),
                TRY_CAST(SUBSTRING(item, CHARINDEX('=',item)+1, 10) AS TINYINT)
            FROM STRING_SPLIT(@ManualQuestionList, ',') 
            CROSS APPLY (SELECT TRIM(value)) AS v(item)
            WHERE CHARINDEX('=',item) > 0;

            -- insert with individual degrees
            INSERT INTO dbo.ExamQuestion
              (ExamId_FK, QuestionId_FK, QusetionDegree)
            SELECT
              @ExamID,
              QuestionID,
              QDegree
            FROM @tblQ;
        END
        ----------------------------------------------------------------
        -- 2b) Fallback: simple ID list + uniform degree
        ELSE IF @ManualQuestionIDs IS NOT NULL
        BEGIN
            DECLARE @tblIDs TABLE (QuestionID INT);
            INSERT INTO @tblIDs(QuestionID)
            SELECT TRY_CAST(value AS INT)
            FROM STRING_SPLIT(@ManualQuestionIDs, ',')
            WHERE ISNUMERIC(value) = 1;

            INSERT INTO dbo.ExamQuestion
              (ExamId_FK, QuestionId_FK, QusetionDegree)
            SELECT 
              @ExamID,
              QuestionID,
              @QuestionDegree
            FROM @tblIDs;
        END
        ELSE
        BEGIN
            THROW 51000, 'Manual mode requires either ManualQuestionList or ManualQuestionIDs', 1;
        END
    END
    ELSE
    BEGIN
        THROW 51000, 'Invalid Mode – must be Auto or Manual', 1;
    END

    ----------------------------------------------------
    -- 3) Return the new ExamId
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
go
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

--Total possible marks for an exam (sums each questions weight)
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

--Students raw score (sum of weights for correctly answered questions)
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

--Students percentage score
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

--Student�s letter grade (customize cutoffs as needed)
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


CREATE PROCEDURE ValidateStudentExamAccess
    @StudentId INT,
    @ExamId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM Exam e
        JOIN StudentExam se ON e.ExamId = se.ExamId_FK
        WHERE se.StudentId_FK = @StudentId
          AND e.ExamId = @ExamId
          AND GETDATE() BETWEEN e.StartTime AND e.EndTime
    )
    BEGIN
        SELECT 'Access Granted' AS Status;
    END
    ELSE
    BEGIN
        SELECT 'Access Denied' AS Status;
    END
END



IF OBJECT_ID('dbo.ExamSchedule','V') IS NOT NULL
    DROP VIEW dbo.ExamSchedule;
GO
CREATE VIEW dbo.ExamSchedule
AS
SELECT
  e.ExamId,
  e.ExamType,
  u.FirstName + ' ' + u.LastName   AS InstructorName,
  (
     SELECT STRING_AGG(c2.CourseName, ', ') 
       WITHIN GROUP (ORDER BY c2.CourseName)
     FROM (
       SELECT DISTINCT c.CourseName
       FROM dbo.ExamQuestion eq2
       JOIN dbo.Question         q2 ON eq2.QuestionId_FK = q2.QuestionId
       JOIN dbo.Course           c  ON q2.CourseId_FK    = c.CourseId
       WHERE eq2.ExamId_FK = e.ExamId
     ) AS c2
  ) AS CoursesCovered,
  e.StartTime,
  e.EndTime,
  e.TotalTime
FROM dbo.Exam AS e
JOIN dbo.Instructor AS i
  ON e.InstructorId_FK = i.InstructorId
JOIN dbo.Users AS u
  ON i.UserId_FK = u.UserId;
GO

IF OBJECT_ID('dbo.GetEligibleStudentsForExam','P') IS NOT NULL
  DROP PROCEDURE dbo.GetEligibleStudentsForExam;
GO

CREATE PROCEDURE dbo.GetEligibleStudentsForExam
  @ExamID            INT,
  @ExcludeStudentIDs  NVARCHAR(MAX) = NULL  -- e.g. '2,5,17'
AS
BEGIN
  SET NOCOUNT ON;

  --------------------------------------------------
  -- 1) Parse the comma-list of IDs to exclude (if provided)
  DECLARE @tblExclude TABLE (StudentId INT PRIMARY KEY);
  IF @ExcludeStudentIDs IS NOT NULL
  BEGIN
    INSERT INTO @tblExclude (StudentId)
    SELECT DISTINCT TRY_CAST(value AS INT)
    FROM STRING_SPLIT(@ExcludeStudentIDs, ',')
    WHERE TRY_CAST(value AS INT) IS NOT NULL;
  END

  --------------------------------------------------
  -- 2) Pull eligible students and filter out any in @tblExclude
  SELECT DISTINCT
      s.StudentId,
      u.FirstName + ' ' + u.LastName AS StudentName,
      u.Email,
      s.City,
      s.Street
  FROM dbo.Exam                     AS e
  INNER JOIN dbo.InstructorTeachCourse AS itc
      ON e.InstructorId_FK = itc.InstructorId_FK
  INNER JOIN dbo.StudentTakeCourse    AS stc
      ON itc.CourseId_FK   = stc.CourseId_FK
  INNER JOIN dbo.Student            AS s
      ON stc.StudentId_FK   = s.StudentId
  INNER JOIN dbo.Users              AS u
      ON s.UserId_FK        = u.UserId
  WHERE e.ExamId = @ExamID
    AND (
         @ExcludeStudentIDs IS NULL
         OR s.StudentId NOT IN (SELECT StudentId FROM @tblExclude)
        )
  ORDER BY StudentName;  -- order by the alias in the select list
END;
GO




SELECT *
FROM dbo.ExamSchedule
ORDER BY StartTime;

exec ValidateStudentExamAccess 1, 23


EXEC AddExamWithQuestions
  @CourseID            = 3,
  @InstructorID        = 10,
  @ExamType            = 'corrective',
  @StartTime           = '2025-05-02 16:00:00',
  @EndTime             = '2025-05-02 17:00:00',
  @Mode                = 'Auto',
  @ManualQuestionList  = '1=5,2=10,3=7';


  EXEC AddExamWithQuestions
  @CourseID            = 3,
  @InstructorID        = 10,
  @ExamType            = 'corrective',
  @StartTime           = '2025-05-02 16:00:00',
  @EndTime             = '2025-05-02 17:00:00',
  @Mode                = 'Auto',
  @NumQuestions       = 3,
  @QuestionDegree  = 7;


 select * from vw_InstructorQuestions;
 select dbo.fn_ExamTotalQuestions(27)
 select dbo.fn_ExamTotalMarks(27)


 exec dbo.GetEligibleStudentsForExam 25 ,'' 