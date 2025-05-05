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

----------------------------------------------------------------------
/*
	Creating View To Display All Students Exams Results
	- studnet id , course name , student result , total result , status
	- this view should be for instructor only
*/
select * from view_StudentResults

CREATE OR ALTER VIEW view_StudentResults
AS
SELECT  SE.StudentId_FK,
		dbo.GetCourseNameByExamID(SE.ExamId_FK) AS 'Course', 
		SE.ExamTotalResult AS 'Degree',
		dbo.GetExamTotalDegree(SE.ExamId_FK) AS 'Total_Degree',
		CASE 
			WHEN (SE.ExamTotalResult < dbo.GetExamTotalDegree(SE.ExamId_FK)/2) THEN 'FAILED'
			ELSE 'PASSED'
		END 
		AS 'Status',
		E.ExamType
FROM StudentExam SE, Exam E
WHERE SE.ExamId_FK = E.ExamId
--------------------------------------------------------------------
 select * from InstructorExam_v

 create OR ALTER view InstructorExam_v
as
select DISTINCT concat(U.FirstName,' ', U.LastName) as 'Instructor Name',
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
--------------------------------------------------------------
