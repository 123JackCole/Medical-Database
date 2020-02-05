/***************************************************************************
ETL Final Project: Backup Final Database
Dev: JCole
Date: 8/14/2018
Desc: This is a Data Warehouse for the Patient and DoctorsSchedule Databases.
	  ETL processing issues.
ChangeLog: (Who, When, What) 
			JCole, 8/14/18, Created File
			JCole, 8/17/18, Created Backups + Automated Using SQL Agent
*****************************************************************************/

USE [TempDB];
Go

SET NoCount ON;
Go

-- DoctorsSchedules
If Exists(Select * from Sys.objects where Name = 'pMaintRefreshDoctorsSchedules')
	Drop Procedure pMaintRefreshDoctorsSchedules;
Go

Create Procedure pMaintRefreshDoctorsSchedules
/* Author: JCole
** Desc: Backups the DoctorsSchedules and restores a copy of it for reporting 
** Change Log: When,Who,What
** 8/17/18,JCole,Created Sproc.
*/
As
Begin
	Declare @RC int = 0;
	Begin Try
		-- Step 1: Make a copy of the current database
		BACKUP DATABASE [DoctorsSchedules] 
		TO DISK = N'C:\_BISolutions\DoctorsSchedules.bak' 
		WITH INIT;
		-- Step 2: Restore the copy as a different database for reporting
		RESTORE DATABASE [DoctorsSchedules-ReadOnly] 
		FROM DISK = N'C:\_BISolutions\DoctorsSchedules.bak' 
		WITH FILE = 1
			, MOVE N'DoctorsSchedules' TO N'C:\_BISolutions\DoctorsSchedules-Reports.mdf'
			, MOVE N'DoctorsSchedules_log' TO N'C:\_BISolutions\DoctorsSchedules-Reports.ldf'
			, REPLACE;
		-- Step 3: Set the reporting database to read-only
		ALTER DATABASE [DoctorsSchedules-ReadOnly] SET READ_ONLY WITH NO_WAIT;
		Set @RC = +1
	End Try
	Begin Catch
		Print Error_Message()
		Set @RC = -1
	End Catch
	Return @RC;
End
Go

/* Testing Code:
 Declare @Status int;
 Exec @Status = pMaintRefreshDoctorsSchedules;
 Print @Status;
 Select * from SysDatabases Where Name like 'DoctorsSchedules%';
 Select name, create_date, is_read_only from Sys.Databases Where Name like 'DoctorsSchedules%';
*/

-- Patients
If Exists(Select * from Sys.objects where Name = 'pMaintRefreshPatients')
	Drop Procedure pMaintRefreshPatients;
Go

Create Procedure pMaintRefreshPatients
/* Author: JCole
** Desc: Backups the Patients and restores a copy of it for reporting 
** Change Log: When,Who,What
** 8/17/18,JCole,Created Sproc.
*/
As
Begin
	Declare @RC int = 0;
	Begin Try
		-- Step 1: Make a copy of the current database
		BACKUP DATABASE [Patients] 
		TO DISK = N'C:\_BISolutions\Patients.bak' 
		WITH INIT;
		-- Step 2: Restore the copy as a different database for reporting
		RESTORE DATABASE [Patients-ReadOnly] 
		FROM DISK = N'C:\_BISolutions\Patients.bak' 
		WITH FILE = 1
			, MOVE N'Patients' TO N'C:\_BISolutions\Patients-Reports.mdf'
			, MOVE N'Patients_log' TO N'C:\_BISolutions\Patients-Reports.ldf'
			, REPLACE;
		-- Step 3: Set the reporting database to read-only
		ALTER DATABASE [Patients-ReadOnly] SET READ_ONLY WITH NO_WAIT;
		Set @RC = +1
	End Try
	Begin Catch
		Print Error_Message()
		Set @RC = -1
	End Catch
	Return @RC;
End
Go

/* Testing Code:
 Declare @Status int;
 Exec @Status = pMaintRefreshPatients;
 Print @Status;
 Select * from SysDatabases Where Name like 'Patients%';
 Select name, create_date, is_read_only from Sys.Databases Where Name like 'Patients%';
*/

-- DWClinicReportData
If Exists(Select * from Sys.objects where Name = 'pMaintRefreshDWClinicReportData')
	Drop Procedure pMaintRefreshDWClinicReportData;
Go

Create Procedure pMaintRefreshDWClinicReportData
/* Author: JCole
** Desc: Backups the DWClinicReportData and restores a copy of it for reporting 
** Change Log: When,Who,What
** 8/17/18,JCole,Created Sproc.
*/
As
Begin
	Declare @RC int = 0;
	Begin Try
		-- Step 1: Make a copy of the current database
		BACKUP DATABASE [DWClinicReportData] 
		TO DISK = N'C:\_BISolutions\DWClinicReportData.bak' 
		WITH INIT;
		-- Step 2: Restore the copy as a different database for reporting
		RESTORE DATABASE [DWClinicReportData-ReadOnly] 
		FROM DISK = N'C:\_BISolutions\DWClinicReportData.bak' 
		WITH FILE = 1
			, MOVE N'DWClinicReportData' TO N'C:\_BISolutions\DWClinicReportData-Reports.mdf'
			, MOVE N'DWClinicReportData_log' TO N'C:\_BISolutions\DWClinicReportData-Reports.ldf'
			, REPLACE;
		-- Step 3: Set the reporting database to read-only
		ALTER DATABASE [DWClinicReportData-ReadOnly] SET READ_ONLY WITH NO_WAIT;
		Set @RC = +1
	End Try
	Begin Catch
		Print Error_Message()
		Set @RC = -1
	End Catch
	Return @RC;
End
Go

/* Testing Code:
 Declare @Status int;
 Exec @Status = pMaintRefreshDWClinicReportData;
 Print @Status;
 Select * from SysDatabases Where Name like 'DWClinicReportData%';
 Select name, create_date, is_read_only from Sys.Databases Where Name like 'DWClinicReportData%';
*/