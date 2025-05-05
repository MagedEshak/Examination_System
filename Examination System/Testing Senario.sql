---------------------------------------------

-- testing senario




-- Instructor will open his course questions to choose some
-- he also can generate the exam automatically
EXEC GetCourseQuestions 1


-- Then he insert new exam in Exam , ExamQuestion   -- manual
EXEC AddExamWithQuestions
  @CourseID            = 1,
  @InstructorID        = 1,
  @ExamType            = 'corrective',
  @StartTime           = '2025-05-05 16:00:00',
  @EndTime             = '2025-05-05 18:00:00',
  @Mode                = 'Manual',
  @ManualQuestionList  = '1=10,2=10,3=10,4=10,5=10';
-- exam id = 39


/*
select *
from StudentTakeCourse stk
where stk.CourseId_FK = 2
*/

-- show eligable students for this exam 
EXEC dbo.GetEligibleStudentsForExam 4;

-- determine student ids to enter this exam
EXEC AssignStudentsToExam 3, '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15'

select *
from
  Question Q , QuestionChoice QC
where Q.CourseId_FK = 1
  And QC.QuestionId_FK = Q.QuestionId

-- students open exam

EXEC GetStudentExamSchedule 1

EXEC OpenExam 3 



-------------------------------------------------
-- students 1 submit answers
--						 St_ID   Exam_ID   Q.No   Answer

EXEC UpdateStudentAnswers  1,	   3,		2,   'True'
EXEC UpdateStudentAnswers  1,	   3,		4,   'False' 
EXEC UpdateStudentAnswers  1,	   3,		5,   '<!DOCTYPE html>' 
EXEC UpdateStudentAnswers  1,	   3,		1,   'Hyper Text Markup Language' 
EXEC UpdateStudentAnswers  1,	   3,		3,   '<a>' 

EXEC UpdateStudentAnswers  2,	   3,		2,   'False'
EXEC UpdateStudentAnswers  2,	   3,		4,   'True' 
EXEC UpdateStudentAnswers  2,	   3,		5,   '<!DOCTYPE html>' 
EXEC UpdateStudentAnswers  2,	   3,		1,   'Hyper Text Markup Language' 
EXEC UpdateStudentAnswers  2,	   3,		3,   'cc' 


-- SHOW STUDENT RESULT
--                      St_ID
Exec sp_StudentResults   2

------------------------------------------------------------------------------

-- students 1 submit answers
--						 St_ID   Exam_ID   Q.No   Answer
EXEC UpdateStudentAnswers  1,	   2,		2,   'True'
EXEC UpdateStudentAnswers  1,	   2,		4,   'False'
EXEC UpdateStudentAnswers  1,	   2,		5,   '<!DOCTYPE html>'
EXEC UpdateStudentAnswers  1,	   2,		1,   'Hyper Text Markup Language'
EXEC UpdateStudentAnswers  1,	   2,		3,   '<a>'

-- SHOW STUDENT RESULT
--                      St_ID
Exec sp_StudentResults   1

-- students 1 submit answers
--						 St_ID   Exam_ID   Q.No   Answer
EXEC UpdateStudentAnswers  1,	   2,		2,   'True'
EXEC UpdateStudentAnswers  1,	   2,		4,   'False'
EXEC UpdateStudentAnswers  1,	   2,		5,   '<!DOCTYPE html>'
EXEC UpdateStudentAnswers  1,	   2,		1,   'Hyper Text Markup Language'
EXEC UpdateStudentAnswers  1,	   2,		3,   '<a>'

-- SHOW STUDENT RESULT
--                      St_ID
Exec sp_StudentResults   1

------------------------------------------------------------

-- put corrective exam to failed students
EXEC AddExamWithQuestions
  @CourseID            = 3,
  @InstructorID        = 14,
  @ExamType            = 'corrective',
  @StartTime           = '2025-05-02 16:00:00',
  @EndTime             = '2025-05-03 23:59:00',
  @Mode                = 'Manual',
  @ManualQuestionList  = '8=8,9=10,10=7,11=8,12=10';
-- exam id = 38

-- show eligable students for this exam 
EXEC dbo.GetEligibleStudentsForExam 23;

-- students 1 submit answers
--						 St_ID   Exam_ID   Q.No   Answer
EXEC UpdateStudentAnswers  1,	   2,		2,   'True'
EXEC UpdateStudentAnswers  1,	   2,		4,   'False'
EXEC UpdateStudentAnswers  1,	   2,		5,   '<!DOCTYPE html>'
EXEC UpdateStudentAnswers  1,	   2,		1,   'Hyper Text Markup Language'
EXEC UpdateStudentAnswers  1,	   2,		3,   '<a>'

-- SHOW STUDENT RESULT
--                      St_ID
Exec sp_StudentResults   1


--------------------------------------------------------------------------




---- Training Manager Tasks

-- create new training manager

EXEC SP_InsertNewTrainingManager 
@fName = 'Khaled',
@lName = 'Moustafa',
@gender = 'm',
@PhoneNumber = '01150250978',
@email = 'ahmKehalcced.al@gmail.com',
@password = '123456789'

select *
from TrainingManager



select * from branch 
select * from TrainingManager


-- Creating Branch
--          manager id in user table
--                    Man_ID       BranchName
EXEC SP_CreateBranch   76    ,		'Minya'


select * from branch 
-- Updating Branch
--          manager id in user table
--                   UserID    BranchID
exec SP_UpdateBranch   74,      8,			'Asyut'

----------------------------------------------------------
-- inserting new Student
exec SP_InsertNewStd
@userID = 74,              -- manager id in user table
@fName = 'Ahmed',
@lName = 'Belal',
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

select * from Users
-- updating Student

exec SP_UpdateStudent
@TManagerID = 74,        -- manager id in user table
@UserStudentID = 75,     -- student id in user table
@stdId = 51,
@PhoneNumber = '01234565788',
@email = 'aliG@gmail.com',
@password = '123456799',
@city = 'Assuit',
@street = 'Al Galaa ST',
@BuildingNum = 5
go

--------------------------------------------------------------

select * from Track
select * from Intake

-- need modification
-- adding Student To track
exec SP_InsertNewStdToTrack 
@userID = 74,
@stdID = 51,
@TrackId_FK = 11,
@IntakeId_FK = 8,
@EnrollmentDate = '2026-07-15'



select * from Track
select * from Department
---------------------------------------------
-- adding track					 Track Name                Dept_ID
Exec SP_AddTrackInDepartment	'Virtualization_Advanced',   3

---------------------------------------------
-- adding intake		Description				StartDate		  EndDate
Exec SP_AddIntake	'R13 Summer 2026 - II',	  '2026-12-01', 	'2026-12-30'





