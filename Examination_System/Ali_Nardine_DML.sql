INSERT INTO Users (FirstName, LastName, Gender, PhoneNumber, Email, Password_, Role_)
VALUES
('Ahmed', 'Ali', 'm', '01012345678', 'ahmed.ali@gmail.com', 'pass1234', 'student'),
('Sara', 'Hassan', 'f', '01022345678', 'sara.hassan@gmail.com', 'sara5678', 'student'),
('Mona', 'Sayed', 'f', '01112345678', 'mona.sayed@gmail.com', 'mona1234', 'student'),
('Omar', 'Adel', 'm', '01212345678', 'omar.adel@gmail.com', 'omar5678', 'student'),
('Youssef', 'Nabil', 'm', '01512345678', 'youssef.nabil@gmail.com', 'yous1234', 'instructor'),
('Huda', 'Kamal', 'f', '01032345678', 'huda.kamal@gmail.com', 'huda5678', 'instructor'),
('Karim', 'Fahmy', 'm', '01122345678', 'karim.fahmy@gmail.com', 'karim567', 'instructor'),
('Nora', 'Gamal', 'f', '01222345678', 'nora.gamal@gmail.com', 'nora7890', 'training manager'),
('Walid', 'Osman', 'm', '01522345678', 'walid.osman@gmail.com', 'walid456', 'training manager'),
('Alaa', 'Tarek', 'm', '01042345678', 'alaa.tarek@gmail.com', 'alaa9876', 'student');


-- CourseName , description, MinDegree, MaxDegree
insert into Course
values('Arabic', 'You will study Arabic course', 40, 50);

-- QuestionType, Text, CorrectAnswer, CourseID_FK
insert into Question
values ('T/F', 'are you ready', 'true', 1),
	   ('T/F', 'are you Ali', 'true', 1),
	   ('T/F', 'are you Engineer', 'true', 1),
	   ('T/F', 'are you happy', 'false', 1),
	   ('T/F', 'are you eating well', 'false', 1),
	   ('T/F', 'do you enjoy reading', 'false', 1),
	   ('T/F', 'are you working', 'true', 1),
	   ('mcq', 'what is capital of egypt', 'cairo', 1),
	   ('mcq', 'who is captin of egypt football team', 'mo salah', 1),
	   ('mcq', 'who is best player in the world', 'messi', 1),
	   ('mcq', 'what is best club in the world', 'barca', 1),
	   ('mcq', 'what is best club in the Egypt', 'zamalek', 1)

-- Choice Text, QuestionID_FK
insert into QuestionChoice
values	('cairo' ,8),('minia', 8),('assuit',8),('aswan',8),
		( 'mo salah',9),( 'zizo',9),( 'marmoush',9),('emam ashour',9),
		('mo salah', 10),('ronaldo',10),( 'messi',10),( 'ramos',10),
		('paris' ,11),( 'bayren munich',11),('real madrid' ,11),( 'barca',11),
		( 'ahli',12),('zamalek',12),('pyramids',12),('masry',12)
		
-- hireDate, UserID_FK 
insert into Instructor 
values ('05-15-1999', 5)

-- ExamType, StartTime, EndTime, TotalTime, instructorID_FK
insert into Exam
values ('exam', '2025-04-29 10:00:00', '2025-04-29 12:30:00' , 90, 12);

-- QueestionID_FK, ExamID_FK, Degree
insert into ExamQuestion
values (7,20,1),(9,20,1),(10,20,1),(11,20,1)

insert into Student(UserId_FK)
values(1),(2),(3),(4)

-- studentID_FK, examID_FK, Result
insert into StudentExam
values(1,20,41), (2,20,20), (3,20,25) , (4,20,10)



 