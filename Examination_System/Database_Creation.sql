
create DataBase Examination
on primary
(	
	name = 'Examination',
	fileName = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Examination.mdf',
	size = 10MB,
	fileGrowth = 2MB,
	maxSize = 100MB
),

fileGroup users_FG
(
	name = 'users',
	fileName = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\users.ndf',
	size = 10MB,
	fileGrowth = 2MB,
	maxSize = 100MB
),

fileGroup branch_FG
(
	name = 'branch',
	fileName = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\branch.ndf',
	size = 10MB,
	fileGrowth = 2MB,
	maxSize = 100MB
),

fileGroup material_FG
(
	name = 'material',
	fileName = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\material.ndf',
	size = 10MB,
	fileGrowth = 2MB,
	maxSize = 100MB
)


log on
(
	name = 'Examination_System',
	fileName = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Examination_System.ldf',
	size = 10MB,
	fileGrowth = 2MB,
	maxSize = 100MB
)

---zxs