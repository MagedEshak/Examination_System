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

GO
----------------------------------------------------------------------

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
	IF NOT Exists(
		select I.InstructorId,C.CourseId,  C.CourseName from 
		Instructor I , Course C, InstructorTeachCourse ITC
		where ITC.InstructorId_FK = @InstructorID AND ITC.CourseId_FK = @CourseID
	)
	BEGIN
		PRINT 'You Dont Teach This Course, Check Course ID, Instructor ID';
		RETURN;
	END
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
	 -- 3) Return the new ExamId
    SELECT @ExamID AS CreatedExamID;
END

GO
    ----------------------------------------------------

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
