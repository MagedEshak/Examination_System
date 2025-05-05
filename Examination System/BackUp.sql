BACKUP DATABASE [Examination]
TO DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Examination_System.bak'
WITH FORMAT, INIT,  
     NAME = N'Full Backup of Examination_System',  
     SKIP, NOREWIND, NOUNLOAD, STATS = 10;