use Examination;

INSERT INTO Users (FirstName, LastName, Gender, PhoneNumber, Email, Password_, Role_) VALUES
('Ahmed', 'Ali', 'm', '01012345655', 'ahmed@example.com', '123456', 'student'),
('Fatma', 'Hassan', 'f', '01198765438', 'fatma@example.com', '123456', 'instructor'),
('Khaled', 'Ibrahim', 'm', '01234567894', 'khaled@example.com', '123456', 'training manager'),
('Sara', 'Mahmoud', 'f', '01555555558', 'sara@example.com', '123456', 'student'),
('Omar', 'Gamal', 'm', '01001122362', 'omar@example.com', '123456', 'instructor'),
('Noha', 'Youssef', 'f', '01223345556', 'noha@example.com', '123456', 'student'),
('Mohamed', 'Tarek', 'm', '01112243334', 'mohamed@example.com', 'Cod123456eWord', 'student'),
('Aya', 'Sameh', 'f', '01512312314', 'aya@example.com', '123456', 'instructor'),
('Hassan', 'Fathy', 'm', '01098761432', 'hassan@example.com', '123456', 'student'),
('Salma', 'Adel', 'f', '01276543230', 'salma@example.com', '123456', 'training manager'),
('Ali', 'Ahmed', 'm', '01011223342', 'ali@example.com', '123456', 'student'),
('Hend', 'Kamal', 'f', '01155667781', 'hend@example.com', '123456', 'instructor');


INSERT INTO Student (City, Street, BuildingNumber, UserId_FK) VALUES
('Cairo', 'Maadi', 12, 1),
('Alexandria', 'Smouha', 5, 4),
('Giza', 'Dokki', 25, 6),
('Cairo', 'Zamalek', 8, 7),
('Alexandria', 'Loran', 15, 9),
('Giza', 'Haram', 30, 11)


select * from users
where Role_ = 'training manager'

INSERT INTO Instructor (HireDate, UserId_FK) VALUES
('2022-08-15', 2),
('2023-01-20', 5),
('2024-05-10', 8),
('2022-11-01', 12)


INSERT INTO TrainingManager (UserId_FK) VALUES
(3),
(10)



INSERT INTO Branch (BranchName, ManagerId_FK) VALUES
('Cairo', 6),
('Alexandria', 8)



INSERT INTO Department (DeptName, BranchId_FK) VALUES
('CS', 130), 
('IT', 140)



INSERT INTO Track (TrackName, DeptId_FK) VALUES
('Web Development', 10),
('Mobile Development', 10),
('Data Science', 10),
('Network Engineering', 10),
('Project Management', 20),
('Digital Marketing', 20),
('Financial Accounting', 20),
('Structural Design', 20),
('Urban Planning', 10)


INSERT INTO Intake (Description, StartDate, EndDate) VALUES
('Spring 2024', '2024-03-01', '2024-06-30'),
('Summer 2024', '2024-07-15', '2024-09-30'),
('Fall 2024', '2024-10-15', '2025-01-31'),
('Winter 2025', '2025-02-15', '2025-05-31'),
('Spring 2025', '2025-03-01', '2025-06-30'),
('Summer 2025', '2025-07-15', '2025-09-30'),
('Fall 2025 - A', '2025-10-01', '2025-12-15'),
('Fall 2025 - B', '2025-12-16', '2026-02-28'),
('Winter 2026 - I', '2026-01-15', '2026-04-30'),
('Winter 2026 - II', '2026-05-01', '2026-07-31'),
('Summer 2026 - I', '2026-06-15', '2026-08-31'),
('Summer 2026 - II', '2026-09-01', '2026-11-30');


select S.StudentId from  Student S
select S.TrackId from  Track S
select S.IntakeId from  Intake S


INSERT INTO StudentTrackIntake (StudentId_FK, TrackId_FK, IntakeId_FK, EnrollmentDate) VALUES
(8, 1, 1, '2024-02-05'),
(9, 1, 1, '2024-06-10'),
(10, 2, 1, '2024-09-10'),
(11, 2, 1, '2025-01-15'),
(12, 3, 1, '2025-02-01'),
(13, 3, 1, '2025-06-15')




INSERT INTO Course (CourseName, CRS_Description, MinDegree, MaxDegree) VALUES
('Programming 101', 'Introduction to programming concepts', 0, 100),
('Web Development Basics', 'HTML, CSS, and JavaScript fundamentals', 10, 100),
('Data Structures', 'Understanding and implementing data structures', 15, 100),
('Database Management', 'Relational databases and SQL', 20, 100),
('Mobile App Development', 'Building apps for Android and iOS', 25, 100),
('Calculus I', 'Fundamentals of differential calculus', 0, 100),
('Linear Algebra', 'Vectors, matrices, and linear transformations', 5, 100),
('Operating Systems', 'Principles of operating systems', 15, 100),
('Computer Networks', 'Networking protocols and technologies', 20, 100),
('Software Engineering', 'Principles and practices of software development', 30, 100),
('Marketing Management', 'Strategies and tactics in marketing', 10, 100),
('Financial Accounting', 'Basic principles of financial accounting', 5, 100);


select S.CourseId from  Course S

INSERT INTO Question (QuestionType, QuestionText, CorrectAnswer, CourseId_FK) VALUES
('mcq', 'What does HTML stand for?', 'Hyper Text Markup Language', 6),
('T/F', 'JavaScript is a server-side scripting language.', 'False', 6),
('text', 'What is the primary function of a relational database?', 'To store and manage structured data', 6),
('mcq', 'Which of the following is not a data structure?', 'Algorithm', 6),
('T/F', 'SQL is used to query and manipulate databases.', 'True', 6),
('text', 'Name three popular mobile operating systems.', 'Android, iOS, Windows Mobile (or similar)', 6),
('mcq', 'The derivative of x^2 is:', '2x', 6),
('T/F', 'A matrix with the same number of rows and columns is a square matrix.', 'True', 3),
('text', 'What is the role of the kernel in an operating system?', 'Manages system resources', 3),
('mcq', 'Which layer of the OSI model is responsible for routing?', 'Network', 3),
('T/F', 'Agile is a software development methodology.', 'True', 3),
('text', 'What are the four Ps of marketing?', 'Product, Price, Place, Promotion', 3);


select S.QuestionId , S.QuestionText from   Question S
INSERT INTO QuestionChoice (ChoiceText, QuestionId_FK) VALUES
('Hyper Text Transfer Protocol', 1),
('Hyper Text Markup Language', 1),
('High-Level Text Language', 1),
('Hyperlink and Text Management Language', 1),
('True', 2),
('False', 2),
('Stack', 3),
('Queue', 3),
('Tree', 3),
('Algorithm', 3);


INSERT INTO Exam (ExamType, StartTime, EndTime, TotalTime, InstructorId_FK) VALUES
('exam', '2025-05-10 10:00:00', '2025-05-10 11:00:00', 60, 120),
('corrective', '2025-05-15 14:00:00', '2025-05-15 14:30:00', 30, 120),
('exam', '2025-06-05 09:00:00', '2025-06-05 10:30:00', 90, 122),
('corrective', '2025-06-12 11:00:00', '2025-06-12 11:45:00', 45, 122),
('exam', '2025-07-01 13:00:00', '2025-07-01 14:15:00', 75, 124),
('corrective', '2025-07-08 15:00:00', '2025-07-08 15:30:00', 30, 124),
('exam', '2025-08-03 16:00:00', '2025-08-03 17:00:00', 60, 126),
('corrective', '2025-08-10 10:30:00', '2025-08-10 11:15:00', 45, 126),
('exam', '2025-09-15 12:00:00', '2025-09-15 13:30:00', 90, 128),
('corrective', '2025-09-22 14:30:00', '2025-09-22 15:00:00', 30, 128),
('exam', '2025-10-20 11:30:00', '2025-10-20 12:45:00', 75, 130),
('corrective', '2025-10-27 09:30:00', '2025-10-27 10:00:00', 30, 130);


select StudentId
from Student

select CourseId
from Course

INSERT INTO StudentTakeCourse (StudentId_FK, CourseId_FK) VALUES
(8, 6),
(8, 9),
(8, 3),
(9, 6),
(9, 9),
(9, 3),
(10, 6),
(10, 9),
(10, 3),
(11, 6),
(11, 9),
(11, 3);

select i.InstructorId
from Instructor i

select CourseId
from Course

INSERT INTO InstructorTeachCourse (InstructorId_FK, CourseId_FK, Class, TeachYear) VALUES
(10, 6, 1, '2024-01-01'),
(12, 9, 1, '2024-01-01'),
(14, 3, 2, '2024-01-01'),
(16, 4, 1, '2024-01-01')


select i.TrackId
from Track i

select CourseId
from Course

INSERT INTO TrackCourse (TrackId_FK, CourseId_FK) VALUES
(1, 6),
(1, 9),
(1, 3),
(3, 6),
(3, 4),
(3, 3),
(4, 6),
(4, 9),
(4,4);



INSERT INTO StudentAnswer (StudentId_FK, QuestionId_FK, ExamId_FK, StudentAnswer) VALUES
(71, 11, 30, 'The answer provided by the student for question 11 in exam 120'),
(74, 12, 32, 'The answer provided by the student for question 12 in exam 120'),
(76, 13, 34, 'The answer provided by the student for question 13 in exam 122');

INSERT INTO StudentExam (StudentId_FK, ExamId_FK, ExamTotalResult) VALUES
(71, 30, 75),
(74, 32, 40),
(76, 34, 82);

-- ExamQuestion table data
-- Linking questions to exams and defining the degree of each question
INSERT INTO ExamQuestion (QuestionId_FK, ExamId_FK, QusetionDegree) VALUES
(11, 120, 10),
(12, 120, 15),
(13, 122, 20),
(14, 122, 12);


INSERT INTO TrackCourse (TrackId_FK, CourseId_FK) VALUES
(13, 23),
(14, 24),
(15, 25),
(16, 26),
(17, 27),
(18, 28),
(19, 29),
(20, 30),
(21, 31),
(22, 32);


ALTER TABLE Branch
ADD CONSTRAINT DEF_BranchName
check (BranchName in (
'Alexandria','Aswan','Asyut','Beheira','Beni Suef',
'Cairo','Dakahlia','Damietta','Fayoum','Gharbia',
'Giza','Ismailia','Kafr El Sheikh','Luxor','Matrouh',
'Minya','Monufia','New Valley','North Sinai','Port Said',
'Qalyubia','Qena','Red Sea','Sharqia','Assuit','Sohag',
'South Sinai','Suez'));



