USE Examination;
GO

BEGIN TRAN;

--------------------------------------------------------------------------------
-- 1) USERS
SET IDENTITY_INSERT dbo.Users ON;
INSERT INTO dbo.Users (UserId, FirstName, LastName, Gender, PhoneNumber, Email, Password_, Role_)
VALUES
  (1, 'Ahmed',   'Ali',    'm', '01001234567', 'ahmed.ali@uni.edu.eg',    'Pwd12345', 'student'),
  (2, 'Mona',    'Saeed',  'f', '01102345678', 'mona.saeed@uni.edu.eg',    'Secure!1', 'student'),
  (3, 'Sara',    'Hassan', 'f', '01203456789', 'sara.hassan@uni.edu.eg',   'SaraPass2', 'instructor'),
  (4, 'Youssef', 'Khaled', 'm', '01504567890', 'youssef.khaled@uni.edu.eg','Yous#2025', 'training manager');
SET IDENTITY_INSERT dbo.Users OFF;
GO

--------------------------------------------------------------------------------
-- 2) STUDENT
SET IDENTITY_INSERT dbo.Student ON;
INSERT INTO dbo.Student (StudentId, City, Street, BuildingNumber, UserId_FK)
VALUES
  (1, 'Cairo',      'Tahrir St.',  10, 1),
  (2, 'Alexandria', 'Corniche St.', 22, 2);
SET IDENTITY_INSERT dbo.Student OFF;
GO

--------------------------------------------------------------------------------
-- 3) INSTRUCTOR
SET IDENTITY_INSERT dbo.Instructor ON;
INSERT INTO dbo.Instructor (InstructorId, HireDate, UserId_FK)
VALUES
  (10, '2020-09-01', 3);
SET IDENTITY_INSERT dbo.Instructor OFF;
GO

--------------------------------------------------------------------------------
-- 4) TRAININGMANAGER
SET IDENTITY_INSERT dbo.TrainingManager ON;
INSERT INTO dbo.TrainingManager (ManagerId, UserId_FK)
VALUES
  (2, 4);
SET IDENTITY_INSERT dbo.TrainingManager OFF;
GO

--------------------------------------------------------------------------------
-- 5) BRANCH
SET IDENTITY_INSERT dbo.Branch ON;
INSERT INTO dbo.Branch (BranchId, BranchName, ManagerId_FK)
VALUES
  (100, 'Cairo Campus',     2),
  (110, 'Alexandria Campus',2);
SET IDENTITY_INSERT dbo.Branch OFF;
GO

--------------------------------------------------------------------------------
-- 6) DEPARTMENT
SET IDENTITY_INSERT dbo.Department ON;
INSERT INTO dbo.Department (DeptId, DeptName, BranchId_FK)
VALUES
  (10, 'Computer Science',    100),
  (20, 'Information Systems', 110);
SET IDENTITY_INSERT dbo.Department OFF;
GO

--------------------------------------------------------------------------------
-- 7) TRACK
SET IDENTITY_INSERT dbo.Track ON;
INSERT INTO dbo.Track (TrackId, TrackName, DeptId_FK)
VALUES
  (1, 'Web Development', 10),
  (2, 'Data Science',    20);
SET IDENTITY_INSERT dbo.Track OFF;
GO

--------------------------------------------------------------------------------
-- 8) INTAKE
SET IDENTITY_INSERT dbo.Intake ON;
INSERT INTO dbo.Intake (IntakeId, Description, StartDate,   EndDate)
VALUES
  (1, 'Spring 2025', '2025-02-01', '2025-06-30'),
  (2, 'Fall 2025',   '2025-09-01', '2025-12-15');
SET IDENTITY_INSERT dbo.Intake OFF;
GO

--------------------------------------------------------------------------------
-- 9) STUDENTTRACKINTAKE
INSERT INTO dbo.StudentTrackIntake
  (StudentId_FK, TrackId_FK, IntakeId_FK, EnrollmentDate)
VALUES
  (1, 1, 1, '2025-02-10'),
  (2, 2, 2, '2025-09-05');
GO

--------------------------------------------------------------------------------
-- 10) COURSE
SET IDENTITY_INSERT dbo.Course ON;
INSERT INTO dbo.Course (CourseId, CourseName, CRS_Description, MinDegree, MaxDegree)
VALUES
  (1, 'ASP.NET',           'Intro to ASP.NET',         0, 100),
  (2, 'SQL Server',        'Advanced SQL Server',      0, 100),
  (3, 'Python Programming','Python for Data Analysis', 0, 100);
SET IDENTITY_INSERT dbo.Course OFF;
GO

--------------------------------------------------------------------------------
-- 11) QUESTION
SET IDENTITY_INSERT dbo.Question ON;
INSERT INTO dbo.Question 
  (QuestionId, QuestionType, QuestionText, CorrectAnswer, CourseId_FK)
VALUES
  (1, 'mcq', 'What does ASP stand for?',      'Active Server Pages',   1),
  (2, 'mcq', 'Which keyword creates a table?', 'CREATE TABLE',         2),
  (3, 'mcq', 'print() is a function in?',      'Python',                3);
SET IDENTITY_INSERT dbo.Question OFF;
GO

--------------------------------------------------------------------------------
-- 12) QUESTIONCHOICE
INSERT INTO dbo.QuestionChoice (ChoiceText, QuestionId_FK)
VALUES
  ('Active Server Pages', 1),
  ('Application Server Pages', 1),
  ('CREATE TABLE', 2),
  ('MAKE TABLE',   2),
  ('Python',       3),
  ('Java',         3);
GO

--------------------------------------------------------------------------------
-- 13) EXAM
SET IDENTITY_INSERT dbo.Exam ON;
INSERT INTO dbo.Exam (ExamId, ExamType, StartTime,             EndTime,               TotalTime, InstructorId_FK)
VALUES
  (20, 'exam',      '2025-05-10 09:00:00', '2025-05-10 10:00:00', 60, 10),
  (21, 'corrective','2025-06-01 14:00:00', '2025-06-01 15:00:00', 60, 10);
SET IDENTITY_INSERT dbo.Exam OFF;
GO

--------------------------------------------------------------------------------
-- 14) STUDENTTAKECOURSE
INSERT INTO dbo.StudentTakeCourse (StudentId_FK, CourseId_FK)
VALUES
  (1, 1),
  (1, 2),
  (2, 3);
GO

--------------------------------------------------------------------------------
-- 15) INSTRUCTORTEACHCOURSE
INSERT INTO dbo.InstructorTeachCourse (InstructorId_FK, CourseId_FK, Class, TeachYear)
VALUES
  (10, 1, 101, '2025-01-01'),
  (10, 2, 102, '2025-01-01');
GO

--------------------------------------------------------------------------------
-- 16) TRACKCOURSE
INSERT INTO dbo.TrackCourse (TrackId_FK, CourseId_FK)
VALUES
  (1, 1),
  (1, 2),
  (2, 3);
GO

--------------------------------------------------------------------------------
-- 17) STUDENTANSWER
INSERT INTO dbo.StudentAnswer (StudentId_FK, QuestionId_FK, ExamId_FK, StudentAnswer)
VALUES
  (1, 1, 20, 'Active Server Pages'),
  (1, 2, 20, 'CREATE TABLE'),
  (2, 3, 21, 'Python');
GO

--------------------------------------------------------------------------------
-- 18) STUDENTEXAM
INSERT INTO dbo.StudentExam (StudentId_FK, ExamId_FK, ExamTotalResult)
VALUES
  (1, 20,  95),
  (2, 21,  80);
GO

--------------------------------------------------------------------------------
-- 19) EXAMQUESTION
INSERT INTO dbo.ExamQuestion (QuestionId_FK, ExamId_FK, QusetionDegree)
VALUES
  (1, 20, 5),
  (2, 20, 5),
  (3, 21, 10);
GO

COMMIT TRAN;

-- Verify counts
SELECT
  (SELECT COUNT(*) FROM dbo.Users)          AS Users,
  (SELECT COUNT(*) FROM dbo.Student)        AS Student,
  (SELECT COUNT(*) FROM dbo.Instructor)     AS Instructor,
  (SELECT COUNT(*) FROM dbo.TrainingManager)AS TrainingManager,
  (SELECT COUNT(*) FROM dbo.Branch)         AS Branch,
  (SELECT COUNT(*) FROM dbo.Department)     AS Department,
  (SELECT COUNT(*) FROM dbo.Track)          AS Track,
  (SELECT COUNT(*) FROM dbo.Intake)         AS Intake,
  (SELECT COUNT(*) FROM dbo.StudentTrackIntake) AS StudentTrackIntake,
  (SELECT COUNT(*) FROM dbo.Course)         AS Course,
  (SELECT COUNT(*) FROM dbo.Question)       AS Question,
  (SELECT COUNT(*) FROM dbo.QuestionChoice) AS QuestionChoice,
  (SELECT COUNT(*) FROM dbo.Exam)           AS Exam,
  (SELECT COUNT(*) FROM dbo.StudentTakeCourse)    AS StudentTakeCourse,
  (SELECT COUNT(*) FROM dbo.InstructorTeachCourse)AS InstructorTeachCourse,
  (SELECT COUNT(*) FROM dbo.TrackCourse)          AS TrackCourse,
  (SELECT COUNT(*) FROM dbo.StudentAnswer)        AS StudentAnswer,
  (SELECT COUNT(*) FROM dbo.StudentExam)          AS StudentExam,
  (SELECT COUNT(*) FROM dbo.ExamQuestion)         AS ExamQuestion;
GO
