/***************************************************************************
ETL Final Project: File to OLTP Database
Dev: JCole
Date: 8/14/2018
Desc: This file transfers
ChangeLog: (Who, When, What) 
			JCole, 8/14/18, Created File, added staging tables, bulk insert 
										  statements, views, and Sproc
			JCole, 8/15/18, Executed Sproc, dropped old tables
*****************************************************************************/

Use Patients;
Go

If Exists(Select * from Sys.objects where Name = 'pCreateStagingTables')
	Drop Procedure pCreateStagingTables;
Go

If Exists(Select * from Sys.objects where Name = 'pInsertIntoStagingTables')
	Drop Procedure pInsertIntoStagingTables;
Go

If Exists(Select * from Sys.objects where Name = 'pETLSyncBellevueVisitors')
	Drop Procedure pETLSyncBellevueVisitors;
Go

If Exists(Select * from Sys.objects where Name = 'pETLSyncKirklandVisitors')
	Drop Procedure pETLSyncKirklandVisitors;
Go

If Exists(Select * from Sys.objects where Name = 'pETLSyncRedmondVisitors')
	Drop Procedure pETLSyncRedmondVisitors;
Go

-- Create staging tables for csv files
Create Procedure pCreateStagingTables
/* Author: JCole
** Desc: Inserts data into Staging Tables
** Change Log: When,Who,What
** 2018-08-14,JCole,Created Sproc.
*/
As
	Begin
		Declare @RC int = 0;
		Begin Try

			-- Bellevue
			If (Select Object_ID('StagingBellevue')) Is Not Null
				Truncate Table StagingBellevue;
			Else
				Create Table StagingBellevue (
					[Time] nvarchar(100),
					Patient nvarchar(100),
					Doctor nvarchar(100),
					[Procedure] nvarchar(100),
					Charge nvarchar(100)
				);

			-- Kirkland
			If (Select Object_ID('StagingKirkland')) Is Not Null
				Truncate Table StagingKirkland;
			Else
				Create Table StagingKirkland (
					[Time] nvarchar(100),
					Patient nvarchar(100),
					Clinic nvarchar(100),
					Doctor nvarchar(100),
					[Procedure] nvarchar(100),
					Charge nvarchar(100)
				);

			-- Redmond
			If (Select Object_ID('StagingRedmond')) Is Not Null
				Truncate Table StagingRedmond;
			Else
				Create Table StagingRedmond (
					[Time] nvarchar(100),
					Clinic nvarchar(100),
					Patient nvarchar(100),
					Doctor nvarchar(100),
					[Procedure] nvarchar(100),
					Charge nvarchar(100)
				);
			Print 'Successfully Created or Deleted ETL Staging Tables';
			Set @RC = +1
		End Try
		Begin Catch
			Print 'Error Creating or Deleting ETL Staging Tables';
			Print Error_Message()
			Set @RC = -1
		End Catch
			Return @RC;
	End
Go

/* Testing Code:
 Declare @Status int;
 Exec @Status = pETLCreateStagingTables;
 Print @Status;
*/
Go

Execute pCreateStagingTables;
Go

-- Inserts csv files into staging tables
Create Procedure pInsertIntoStagingTables
/* Author: JCole
** Desc: Inserts csv files into staging tables using bulk insert
** Change Log: When,Who,What
** 2018-08-14,JCole,Created Sproc.
*/
As
	Begin
		Declare @RC int = 0;
		Begin Try
			Bulk
			Insert StagingBellevue
				From 'E:\SQL\JCole_Final\JCole_Final\Info 498 Final\DataFiles\Bellevue\20100102Visits.csv'
					With (FirstRow = 2, FieldTerminator = ',', RowTerminator = '\n')

			Bulk
			Insert StagingKirkland
				From 'E:\SQL\JCole_Final\JCole_Final\Info 498 Final\DataFiles\Kirkland\20100102Visits.csv'
					With (FirstRow = 2, FieldTerminator = ',', RowTerminator = '\n')

			Bulk
			Insert StagingRedmond
				From 'E:\SQL\JCole_Final\JCole_Final\Info 498 Final\DataFiles\Redmond\20100102Visits.csv'
					With (FirstRow = 2, FieldTerminator = ',', RowTerminator = '\n')
			
			Print 'Successfully Filled ETL Staging Tables';
			Set @RC = +1
		End Try
		Begin Catch
			Print 'Error Filling ETL Staging Tables';
			Print Error_Message()
			Set @RC = -1
		End Catch
			Return @RC;
	End
Go

/* Testing Code:
 Declare @Status int;
 Exec @Status = pInsertIntoStagingTables;
 Print @Status;
*/
Go

Execute pInsertIntoStagingTables;
Go

-- Transform data with views
If (Select Object_ID('vBellevueReport')) is Not Null Drop View vBellevueReport;
Go

Create View vBellevueReport
As
Select [Date] = Cast(GetDate() as datetime) + Cast([Time] as datetime),
	   Clinic = Cast('100' as int),	   
	   Patient = Cast(Patient as int),
	   Doctor = Cast(Doctor as int),
	   [Procedure] = Cast([Procedure] as int),
	   Charge = Cast(Charge as money)
From StagingBellevue;
Go

If (Select Object_ID('vKirklandReport')) is Not Null Drop View vKirklandReport;
Go

Create View vKirklandReport
As
Select [Date] = Cast(GetDate() as datetime) + Cast([Time] as datetime),
	   Clinic = Cast(Clinic * 100 as int),	   
	   Patient = Cast(Patient as int),
	   Doctor = Cast(Doctor as int),
	   [Procedure] = Cast([Procedure] as int),
	   Charge = Cast(Charge as money)
From StagingKirkland;
Go

If (Select Object_ID('vRedmondReport')) is Not Null Drop View vRedmondReport;
Go

Create View vRedmondReport
As
Select [Date] = Cast(GetDate() as datetime) + Cast([Time] as datetime),
	   Clinic = Cast(Clinic * 100 as int),		   
	   Patient = Cast(Patient as int),
	   Doctor = Cast(Doctor as int),
	   [Procedure] = Cast([Procedure] as int),
	   Charge = Cast(Charge as money)
From StagingRedmond;
Go

-- Create Sprocs to move data from views to tables
Create Procedure pETLSyncBellevueVisitors
/* Author: JCole
** Desc: Inserts data into Visitors
** Change Log: When,Who,What
** 2018-08-14,JCole,Created Sproc.
*/
AS
	Begin
		Declare @RC int = 0;
		Begin Try
			Insert 
			Into Patients.dbo.Visits (
				[Date], Clinic, Patient, Doctor, [Procedure], Charge)
			Select 
				[Date], Clinic, Patient, Doctor, [Procedure], Charge
			From vBellevueReport;
			Print 'Successfully Synced Visitors With New Data';
			Set @RC = +1
		End Try
		Begin Catch
			Print 'Error Syncing Visitors With New Data';
			Print Error_Message()
			Set @RC = -1
		End Catch
			Return @RC;
	End
Go

/* Testing Code:
 Declare @Status int;
 Exec @Status = pETLSyncBellevueVisitors;
 Print @Status;
*/
Go

Create Procedure pETLSyncKirklandVisitors
/* Author: JCole
** Desc: Inserts data into Visitors
** Change Log: When,Who,What
** 2018-08-14,JCole,Created Sproc.
*/
AS
	Begin
		Declare @RC int = 0;
		Begin Try
			Insert 
			Into Patients.dbo.Visits (
				[Date],	Clinic, Patient, Doctor, [Procedure], Charge)
			Select 
				[Date], Clinic, Patient, Doctor, [Procedure], Charge
			From vKirklandReport;
			Print 'Successfully Synced Visitors With New Data';
			Set @RC = +1
		End Try
		Begin Catch
			Print 'Error Syncing Visitors With New Data';
			Print Error_Message()
			Set @RC = -1
		End Catch
			Return @RC;
	End
Go

/* Testing Code:
 Declare @Status int;
 Exec @Status = pETLSyncKirklandVisitors;
 Print @Status;
*/
Go

Create Procedure pETLSyncRedmondVisitors
/* Author: JCole
** Desc: Inserts data into Visitors
** Change Log: When,Who,What
** 2018-08-14,JCole,Created Sproc.
*/
AS
	Begin
		Declare @RC int = 0;
		Begin Try
			Insert 
			Into Patients.dbo.Visits (
				[Date], Clinic, Patient, Doctor, [Procedure], Charge)
			Select 
				[Date], Clinic, Patient, Doctor, [Procedure], Charge
			From vRedmondReport;
				Print 'Successfully Synced Visitors With New Data';
				Set @RC = +1
		End Try
		Begin Catch
			Print 'Error Syncing Visitors With New Data';
			Print Error_Message()
			Set @RC = -1
		End Catch
			Return @RC;
	End
Go

/* Testing Code:
 Declare @Status int;
 Exec @Status = pETLSyncRedmondVisitors;
 Print @Status;
*/
Go

-- Execute the Sproc for each csv file
Delete From Patients.dbo.Visits Where Cast([Date] as Date) = Cast(GetDate() as Date);
Go

Declare @Status int;
	Exec @Status = pETLSyncBellevueVisitors;
	Select [pETLSyncBellevueVisitors Status] = @Status;
	Print @Status;
Go

Declare @Status int;
	Exec @Status = pETLSyncKirklandVisitors;
	Select [pETLSyncKirklandVisitors Status] = @Status;
	Print @Status;
Go

Declare @Status int;
	Exec @Status = pETLSyncRedmondVisitors;
	Select [pETLSyncRedmondVisitors Status] = @Status;
	Print @Status;
Go

-- Check if new reports were added
Select * From Patients.dbo.Visits
