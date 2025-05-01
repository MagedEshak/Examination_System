use Examination;

go

----------------------------------------------------------------------
-- SP_Get Eligible Students For Exams								--
-- fun if course not has std print msg this not has any std			--
-- fun if entered invalid course id  print msg enter v crs id		--
-- fun if course has this student or not							--
-- fun if check student Total Exam Degree							--
----------------------------------------------------------------------

go

create or alter function checkCousreHasStd(@courseId int)
returns bit
begin
	
	declare @msg varchar(100)

	if exists 
	(
		select 1 from StudentTakeCourse
		where CourseId_FK = @courseId
	)
	set @msg = 1

	else
	set @msg = 0

return @msg
end

go

create or alter function checkCousreFounded(@courseId int)
returns bit
begin
	
	declare @msg varchar(100)

	if exists 
	(
		select 1 from Course
		where CourseId = @courseId
	)
	set @msg = 1

	else
	set @msg = 0

return @msg
end

go

create or alter function checkStudentExamDegree(@studendtId int)
returns bit
begin
	declare @msg varchar(100)

	if exists(
				select 1 from StudentExam
				where ExamTotalResult >= 50 and StudentId_FK = @studendtId
			)
			set @msg = 1

			else 
				set @msg = 0

			return @msg
end
go

create or alter function checkStudentBelongToAnyCourse(@studendtId int)
returns bit
begin
	declare @msg varchar(100)

	if exists(
				select 1 from StudentTakeCourse
				where StudentId_FK = @studendtId
			)
			set @msg = 1

			else 
				set @msg = 0

			return @msg
end

go

create or alter proc SP_GetEligibleStudentsForExams 
@courseId int,
@stdId int
as
begin


	if  dbo.checkCousreFounded(@courseId) = 0
					begin
						print 'Course not Found'
						return
					end

	else if dbo.checkCousreHasStd(@courseId) = 0
					begin
						print 'Course not have any Student'
						return
					end

	else if dbo.checkStudentBelongToAnyCourse(@stdId) = 0
					begin
						print 'This Student not enroll in any course'
						return
					end

	else if dbo.checkStudentExamDegree(@stdId) = 0
					begin
						print 'Student does not meet the required exam score'

							update StudentExam
							set ExamId_FK = 25
							where StudentId_FK = @stdId

							print 'Check your Corrective Exam Date'
						return
					end


	select s.StudentId , us.FirstName, us.LastName , crs.CourseName
	from StudentTakeCourse stc
	join
	Student s on stc.StudentId_FK = s.StudentId
	join
	Users us on s.UserId_FK = us.UserId
	join
	StudentExam se on se.StudentId_FK = s.StudentId
	join
	Course crs on stc.CourseId_FK = crs.CourseId
	where
	crs.CourseId = @courseId and s.StudentId = @stdId and crs.MinDegree <= se.ExamTotalResult
end

go

exec SP_GetEligibleStudentsForExams 3 , 6



select * from StudentExam