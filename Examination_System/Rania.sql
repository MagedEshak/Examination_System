CREATE OR ALTER PROCEDURE dbo.GetEligibleStudentsForExam 
   @ExamID  INT
AS
BEGIN
	select * from dbo.fn_GetEligibleStudentsForExam(@ExamID)
END;
GO



--------------------------------------------------------------------------



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

GO

 ------------ SP to Create new Branch ----------------------------

create or alter proc SP_CreateBranch
@userID  int,
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
				where BranchName = @BranchName
			)
			begin
				print 'Branch Name Found'
			end

	else
		begin
				begin try
				insert into Branch (BranchName, ManagerId_FK)
							values (@BranchName,@trainingManagerId)
							print 'Branch Created'
				end try

				begin catch
						print 'Enter Correct Branch Name'
				end catch
			
				
		end	
end

GO
 --------------------------------------------------------------------
 /* Views*/
 --------------------------------------------------------------------
 create view InstructorExam_v
as
select concat(U.FirstName,' ', U.LastName) as 'Instructor Name',
C.CourseName, E.ExamType

from Exam E

join Instructor I on E.InstructorId_FK=I.InstructorId
join Users U on I.UserId_FK=U.UserId
join ExamQuestion EQ on EQ.ExamId_FK=E.ExamId
join Question Q on EQ.QuestionId_FK=Q.QuestionId
join Course C on Q.CourseId_FK=C.CourseId
where I.InstructorId =E.InstructorId_FK

select * from InstructorExam_v 

--------------------------------------------------------------

go

create view StudentExam_v
as
select
  concat(U.FirstName,' ', U.LastName) as 'Student Name',
  C.CourseName, E.ExamType,SE.ExamTotalResult
from StudentExam SE

join Student S on SE.StudentId_FK=S.StudentId
join Users U on S.UserId_FK=U.UserId
join Exam E on SE.ExamId_FK= E.ExamId
join Course C on E.ExamId in(
    select ExamId_FK
    from ExamQuestion EQ
    join Question Q on EQ.QuestionId_FK = Q.QuestionId
    where Q.CourseId_FK = C.CourseId
	)



------------------------------------------------------------------------------------
------- exec SP_CreateBranch
exec SP_CreateBranch 3,430,'Sharqia'

select * from Branch