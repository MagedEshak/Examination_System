

---------view
-------Instructor exam overview.                      view Exams, Students, Courses 

use Examination
GO
create view Instructorcourse_v 
as
select 
concat(U.FirstName ,' ',U.LastName) as 'Instructor Name', C.CourseName


from InstructorTeachCourse ITC

join Instructor I on ITC.InstructorId_FK= I.InstructorId
join Users U on I.UserId_FK=U.UserId
join Course C on ITC.CourseId_FK=C.CourseId

where C.CourseId= ITC.CourseId_FK and I.InstructorId=ITC.InstructorId_FK

select * from  Instructorcourse_v 

------------
go
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



-------------------
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

select * from  StudentExam_v

	
