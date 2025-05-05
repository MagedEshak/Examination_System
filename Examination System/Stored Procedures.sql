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
--------------------------------------------------------------------

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
--------------------------------------------------------------------
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
--------------------------------------------------------------------
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
 ------------ SP to Get TM ID after check if userId Role = TM -------------------
create or alter proc SP_GetTMId_afterCheck
@userId int,
@trainingManagerId int output
as
begin

	if exists(
		select 1 from TrainingManager
		where UserId_FK = @userID
		)
		begin
			select @trainingManagerId = ManagerId from TrainingManager
			where UserId_FK = @userID
			print 'Training Manager Found'
		end

		else
		begin
			set @trainingManagerId = 0
		end
end
-----------------------------------------------------------------------
------------ SP to Update Branch -------------------
create or alter proc SP_UpdateBranch
@userID  int,
@BranchId int,
@BranchName varchar(20)
as
begin
declare @tm int
declare @trainingManagerId int

exec SP_GetTMId_afterCheck @userID , @tm output

	if exists
		(
			select 1 from TrainingManager 
			where ManagerId = @tm
		)
		begin
			set @trainingManagerId = @tm
		end

	else
		begin
			 print 'Training Manager not found'
            return
		end

	if exists
			(
				select 1 from Branch
				where BranchId = @BranchId
			)
			begin
				
				if exists
					(
						select 1 from Branch
						where BranchName = @BranchName and BranchId <> @BranchId
					)
			begin
			 print 'Branch name already used by another branch.'
            return
			end
				begin try
				print 'Branch Found'
				if exists ( select 1 from Branch 
					where BranchId = @BranchId and ManagerId_FK = @trainingManagerId 
				)
				begin
				update Branch
				set BranchName = @BranchName
				where BranchId = @BranchId and ManagerId_FK = @trainingManagerId
				
				print 'Branch Updated'
				end

				else
					print 'This manager has no access on this branch'

				end try

				begin catch
						print 'Error Training Manager ID'
				end catch
		end
    else
    begin
        print 'Branch ID not found.'
    end
end
----------------------------------------------------------------------
------------ SP to Insert New Std -------------------
create or alter proc SP_InsertNewStd
@userID  int,
@fName varchar(20),
@lName varchar(20),
@gender char(1),
@PhoneNumber char(11),
@email varchar(30),
@password varchar(15),
@city varchar(15),
@street varchar(20),
@BuildingNum smallint
as
begin
declare @tm int
declare @trainingManagerId int

declare  @newUserId  int


exec SP_GetTMId_afterCheck @userID , @tm output
	if exists
		(
			select 1 from TrainingManager 
			where ManagerId = @tm
		)
		begin
			set @trainingManagerId = @tm
		end

	else
		begin
			 print 'Training Manager not found'
            return
		end

	if exists
			(
				select 1 from Users
				where Email = @email 
			)
			begin
				print 'Student Found and Email Found'
				print 'Please, Enter New Student'
			end

	if exists
			(
				select 1 from Users
				where PhoneNumber = @PhoneNumber
			)
			begin
				print 'Student Found and Phone Found'
				print 'Please, Enter New Student'
			end

	else
		begin
			begin try
				insert into Users(FirstName,LastName,Gender,PhoneNumber,Email,Password_,Role_)
				values (@fName,@lName,@gender,@PhoneNumber,@email,@password,'student')
				print 'New User was Created'
						
				set @newUserId = SCOPE_IDENTITY()
								

				insert into Student(City,Street,BuildingNumber,UserId_FK)
				values (@city,@street,@BuildingNum,@newUserId)
				print 'New Student was Created'
			end try

			begin catch
					print 'Error Training Manager ID'
			end catch	
		end	
end
----------------------------------------------------------------------
------------ SP to Update Student -------------------
create or alter proc SP_UpdateStudent
@TManagerID  int,
@UserStudentID int,
@stdId int,
@fName varchar(20) =  null,
@lName varchar(20) =  null,
@gender char(1)=  null,
@PhoneNumber char(11) =  null,
@email varchar(30)=  null,
@password varchar(15) =  null,
@city varchar(15) =  null,
@street varchar(20) =  null,
@BuildingNum smallint =  null
as
begin
declare @tm int
declare @trainingManagerId int

exec SP_GetTMId_afterCheck @TManagerID , @tm output

	if exists
		(
			select 1 from TrainingManager 
			where ManagerId = @tm
		)
		begin
			set @trainingManagerId = @tm
		end

	else
		begin
			 print 'Training Manager not found'
            return
		end

	if exists
			(
				select 1 from Users
				where UserId = @UserStudentID and Role_ = 'student'
			)
			begin
					if exists
					(
						select 1 from Student
						where StudentId = @stdId and UserId_FK = @UserStudentID
					)

			begin
				begin try
				print 'Student was Found'
		
				update Users
				set FirstName = ISNULL(@fName,FirstName),
					LastName = ISNULL(@lName,LastName),
					Email = ISNULL(@email,Email),
					Gender = ISNULL(@gender,Gender),
					PhoneNumber = ISNULL(@PhoneNumber,PhoneNumber),
					Password_ = ISNULL(@password,Password_)
					where UserId = @UserStudentID and Role_ = 'student'

				print 'Student User was Updated'

				update Student
				set City = ISNULL(@city,City),
					Street = ISNULL(@street,Street),
					BuildingNumber = ISNULL(@BuildingNum,BuildingNumber)
					where UserId_FK = @UserStudentID and StudentId = @stdId

				print 'Student Address was Updated'
				end try

				begin catch
						print 'Error Student Data'
				end catch
			end
		end
    else
    begin
        print 'Student ID not found'
    end
end
---------------------------------------------------------------------
------------ SP to Insert New Std to Track -------------------
create or alter proc SP_InsertNewStdToTrack
	@userID int,
	@stdID  int,
	@TrackId_FK int,
	@IntakeId_FK int,
	@EnrollmentDate date
as
begin
	declare @tm int
	declare @trainingManagerId int

	exec SP_GetTMId_afterCheck @userID , @tm output
	if exists
	(
		select 1
	from TrainingManager
	where ManagerId = @tm
	)
	begin
		set @trainingManagerId = @tm
	end

	else
	begin
		print 'Training Manager not found'
		return
	end

	if exists (
		select 1
	from StudentTrackIntake
	where StudentId_FK = @stdID and TrackId_FK = @TrackId_FK and IntakeId_FK = @IntakeId_FK
	)
		begin
		print 'Student already assigned to this Track and Intake'
		return
	end
else
begin
		begin try
		insert into StudentTrackIntake
			(StudentId_FK, TrackId_FK, IntakeId_FK, EnrollmentDate)
		values
			(@stdID, @TrackId_FK, @IntakeId_FK, @EnrollmentDate)
		print 'New Student was Added in this Track'
	end try
	begin catch
		print 'Error Student or Track Id or Intake Id is incorrect'
	end catch
	end
end
-------------------------------------------------------------------
create or alter proc SP_InsertNewTrainingManager
@fName varchar(20),
@lName varchar(20),
@gender char(1),
@PhoneNumber char(11),
@email varchar(30),
@password varchar(15)
as
begin

declare  @newUserId  int


	if exists
			(
				select 1 from Users
				where Email = @email 
			)
			begin
				print 'Training Manager Found and Email Found'
				print 'Please, Enter New Training Manager'
			end

	if exists
			(
				select 1 from Users
				where PhoneNumber = @PhoneNumber
			)
			begin
				print 'Training Manager and Phone Found'
				print 'Please, Enter New Training Manager'
			end

	else
		begin
			begin try
				insert into Users(FirstName,LastName,Gender,PhoneNumber,Email,Password_,Role_)
				values (@fName,@lName,@gender,@PhoneNumber,@email,@password,'training manager')
				print 'New User was Created'
						
				set @newUserId = SCOPE_IDENTITY()
								

				insert into TrainingManager(UserId_FK)
				values (@newUserId)
				print 'New Training Manager was Created'
			end try

			begin catch
					print 'Error Training Manager ID'
			end catch	
		end	
end
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
----------------------------------------------------------------
/*
	Creating Stored Procedure To Display Student Exams Results By Student ID
	-  course name , student result , total result , status
	- this view should be for Student
*/
CREATE OR ALTER Proc sp_StudentResults (@StudentId int)
AS
BEGIN
	SELECT SR.Course, SR.Degree, SR.Total_Degree, SR.Status 
	FROM view_StudentResults SR
	WHERE SR.StudentId_FK = @StudentId
END
------------------------------------------------------------------
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
------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.GetEligibleStudentsForExam 
   @ExamID  INT
AS
BEGIN
	select * from dbo.fn_GetEligibleStudentsForExam(@ExamID)
END;
------------------------------------------------------------------
