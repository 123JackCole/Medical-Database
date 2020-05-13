/***************************************************************************
ETL Final Project: OLTP To DW Database
Dev: JCole
Date: 8/14/2018
Desc: This is a Data Warehouse for the Patient and DoctorsSchedule Databases.
	  The Patients table is incrementally loaded, the others are flushed and
	  filled.
ChangeLog: (Who, When, What) 
			JCole, 8/14/18, Created File
			JCole, 8/15/18, Created Views
			JCole, 8/16/18, Created Sprocs
*****************************************************************************/

Use DWClinicReportData;
Go

-- Set Identity_Insert dbo.Customers On;

If Exists(Select * from Sys.objects where Name = 'pETLDropForeignKeyConstraints')
	Drop Procedure pETLDropForeignKeyConstraints;
Go

If Exists(Select * from Sys.objects where Name = 'pETLTruncateTables')
	Drop Procedure pETLTruncateTables;
Go

If Exists(Select * from Sys.objects where Name = 'pETLFillDimDates')
	Drop Procedure pETLFillDimDates;
Go

If Exists(Select * from Sys.views where Name = 'vETLDimClinics')
	Drop View vETLDimClinics;
Go

If Exists(Select * from Sys.objects where Name = 'pETLFillDimClinics')
	Drop Procedure pETLFillDimClinics;
Go

If Exists(Select * from Sys.views where Name = 'vETLDimDoctors')
	Drop View vETLDimDoctors;
Go

If Exists(Select * from Sys.objects where Name = 'pETLFillDimDoctors')
	Drop Procedure pETLFillDimDoctors;
Go

If Exists(Select * from Sys.views where Name = 'vETLDimShifts')
	Drop View vETLDimShifts;
Go

If Exists(Select * from Sys.objects where Name = 'pETLFillDimShifts')
	Drop Procedure pETLFillDimShifts;
Go

If Exists(Select * from Sys.views where Name = 'vETLFactDoctorShifts')
	Drop View vETLFactDoctorShifts;
Go

If Exists(Select * from Sys.objects where Name = 'pETLFillFactDoctorShifts')
	Drop Procedure pETLFillFactDoctorShifts;
Go

If Exists(Select * from Sys.objects where Name = 'vETLDimProcedures')
	Drop View vETLDimProcedures;
Go

If Exists(Select * from Sys.objects where Name = 'pETLFillDimProcedures')
	Drop Procedure pETLFillDimProcedures;
Go

If Exists(Select * from Sys.views where Name = 'vETLDimPatients')
	Drop View vETLDimPatients;
Go

If Exists(Select * from Sys.objects where Name = 'pETLFillDimPatients')
	Drop Procedure pETLFillDimPatients;
Go

If Exists(Select * from Sys.views where Name = 'vETLFactVisits')
	Drop View vETLFactVisits;
Go

If Exists(Select * from Sys.objects where Name = 'pETLFillFactVisits')
	Drop Procedure pETLFillFactVisits;
Go

If Exists(Select * from Sys.objects where Name = 'pETLAddForeignKeyConstraints')
	Drop Procedure pETLAddForeignKeyConstraints;
Go

-- Remove Foreign Key Constraints
Create Procedure pETLDropForeignKeyConstraints
/* Author: JCole
** Desc: Removed FKs before truncation of the tables
** Change Log: When,Who,What
** 8/16/18,JCole,Created Sproc.
*/
As
	Begin
		Declare @RC int = 0;
		Begin Try
			If (Select Object_ID('fkFactDoctorShiftsToDimClinics')) is Not Null
				Alter Table DWClinicReportData.dbo.FactDoctorShifts
				  Drop Constraint fkFactDoctorShiftsToDimClinics;
				  			
			If (Select Object_ID('fkFactDoctorShiftsToDimDates')) is Not Null
				Alter Table DWClinicReportData.dbo.FactDoctorShifts
					Drop Constraint fkFactDoctorShiftsToDimDates; 

			If (Select Object_ID('fkFactDoctorShiftsToDimShifts')) is Not Null
				Alter Table DWClinicReportData.dbo.FactDoctorShifts
				   Drop Constraint fkFactDoctorShiftsToDimShifts;

			If (Select Object_ID('fkFactDoctorShiftsToDimDoctors')) is Not Null
				Alter Table DWClinicReportData.dbo.FactDoctorShifts
				   Drop Constraint fkFactDoctorShiftsToDimDoctors;

			If (Select Object_ID('fkFactVisitsToDimDates')) is Not Null
				Alter Table DWClinicReportData.dbo.FactVisits
				   Drop Constraint fkFactVisitsToDimDates;

			If (Select Object_ID('fkFactVisitsToDimClinics')) is Not Null
				Alter Table DWClinicReportData.dbo.FactVisits
					Drop Constraint fkFactVisitsToDimClinics;

			If (Select Object_ID('fkFactVisitsToDimPatients')) is Not Null
				Alter Table DWClinicReportData.dbo.FactVisits
					Drop Constraint fkFactVisitsToDimPatients;

			If (Select Object_ID('fkFactVisitsToDimDoctors')) is Not Null
				Alter Table DWClinicReportData.dbo.FactVisits
					Drop Constraint fkFactVisitsToDimDoctors;

			If (Select Object_ID('fkFactVisitsToDimProcedures')) is Not Null
				Alter Table DWClinicReportData.dbo.FactVisits
					Drop Constraint fkFactVisitsToDimProcedures;

			Print 'Successfully Dropped Foreign Keys';
			Set @RC = +1
		End Try
		Begin Catch
			Print 'Error Dropping Foreign Keys';
			Print Error_Message()
			Set @RC = -1
		End Catch
		Return @RC;
	End
Go

/* Testing Code:
 Declare @Status int;
 Exec @Status = pETLDropForeignKeyConstraints;
 Print @Status;
*/
Go

Create Procedure pETLTruncateTables
/* Author: JCole
** Desc: Flushes all date from the tables
** Change Log: When,Who,What
** 8/16/18,JCole,Created Sproc.
*/
As
	Begin
		Declare @RC int = 0;
		Begin Try
			Truncate Table [DWClinicReportData].dbo.DimDates;
			Truncate Table [DWClinicReportData].dbo.DimClinics;
			Truncate Table [DWClinicReportData].dbo.DimDoctors;
			Truncate Table [DWClinicReportData].dbo.DimShifts; 
			Truncate Table [DWClinicReportData].dbo.FactDoctorShifts; 
			Truncate Table [DWClinicReportData].dbo.DimProcedures; 
			-- Truncate Table [DWClinicReportData].dbo.DimPatients		Incrementally loading
			Truncate Table [DWClinicReportData].dbo.FactVisits; 
			Print 'Successfully Flushed Data From Tables';
			Set @RC = +1
		End Try
		Begin Catch
			Print 'Error Deleting Data From Tables';
			Print Error_Message()
			Set @RC = -1
		End Catch
		Return @RC;
	End
Go

/* Testing Code:
 Declare @Status int;
 Exec @Status = pETLTruncateTables;
 Print @Status;
*/
Go

Create Procedure pETLFillDimDates
/* Author: JCole
** Desc: Inserts data into DimDates
** Change Log: When,Who,What
** 8/16/18,JCole,Created Sproc.
*/
As
	Begin
		Set Identity_Insert DWClinicReportData.dbo.DimDates On;
		Declare @RC int = 0;
		Begin Try
			Declare @StartDate datetime = '01/01/1990'
			Declare @EndDate datetime = '12/31/2030' 
			
			-- Loop through the dates until you reach the end date
			Declare @DateInProcess datetime  = @StartDate
			While @DateInProcess <= @EndDate
				Begin
				-- Add a row into the date dimension table for this date
				Insert Into DimDates 
					(DateKey, FullDate, FullDateName, MonthID, MonthName, YearID, YearName )
				Values ( 
					Cast(Convert(nvarchar(50), @DateInProcess, 112) as Int), -- DateKey

					@DateInProcess, -- FullDate
					DateName(weekday, @DateInProcess) + ', ' + Cast(@DateInProcess as nvarchar(20)), -- FullDateName 

					Year(@DateInProcess) + Month(@DateInProcess),  -- MonthID
					Cast(Year(@DateInProcess ) as nVarchar(50)) + ' - ' + DateName(Month, @DateInProcess), -- MonthName

					Year(@DateInProcess), -- YearKey
					Cast(Year(@DateInProcess ) as nVarchar(50)) -- YearName
				)  
				-- Add a day and loop again
				Set @DateInProcess = DateAdd(d, 1, @DateInProcess)
				End
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
 Exec @Status = pETLFillDimDates;
 Print @Status;
 Select * From DimDates;
*/
Go

If (Select Object_ID('vETLDimClinics')) is Not Null Drop View vETLDimClinics
Go
Create View vETLDimClinics
As
Select ClinicID = Cast(ClinicID * 100 as int),
	   ClinicName = IsNull(ClinicName, 'Missing Data'),
	   ClinicCity = IsNull(City, 'Missing Data'),
	   ClinicState = IsNull([State], 'Missing Data'),
	   ClinicZip = IsNull([Zip], 'Missing Data')
From DoctorsSchedules.dbo.Clinics;
Go

/* Testing Code:
 Select * From vETLDimClinics;
*/
Go

Create Procedure pETLFillDimClinics
/* Author: JCole
** Desc: Inserts data into DimClinics using the vETLDimClinics view
** Change Log: When,Who,What
** 8/16/18,JCole,Created Sproc.
*/
AS
	Begin
		Declare @RC int = 0;
		Begin Try
			If ((Select Count(*) From DWClinicReportData.dbo.DimClinics) = 0)
			Begin
				Insert into DWClinicReportData.dbo.DimClinics
					(ClinicID, ClinicName, ClinicCity, ClinicState, ClinicZip)
				Select
					ClinicID, ClinicName, ClinicCity, ClinicState,	ClinicZip
				From vETLDimClinics
			End
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
 Exec @Status = pETLFillDimClinics;
 Print @Status;
*/
Go

If (Select Object_ID('vETLDimDoctors')) is Not Null Drop View vETLDimDoctors
Go
Create View vETLDimDoctors
As
Select DoctorID = DoctorID,
	   DoctorFullName = Cast(IsNull((FirstName + ' ' + LastName), 'Missing Data') as nvarchar(200)),
	   DoctorEmailAddress = IsNull(EmailAddress, 'Missing Data'),
	   DoctorCity = IsNull(City, 'Missing Data'),
	   DoctorState = IsNull([State], 'Missing Data'),
	   DoctorZip = IsNull(Zip, 'Missing Data')
From DoctorsSchedules.dbo.Doctors;
Go

/* Testing Code:
 Select * From vETLDimDoctors;
*/
Go

Create Procedure pETLFillDimDoctors
/* Author: JCole
** Desc: Inserts data into DimDoctors using the vETLDimDoctors view
** Change Log: When,Who,What
** 8/16/18,JCole,Created Sproc.
*/
As
	Begin
		Declare @RC int = 0;
		Begin Try
			If ((Select Count(*) From DWClinicReportData.dbo.DimDoctors) = 0)
			Begin
				Insert into DWClinicReportData.dbo.DimDoctors
					(DoctorID, DoctorFullName, DoctorEmailAddress, DoctorCity, DoctorState, DoctorZip)
				Select
					DoctorID, DoctorFullName, DoctorEmailAddress, DoctorCity, DoctorState, DoctorZip
				From vETLDimDoctors
			End
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
 Exec @Status = pETLFillDimDoctors;
 Print @Status;
*/
Go

If (Select Object_ID('vETLDimShifts')) is Not Null Drop View vETLDimShifts
Go
Create View vETLDimShifts
As
Select ShiftID,
	   ShiftStart = Case ShiftStart
						When '01:00:00' Then '13:00:00'
						Else ShiftStart
					End,
	   ShiftEnd   = Case ShiftEnd
						When '05:00:00' Then '17:00:00'
						Else ShiftEnd
					End
From DoctorsSchedules.dbo.Shifts;
Go

/* Testing Code:
 Select * From vETLDimShifts;
*/
Go

Create Procedure pETLFillDimShifts
/* Author: JCole
** Desc: Inserts data into DimShifts using the vETLDimShifts view
** Change Log: When,Who,What
** 8/16/18,JCole,Created Sproc.
*/
AS
	Begin
		Declare @RC int = 0;
		Begin Try
			If ((Select Count(*) From DWClinicReportData.dbo.DimShifts) = 0)
			Begin
				Insert into DWClinicReportData.dbo.Dimshifts
					(ShiftID, ShiftStart, ShiftEnd)
				Select
					ShiftID, ShiftStart, ShiftEnd
				From vETLDimShifts
			End
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
 Exec @Status = pETLFillDimShifts;
 Print @Status;
*/
Go

If (Select Object_ID('vETLDimProcedures')) is Not Null Drop View vETLDimProcedures
Go
Create View vETLDimProcedures
As
Select ProcedureID = ID,
	   ProcedureName = IsNull([Name], 'Missing Data'),
	   ProcedureDesc = IsNull([Desc], 'Missing Data'),
	   ProcedureCharge = IsNull(Charge, '-1')
From Patients.dbo.[Procedures];
Go

/* Testing Code:
 Select * From vETLDimProcedures;
*/
Go

Create Procedure pETLFillDimProcedures
/* Author: JCole
** Desc: Inserts data into DimProcedures using the vETLDimProcedures view
** Change Log: When,Who,What
** 8/16/18,JCole,Created Sproc.
*/
As
	Begin
		Declare @RC int = 0;
		Begin Try
			If ((Select Count(*) From DWClinicReportData.dbo.DimProcedures) = 0)
			Begin
				Insert into DWClinicReportData.dbo.DimProcedures
					(ProcedureID, ProcedureName, ProcedureDesc, ProcedureCharge)
				Select
					ProcedureID, ProcedureName, ProcedureDesc, ProcedureCharge
				From vETLDimProcedures
			End
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
 Exec @Status = pETLDimProcedures;
 Print @Status;
*/
Go

If (Select Object_ID('vETLDimPatients')) is Not Null Drop View vETLDimPatients
Go
Create View vETLDimPatients
As
Select PatientID = ID,
	   PatientFullName = Cast(IsNull((FName + ' ' + LName), 'Missing Data') as varchar(100)),
	   PatientCity = Cast(IsNull(City, 'Missing Data') as varchar(100)),
	   PatientState = Cast(IsNull([State], 'Missing Data') as varchar(100)),
	   PatientZipCode = IsNull(ZipCode, '00000')
From Patients.dbo.Patients
Go

/* Testing Code:
 Select * From vETLDimPatients;
*/
Go

Create Procedure pETLFillDimPatients
/* Author: JCole
** Desc: Inserts data into DimCustomers
** Change Log: When,Who,What
** 2018-07-31,JCole,Created Sproc.
*/
As
	Begin
		Declare @RC int = 0;
		Begin Try

		Merge Into DWClinicReportData.dbo.DimPatients as TargetTable
		Using vETLDimPatients as SourceTable
			ON TargetTable.PatientID = SourceTable.PatientID
			When Not Matched 
				Then -- The ID in the Source is not found the the Target
					INSERT 
					VALUES (SourceTable.PatientID, 
							SourceTable.PatientFullName, 
							SourceTable.PatientCity,
							SourceTable.PatientState,
							SourceTable.PatientZipCode,
							Cast(Convert(nvarchar(50), GetDate(), 112) as date), -- StartDate
							Null, -- EndDate
							1) -- IsCurrent
			When Matched -- When the IDs match for the row currently being looked at
			And ( SourceTable.PatientFullName <> TargetTable.PatientFullName -- but the Names 
				Or SourceTable.PatientCity <> TargetTable.PatientCity        -- City
				Or SourceTable.PatientState <> TargetTable.PatientState      -- State
				Or SourceTable.PatientZipCode <> TargetTable.PatientZipCode) -- or ZipCode do not match...
				Then 
					UPDATE
					SET TargetTable.PatientFullName = SourceTable.PatientFullName,
					    TargetTable.PatientCity = SourceTable.PatientCity,
						TargetTable.PatientState = SourceTable.PatientState,
						TargetTable.PatientZipCode = SourceTable.PatientZipCode,
						TargetTable.StartDate = Cast(Convert(nvarchar(50), GetDate(), 112) as date),
						TargetTable.EndDate = Null,
						TargetTable.IsCurrent = 1
			When Not Matched By Source 
				Then -- The PatientID is in the Target table, but not the source table
					-- DELETE
					UPDATE
					SET TargetTable.EndDate = Cast(Convert(nvarchar(50), GetDate(), 112) as date),
						TargetTable.IsCurrent = 0;
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
 Exec @Status = pETLFillDimPatients;
 Print @Status;
*/
Go

If (Select Object_ID('vETLFactDoctorShifts')) is Not Null Drop View vETLFactDoctorShifts
Go
Create View vETLFactDoctorShifts
As
Select DoctorsShiftID = ds.DoctorsShiftID,
	   ShiftDateKey = Convert(nvarchar(100), ShiftDate, 112),
	   ClinicKey = c.ClinicID,
	   ShiftKey = s.ShiftID,
	   DoctorKey = d.DoctorID,									
	   HoursWorked = Case When (s.ShiftStart < s.ShiftEnd)
			Then 
				Cast(DateDiff([Hour], s.ShiftStart, s.ShiftEnd) as int)
			Else
				Abs(Cast(DateDiff([Hour], s.ShiftEnd, s.ShiftStart) as int) - 24)
			End,
	   ShiftStartTime = Cast(s.ShiftStart as Time(0)),
	   ShiftEndTime = Cast(s.ShiftEnd as Time(0))	
From DoctorsSchedules.dbo.DoctorShifts as ds
Join DoctorsSchedules.dbo.Shifts as s
On ds.ShiftID = s.ShiftID
Join DoctorsSchedules.dbo.Clinics as c
On ds.ClinicID = c.ClinicID
Join DoctorsSchedules.dbo.Doctors as d
On ds.DoctorID = d.DoctorID;
Go

/* Testing Code:
 Select * From vETLFactDoctorShifts;
*/
Go

Create Procedure pETLFillFactDoctorShifts
/* Author: JCole
** Desc: Inserts data into FactDoctorShifts using the vETLFactDoctorShifts view
** Change Log: When,Who,What
** 8/16/18,JCole,Created Sproc.
*/
As
	Begin
		Declare @RC int = 0;
		Begin Try
			If ((Select Count(*) From DWClinicReportData.dbo.FactDoctorShifts) = 0)
			Begin
				Insert into DWClinicReportData.dbo.FactDoctorShifts
					(DoctorsShiftID, ShiftDateKey, ClinicKey, ShiftKey, DoctorKey, HoursWorked)
				Select
					DoctorsShiftID, ShiftDateKey, ClinicKey, ShiftKey, DoctorKey, HoursWorked
				From vETLFactDoctorShifts
			End
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
 Exec @Status = pETLFactDoctorShifts;
 Print @Status;
*/
Go

If (Select Object_ID('vETLFactVisits')) is Not Null Drop View vETLFactVisits
Go
Create View vETLFactVisits
As
Select VisitKey = ID,
	   DateKey = d.DateKey,
	   ClinicKey = c.ClinicID,
	   PatientKey = p.PatientID,
	   DoctorKey = do.DoctorID,
	   ProcedureKey = pr.ProcedureID,
	   ProcedureVistCharge = Sum(Charge)
From Patients.dbo.Visits as v
Join DimDates as d
On Cast(v.[Date] as Date) = Cast(d.FullDate as Date)
Join DimClinics as c
On v.Clinic = c.ClinicID
Join DimPatients as p
On v.Patient = p.PatientID
Join DimDoctors as do
On v.Doctor = do.DoctorID
Join DimProcedures as pr
On v.[Procedure] = pr.ProcedureID
Group By
	ID,
	d.DateKey,
	c.ClinicID,
	p.PatientID,
	do.DoctorID,
	pr.ProcedureID
Go

/* Testing Code:
 Select * From vETLFactVisits;
*/
Go

Create Procedure pETLFillFactVisits
/* Author: JCole
** Desc: Inserts data into FactVisits using the vETLFactVisits view
** Change Log: When,Who,What
** 8/16/18,JCole,Created Sproc.
*/
As
	Begin
		Declare @RC int = 0;
		Begin Try
			If ((Select Count(*) From DWClinicReportData.dbo.FactVisits) = 0)
			Begin
				Insert into DWClinicReportData.dbo.FactVisits
					(VisitKey, DateKey, ClinicKey, PatientKey, DoctorKey, ProcedureKey, ProcedureVistCharge)
				Select
					VisitKey, DateKey, ClinicKey, PatientKey, DoctorKey, ProcedureKey, ProcedureVistCharge
				From vETLFactVisits
			End
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
 Exec @Status = pETLFactVisits;
 Print @Status;
*/
Go

-- Add back Foreign Key Constraints
Create Procedure pETLAddForeignKeyConstraints
/* Author: JCole
** Desc: Removed FKs before truncation of the tables
** Change Log: When,Who,What
** 8/16/18,JCole,Created Sproc.
*/
As
	Begin
		Declare @RC int = 0;
		Begin Try
			If (Select Object_ID('fkFactDoctorShiftsToDimShifts')) is Not Null
				Alter Table DWClinicReportData.dbo.FactDoctorShifts
					Add Constraint [fkFactDoctorShiftsToDimDates]
					Foreign Key (ShiftDateKey) References DimDates (DateKey); 

			If (Select Object_ID('fkFactDoctorShiftsToDimShifts')) is Not Null
				Alter Table [DWClinicReportData].dbo.FactDoctorShifts
					Add Constraint fkFactDoctorShiftsToDimClinics
					Foreign Key (ClinicKey) References DimClinics (ClinicKey);

			If (Select Object_ID('fkFactDoctorShiftsToDimShifts')) is Not Null
				Alter Table DWClinicReportData.dbo.FactDoctorShifts
					Add Constraint fkFactDoctorShiftsToDimShifts
					Foreign Key (ShiftKey) References DimShifts (ShiftKey);

			If (Select Object_ID('fkFactDoctorShiftsToDimShifts')) is Not Null
				Alter Table DWClinicReportData.dbo.FactDoctorShifts
					Add Constraint fkFactDoctorShiftsToDimDoctors
					Foreign Key (DoctorKey) References DimDoctors (DoctorKey);

			If (Select Object_ID('fkFactVisitsToDimShifts')) is Not Null
				Alter Table DWClinicReportData.dbo.FactVisits
					Add Constraint fkFactVisitsToDimDates
					Foreign Key (DateKey) References DimDates (DateKey);

			If (Select Object_ID('fkFactVisitsToDimShifts')) is Not Null
				Alter Table DWClinicReportData.dbo.FactVisits
					Add Constraint fkFactVisitsToDimClinics
					Foreign Key (ClinicKey) References DimClinics (ClinicKey);

			If (Select Object_ID('fkFactVisitsToDimShifts')) is Not Null
				Alter Table [DWClinicReportData].dbo.FactVisits
					Add Constraint fkFactVisitsToDimPatients
					Foreign Key (PatientKey) References DimPatients (PatientKey);

			If (Select Object_ID('fkFactVisitsToDimShifts')) is Not Null
				Alter Table DWClinicReportData.dbo.FactVisits
					Add Constraint fkFactVisitsToDimDoctors
					Foreign Key (DoctorKey) References DimDoctors (DoctorKey);

			If (Select Object_ID('fkFactVisitsToDimShifts')) is Not Null
				Alter Table DWClinicReportData.dbo.FactVisits
					Add Constraint fkFactVisitsToDimProcedures
					Foreign Key (ProcedureKey) References DimProcedures (ProcedureKey);
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
 Exec @Status = pETLDropForeignKeyConstraints;
 Print @Status;
*/
Go

-- Execute the Sprocs
Declare @Status int;
Exec @Status = pETLDropForeignKeyConstraints;
Select [Object] = 'pETLDropForeignKeyConstraints', [Status] = @Status;

Exec @Status = pETLTruncateTables;
Select [Object] = 'pETLTruncateTables', [Status] = @Status;

Exec @Status = pETLFillDimDates;
Select [Object] = 'pETLFillDimDates', [Status] = @Status;

Exec @Status = pETLFillDimClinics;
Select [Object] = 'pETLFillDimClinics', [Status] = @Status;

Exec @Status = pETLFillDimDoctors;
Select [Object] = 'pETLFillDimDoctors', [Status] = @Status;

Exec @Status = pETLFillDimShifts;
Select [Object] = 'pETLFillDimShifts', [Status] = @Status;

Exec @Status = pETLFillFactDoctorShifts;
Select [Object] = 'pETLFillFactDoctorShifts', [Status] = @Status;

Exec @Status = pETLFillDimProcedures;
Select [Object] = 'pETLFillDimProcedures', [Status] = @Status;

Exec @Status = pETLFillDimPatients;
Select [Object] = 'pETLFillDimPatients', [Status] = @Status;

Exec @Status = pETLFillFactVisits;
Select [Object] = 'pETLFillFactVisits', [Status] = @Status;

Exec @Status = pETLAddForeignKeyConstraints;
Select [Object] = 'pETLAddForeignKeyConstraints', [Status] = @Status;
Go

