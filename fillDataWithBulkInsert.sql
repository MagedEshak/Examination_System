USE Examination;
GO

BULK INSERT dbo.Users
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\Users_real.csv'
WITH
(
  FIRSTROW       = 2,
  FIELDTERMINATOR = ',',
  ROWTERMINATOR   = '0x0a',
  KEEPNULLS,
  TABLOCK
);
GO

BULK INSERT dbo.Student
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\Student_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.Instructor
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\Instructor_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.TrainingManager
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\TrainingManager_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.Branch
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\Branch_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.Department
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\Department_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.Track
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\Track_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.Intake
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\Intake_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

---cccchere
BULK INSERT dbo.StudentTrackIntake
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\StudentTrackIntake_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.Course
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\Course_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.Question
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\Question_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.QuestionChoice
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\QuestionChoice_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.Exam
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\Exam_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.StudentTakeCourse
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\StudentTakeCourse_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.InstructorTeachCourse
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\InstructorTeachCourse_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.TrackCourse
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\TrackCourse_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.StudentAnswer
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\StudentAnswer_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.StudentExam
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\StudentExam_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

BULK INSERT dbo.ExamQuestion
FROM 'F:\CS\Projects\ExaminationSystem\Examination_System\Examination_System\data\ExamQuestion_real.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', KEEPNULLS, TABLOCK);
GO

SELECT 'Users' AS TableName, COUNT(*) AS Rows FROM dbo.Users
UNION ALL
SELECT 'Student', COUNT(*) FROM dbo.Student
-- ... repeat for each table if desired
;
GO
