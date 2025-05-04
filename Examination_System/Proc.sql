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
		select 1
	from StudentTakeCourse
	where CourseId_FK = @courseId
	)
	set @msg = 1

	else
	set @msg = 0

	return @msg
end

go
------------------------------ check Cousre Founded ---------------------------------
create or alter function checkCousreFounded(@courseId int)
returns bit
begin

	declare @msg varchar(100)

	if exists 
	(
		select 1
	from Course
	where CourseId = @courseId
	)
	set @msg = 1

	else
	set @msg = 0

	return @msg
end

go

--------- check Instructor Id ----------------------------------------------------
create or alter function checkInstructorId(@instructorId int , @courseId int)
returns bit
begin

	declare @msg varchar(100)

	if exists 
		(
			select 1
	from InstructorTeachCourse
	where InstructorId_FK = @instructorId and CourseId_FK = @courseId
		)
		set @msg = 1

		else
		set @msg = 0

	return @msg
end

go


--------- SP_Get Eligible Students For Exams  ----------------------------------------------------
create or alter proc SP_GetEligibleStudentsForExams
	@courseId int,
	@instructorId int
as
begin
	declare @correctiveExamId int = 37;

	if  dbo.checkCousreFounded(@courseId) = 0
					begin
		print 'Course not Found'
		return
	end

	else if dbo.checkInstructorId(@instructorId,@courseId) = 0
					begin
		print 'This Instructor do not teach this Course'
		return
	end


	select s.StudentId as 'Student ID', CONCAT(us.FirstName,' ', us.LastName ) as 'Student Name',
		crs.CourseName as 'Course Name'

	from StudentTakeCourse stc
		join
		Student s on stc.StudentId_FK = s.StudentId
		join
		Users us on s.UserId_FK = us.UserId
		join
		Course crs on stc.CourseId_FK = crs.CourseId
	where
	crs.CourseId = @courseId
end

go

exec SP_GetEligibleStudentsForExams @courseId = 23, @instructorId = 120
