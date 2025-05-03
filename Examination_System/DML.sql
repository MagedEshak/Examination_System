use Examination;


INSERT INTO Users
    (FirstName, LastName, Gender, PhoneNumber, Email, Password_, Role_)
VALUES
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


INSERT INTO Student
    (City, Street, BuildingNumber, UserId_FK)
VALUES
    ('Cairo', 'Maadi', 12, 1),
    ('Alexandria', 'Smouha', 5, 4),
    ('Giza', 'Dokki', 25, 6),
    ('Cairo', 'Zamalek', 8, 7),
    ('Alexandria', 'Loran', 15, 9),
    ('Giza', 'Haram', 30, 11),
    ('Cairo', 'Nasr City', 7, 33),
    ('Alexandria', 'Miami', 20, 36),
    ('Giza', 'Faisal', 10, 38),
    ('Cairo', 'Abbasia', 3, 39),
    ('Aswan', 'Kornish', 1, 41),
    ('Luxor', 'Karnak', 4, 43);

INSERT INTO Instructor
    (HireDate, UserId_FK)
VALUES
    ('2022-08-15', 2),
    ('2023-01-20', 5),
    ('2024-05-10', 8),
    ('2022-11-01', 12),
    ('2023-07-01', 34),
    ('2024-02-28', 37),
    ('2021-09-05', 40),
    ('2023-04-15', 44);


INSERT INTO TrainingManager
    (UserId_FK)
VALUES
    (3),
    (10),
    (35),
    (42);



INSERT INTO Branch
    (BranchName, ManagerId_FK)
VALUES
    ('Cairo Branch', 62),
    ('Alexandria Branch', 64),
    ('Giza Branch', 66),
    ('Aswan Branch', 68);



INSERT INTO Department
    (DeptName, BranchId_FK)
VALUES
    ('CS', 250),
    ('IT', 260),
    ('SE', 270),
    ('BA', 280),
    ('Marketing', 250),
    ('Accounting', 260),
    ('CE', 280),
    ('Architecture', 250),
    ('Web', 270);

INSERT INTO Track
    (TrackName, DeptId_FK)
VALUES
    ('Web Development', 240),
    ('Mobile Development', 240),
    ('Data Science', 240),
    ('Network Engineering', 250),
    ('Project Management', 250),
    ('Digital Marketing', 260),
    ('Financial Accounting', 270),
    ('Structural Design', 280),
    ('Urban Planning', 290),
    ('Power Systems', 300),
    ('Thermodynamics', 310),
    ('Organic Chemistry', 320);


INSERT INTO Intake
    (Description, StartDate, EndDate)
VALUES
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


INSERT INTO StudentTrackIntake
    (StudentId_FK, TrackId_FK, IntakeId_FK, EnrollmentDate)
VALUES
    (71, 11, 1, '2024-02-05'),
    (72, 12, 2, '2024-06-10'),
    (73, 13, 3, '2024-09-10'),
    (74, 14, 4, '2025-01-15'),
    (75, 15, 5, '2025-02-01'),
    (76, 16, 6, '2025-06-15'),
    (77, 17, 7, '2025-09-01'),
    (78, 18, 8, '2025-11-15'),
    (79, 19, 9, '2025-12-15'),
    (80, 20, 10, '2026-03-15'),
    (81, 21, 11, '2026-05-15'),
    (82, 22, 12, '2026-08-15');


INSERT INTO Course
    (CourseName, CRS_Description, MinDegree, MaxDegree)
VALUES
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


INSERT INTO Question
    (QuestionType, QuestionText, CorrectAnswer, CourseId_FK)
VALUES
    ('mcq', 'What does HTML stand for?', 'Hyper Text Markup Language', 23),
    ('T/F', 'JavaScript is a server-side scripting language.', 'False', 24),
    ('text', 'What is the primary function of a relational database?', 'To store and manage structured data', 25),
    ('mcq', 'Which of the following is not a data structure?', 'Algorithm', 34),
    ('T/F', 'SQL is used to query and manipulate databases.', 'True', 26),
    ('text', 'Name three popular mobile operating systems.', 'Android, iOS, Windows Mobile (or similar)', 27),
    ('mcq', 'The derivative of x^2 is:', '2x', 28),
    ('T/F', 'A matrix with the same number of rows and columns is a square matrix.', 'True', 29),
    ('text', 'What is the role of the kernel in an operating system?', 'Manages system resources', 30),
    ('mcq', 'Which layer of the OSI model is responsible for routing?', 'Network', 31),
    ('T/F', 'Agile is a software development methodology.', 'True', 32),
    ('text', 'What are the four Ps of marketing?', 'Product, Price, Place, Promotion', 33);



INSERT INTO QuestionChoice
    (ChoiceText, QuestionId_FK)
VALUES
    ('Hyper Text Transfer Protocol', 11),
    ('Hyper Text Markup Language', 11),
    ('High-Level Text Language', 11),
    ('Hyperlink and Text Management Language', 11),
    ('True', 12),
    ('False', 12),
    ('Stack', 14),
    ('Queue', 14),
    ('Tree', 14),
    ('Algorithm', 14);


INSERT INTO Exam
    (ExamType, StartTime, EndTime, TotalTime, InstructorId_FK)
VALUES
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

INSERT INTO StudentTakeCourse
    (StudentId_FK, CourseId_FK)
VALUES
    (1, 1),
    (1, 2),
    (4, 2),
    (4, 3),
    (6, 3),
    (6, 4),
    (7, 4),
    (7, 5),
    (9, 5),
    (9, 6),
    (11, 6),
    (11, 7);


INSERT INTO InstructorTeachCourse
    (InstructorId_FK, CourseId_FK, Class, TeachYear)
VALUES
    (2, 1, 1, '2024-01-01'),
    (2, 2, 1, '2024-01-01'),
    (5, 2, 2, '2024-01-01'),
    (5, 3, 1, '2024-01-01'),
    (8, 3, 2, '2024-01-01'),
    (8, 4, 1, '2024-01-01'),
    (2, 4, 2, '2024-01-01'),
    (5, 5, 1, '2024-01-01'),
    (8, 5, 2, '2024-01-01'),
    (2, 6, 1, '2025-01-01'),
    (5, 7, 1, '2025-01-01'),
    (8, 8, 1, '2025-01-01');


INSERT INTO TrackCourse
    (TrackId_FK, CourseId_FK)
VALUES
    (11, 23),
    (12, 24),
    (11, 24),
    (12, 25),
    (13, 30),
    (14, 34),
    (15, 34),
    (16, 29),
    (17, 26);



INSERT INTO StudentAnswer
    (StudentId_FK, QuestionId_FK, ExamId_FK, StudentAnswer)
VALUES
    (71, 11, 30, 'The answer provided by the student for question 11 in exam 120'),
    (74, 12, 32, 'The answer provided by the student for question 12 in exam 120'),
    (76, 13, 34, 'The answer provided by the student for question 13 in exam 122');

INSERT INTO StudentExam
    (StudentId_FK, ExamId_FK, ExamTotalResult)
VALUES
    (71, 30, 75),
    (74, 32, 40),
    (76, 34, 82);

-- ExamQuestion table data
-- Linking questions to exams and defining the degree of each question
INSERT INTO ExamQuestion
    (QuestionId_FK, ExamId_FK, QusetionDegree)
VALUES
    (11, 120, 10),
    (12, 120, 15),
    (13, 122, 20),
    (14, 122, 12);


INSERT INTO TrackCourse
    (TrackId_FK, CourseId_FK)
VALUES
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
