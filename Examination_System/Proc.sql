use Examination;

go

create or alter proc SP_GetEligibleStudentsForExams 
@courseId int
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
	crs.CourseId = @courseId and crs.MinDegree <= se.ExamTotalResult

	
end

go








exec SP_GetEligibleStudentsForExams 50

-------
-- fun if course not has std print msg this not has any std
-- fun if entered invalid course id  print msg enter v crs id
-- 

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

