use Examination;

---- drop all tables
/*
drop table QuestionChoice			--1
drop table StudentAnswer			--2
drop table StudentExam				--3
drop table StudentTrackIntake		--4
drop table StudentTakeCourse		--5
drop table Student					--6
drop table InstructorTeachCourse	--7
drop table TrackCourse				--8
drop table Track					--9
drop table ExamQuestion				--10
drop table Exam						--11
drop table Question					--12
drop table Instructor				--13
drop table Course					--14
drop table Department				--15
drop table Branch					--16
drop table Intake					--17
drop table TrainingManager			--18
drop table Users					--19
*/


create table Users
(
	UserId int identity(1,1),
	FirstName varchar(20) not null,
	LastName varchar(20),
	Gender char(1),
	PhoneNumber char(11),
	Email varchar(30) not null,
	Password_ varchar(15) not null,
	Role_ varchar(20) not null,

	constraint PK_UserId primary key (UserId),
	constraint UQ_Email unique (Email),
	constraint UQ_PhoneNumber unique (PhoneNumber),
	constraint CK_PhoneNumber check (len (PhoneNumber) = 11 and PhoneNumber like '01[0125]%'),
	constraint CK_Password check (len (Password_) >= 6),
	constraint CK_Role check (Role_ in ('student' , 'instructor', 'training manager')),
	constraint CK_Gender check (Gender in ('m' , 'f')),
	CONSTRAINT CK_Email CHECK (Email LIKE '_%@_%._%')

) on users_FG


create table Student
(
	StudentId int identity(1,1),
	City varchar(15),
	Street varchar(20),
	BuildingNumber SmallInt,
	UserId_FK int

		constraint PK_StudentId primary key (StudentId),
	constraint FK_Student_UserId foreign key(UserId_FK) references Users (UserId),

) on users_FG


create table Instructor
(
	InstructorId int identity(10,2),
	HireDate Date,
	UserId_FK int

		constraint PK_InstructorId primary key (InstructorId),
	constraint FK_Instructor_UserId foreign key(UserId_FK) references Users (UserId),


) on users_FG

create table TrainingManager
(
	ManagerId int identity(2,2),
	UserId_FK int,

	constraint PK_ManagerId primary key (ManagerId),
	constraint FK_TrainingManager_UserId foreign key(UserId_FK) references Users (UserId),

)on users_FG
	
-----------------------------------------------------------------------------------------------
--for File Grop "Branch"
	
create table Branch
(
	BranchId int identity(100,10),
	BranchName varchar(20),
	ManagerId_FK int,

	constraint PK_BranchId primary key (BranchId),
	constraint FK_Branch_ManagerId foreign key(ManagerId_FK) references TrainingManager (ManagerId),

) on branch_FG

create table Department
(
	DeptId int identity(10,10),
	DeptName varchar(20),
	BranchId_FK int,

	constraint PK_DeptId primary key (DeptId),
	constraint FK_Department_BranchId foreign key(BranchId_FK) references Branch (BranchId),

) on branch_FG

create table Track
(
	TrackId int identity(1,1),
	TrackName varchar(100),
	DeptId_FK int,

	constraint PK_TrackId primary key (TrackId),
	constraint FK_Track_DeptId foreign key(DeptId_FK) references Department (DeptId),

) on branch_FG

create table Intake
(
	IntakeId int identity(1,1),
	Description varchar(100),
	StartDate date not null,
	EndDate date not null,

	constraint PK_IntakeId primary key (IntakeId),
	constraint CK_EndDate check(EndDate > StartDate)
) on branch_FG

create table StudentTrackIntake
(
	StudentId_FK int,
	TrackId_FK int,
	IntakeId_FK int,
	EnrollmentDate date,

	constraint PK_StudentTrackIntake primary key (StudentId_FK,IntakeId_FK,EnrollmentDate),
	constraint FK_StudentTrackIntake_StudentId foreign key(StudentId_FK) references Student (StudentId),
	constraint FK_StudentTrackIntake_TrackId foreign key(TrackId_FK) references Track (TrackId),
	constraint FK_StudentTrackIntake_IntakeId foreign key(IntakeId_FK) references Intake (IntakeId),

) on branch_FG

-----------------------------------------------------------------------------------------------
--for File Grop "Material"

create table Course
(
	CourseId int identity(1,1),
	CourseName varchar(100) not null,
	CRS_Description varchar(100),
	MinDegree smallint default 0,
	MaxDegree smallint not null,

	constraint PK_Course primary key (CourseId),
	constraint CK_MaxDegree check(MaxDegree > MinDegree),
	constraint CK_MinDegree check(MinDegree >= 0)

) on material_FG

create table Question
(
	QuestionId int identity(1,1),
	QuestionType varchar(30) not null,
	QuestionText varchar(500) not null,
	CorrectAnswer varchar(255) not null,
	CourseId_FK int,

	constraint PK_Question primary key (QuestionId),
	constraint FK_Question_CourseId foreign key(CourseId_FK) references Course (CourseId),
	
	constraint CK_Question_Type check(QuestionType in ('mcq','T/F', 'text'))

) on material_FG


create table QuestionChoice
(
	ChoiceText varchar(255) not null,
	QuestionId_FK int,

	constraint PK_QuestionChoice primary key (ChoiceText,QuestionId_FK),
	constraint FK_QuestionChoice_QuestionId foreign key(QuestionId_FK) references Question (QuestionId)

) on material_FG

create table Exam
(
	ExamId int identity(20,1),
	ExamType varchar(30) not null,
	StartTime datetime not null,
	EndTime datetime not null,
	TotalTime int default 60,
	InstructorId_FK int,

	constraint PK_Exam primary key (ExamId),
	constraint FK_Exam_InstructorId foreign key(InstructorId_FK) references Instructor(InstructorId),
	constraint CK_ExamType check(ExamType in ('exam' , 'corrective')),
	constraint CK_EndTime check(EndTime > StartTime)
) on material_FG

create table StudentTakeCourse
(
	StudentId_FK int,
	CourseId_FK int,

	constraint PK_StudentTakeCourse primary key (StudentId_FK,CourseId_FK),
	constraint FK_StudentTakeCourse_StudentId foreign key(StudentId_FK) references Student (StudentId),
	constraint FK_StudentTakeCourse_CourseId foreign key(CourseId_FK) references Course (CourseId)

) on material_FG


create table InstructorTeachCourse
(
	InstructorId_FK int,
	CourseId_FK int,
	Class int,
	TeachYear date,

	constraint PK_InstructorTeachCourse primary key (InstructorId_FK,CourseId_FK,Class,TeachYear),
	constraint FK_InstructorTeachCourse_InstructorId foreign key(InstructorId_FK) references Instructor(InstructorId),
	constraint FK_InstructorTeachCourse_CourseId foreign key(CourseId_FK) references Course(CourseId)

) on material_FG

create table TrackCourse
(
	TrackId_FK int,
	CourseId_FK int,

	constraint PK_TrackCourse primary key (TrackId_FK,CourseId_FK),
	constraint FK_TrackCourse_TrackId foreign key(TrackId_FK) references Track(TrackId),
	constraint FK_TrackCourse_CourseId foreign key(CourseId_FK) references Course(CourseId)

) on material_FG


create table StudentAnswer
(
	StudentId_FK int,
	QuestionId_FK int,
	ExamId_FK int,
	StudentAnswer varchar(255),

	constraint PK_StudentAnswer primary key (StudentId_FK, ExamId_FK , QuestionId_FK),
	constraint FK_StudentAnswer_StudentId foreign key(StudentId_FK) references Student (StudentId),
	constraint FK_StudentAnswer_QuestionId foreign key(QuestionId_FK) references Question(QuestionId),
	constraint FK_StudentAnswer_ExamId foreign key(ExamId_FK) references Exam(ExamId)
) on material_FG

create table StudentExam
(
	StudentId_FK int,
	ExamId_FK int,
	ExamTotalResult int,

	constraint PK_StudentExam primary key (StudentId_FK,ExamId_FK),
	constraint FK_StudentExam_StudentId foreign key(StudentId_FK) references Student (StudentId),
	constraint FK_StudentExam_ExamId foreign key(ExamId_FK) references Exam(ExamId)
) on material_FG


create table ExamQuestion
(
	QuestionId_FK int,
	ExamId_FK int,
	QusetionDegree tinyint default 1,

	constraint PK_ExamQuestion primary key (QuestionId_FK, ExamId_FK),
	constraint FK_ExamQuestion_StudentId foreign key(QuestionId_FK) references Question(QuestionId),
	constraint FK_ExamQuestion_ExamId foreign key(ExamId_FK) references Exam(ExamId),
	constraint CK_Question_Degree check(QusetionDegree <= 10)
) on material_FG	
