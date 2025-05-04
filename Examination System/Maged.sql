use Examination;

go

------------ Function to check if userId Role = TM -------------------
create OR Alter function checkTMRole(@userID int)
returns bit
begin
	declare @msg varchar(100)

	if exists
	(
		select 1
	from Users
	where UserId = @userID and Role_ = 'training manager'
	)
	set @msg = 1

	else
	set @msg = 0
	return @msg
end
go

------------ SP to Get TM ID after check if userId Role = TM -------------------
create or alter proc SP_GetTMId_afterCheck
	@userId int,
	@trainingManagerId int output
as
begin

	if exists(
		select 1
	from TrainingManager
	where UserId_FK = @userID
		)
		begin
		select @trainingManagerId = ManagerId
		from TrainingManager
		where UserId_FK = @userID
		print 'Training Manager Found'
	end

		else
		begin
		set @trainingManagerId = 0
	end
end


go

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

	if exists
			(
				select 1
	from Branch
	where BranchId = @BranchId
			)
			begin

		if exists
					(
						select 1
		from Branch
		where BranchName = @BranchName and BranchId <> @BranchId
					)
			begin
			print 'Branch name already used by another branch.'
			return
		end
		begin try
				print 'Branch Found'
		
				update Branch
				set BranchName = @BranchName
				where BranchId = @BranchId and ManagerId_FK = @trainingManagerId
				
				print 'Branch Updated'
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
go

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

	if exists
			(
				select 1
	from Users
	where Email = @email 
			)
			begin
		print 'Student Found and Email Found'
		print 'Please, Enter New Student'
	end

	if exists
			(
				select 1
	from Users
	where PhoneNumber = @PhoneNumber
			)
			begin
		print 'Student Found and Phone Found'
		print 'Please, Enter New Student'
	end

	else
		begin
		begin try
				insert into Users
			(FirstName,LastName,Gender,PhoneNumber,Email,Password_,Role_)
		values
			(@fName, @lName, @gender, @PhoneNumber, @email, @password, 'student')
				print 'New User was Created'
						
				set @newUserId = SCOPE_IDENTITY()
								

				insert into Student
			(City,Street,BuildingNumber,UserId_FK)
		values
			(@city, @street, @BuildingNum, @newUserId)
				print 'New Student was Created'
			end try

			begin catch
					print 'Error Training Manager ID'
			end catch
	end
end
go

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

	if exists
			(
				select 1
	from Users
	where UserId = @UserStudentID and Role_ = 'student'
			)
			begin
		if exists
					(
						select 1
		from Student
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
go

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

------- EXEC Queries
------------------------------------------------------------------------------------
------- exec SP_UpdateBranch
exec SP_UpdateBranch 3,320,'Asyut'

select *
from Branch
------------------------------------------------------------------------------------
------- exec SP_InsertNewStd
exec SP_InsertNewStd
@userID = 35,
@fName = 'Ali',
@lName = 'Gamal',
@gender = 'm',
@PhoneNumber = '01234565788',
@email = 'aliG@gmail.com',
@password = '123456789',
@city = 'Minia',
@street = 'Al Galaa ST',
@BuildingNum = 5

select *
from Users
select *
from Student
------------------------------------------------------------------------------------
------- exec SP_UpdateStudent
exec SP_UpdateStudent
@TManagerID = 35,
@UserStudentID = 55,
@stdId = 87,
@PhoneNumber = '01234565788',
@email = 'aliG@gmail.com',
@password = '123456789',
@city = 'Assuit',
@street = 'Al Galaa ST',
@BuildingNum = 5
go
------------------------------------------------------------------------------------
------- SP_InsertNewStdToTrack
exec SP_InsertNewStdToTrack 
@userID = 35,
@stdID = 87,
@TrackId_FK = 11,
@IntakeId_FK = 21,
@EnrollmentDate = '2026-07-15'

select *
from StudentTrackIntake
select *
from Track
select *
from Intake

go
------------------------------------------------------------------
---------view
-------Instructor exam overview.                   view Exams, Students, Courses 

create or alter view Instructorcourse_v
as
	select
		concat(U.FirstName ,' ',U.LastName) as 'Instructor Name', C.CourseName,
		ITC.Class as 'Class Number', ITC.TeachYear as 'Teach Year'


	from InstructorTeachCourse ITC

		join Instructor I on ITC.InstructorId_FK= I.InstructorId
		join Users U on I.UserId_FK=U.UserId
		join Course C on ITC.CourseId_FK=C.CourseId


	where C.CourseId= ITC.CourseId_FK and I.InstructorId=ITC.InstructorId_FK


select *
from Instructorcourse_v

go
-------------------------------------------------------------------
create or alter proc SP_InsertNewTrainingManager
	@userID  int,
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
				select 1
	from Users
	where Email = @email 
			)
			begin
		print 'Training Manager Found and Email Found'
		print 'Please, Enter New Training Manager'
	end

	if exists
			(
				select 1
	from Users
	where PhoneNumber = @PhoneNumber
			)
			begin
		print 'Training Manager and Phone Found'
		print 'Please, Enter New Training Manager'
	end

	else
		begin
		begin try
				insert into Users
			(FirstName,LastName,Gender,PhoneNumber,Email,Password_,Role_)
		values
			(@fName, @lName, @gender, @PhoneNumber, @email, @password, 'training manager')
				print 'New User was Created'
						
				set @newUserId = SCOPE_IDENTITY()
								

				insert into TrainingManager
			(UserId_FK)
		values
			(@newUserId)
				print 'New Training Manager was Created'
			end try

			begin catch
					print 'Error Training Manager ID'
			end catch
	end
end
go
