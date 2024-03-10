--Create a procedure that:
---insert data in the tables (Tables, Views, Tests, TestTables, TestViews, TestRuns)
---runs a test

--Procedure to add data into the table Tables
CREATE OR ALTER PROCEDURE uspInsertDataIntoTables
    @TableName NVARCHAR(100)
AS
BEGIN
    DECLARE @InsertData NVARCHAR(MAX);
    SET @InsertData = 'INSERT INTO Tables (Name) VALUES (' + 'N''' + @TableName + ''')';

    EXEC sp_executesql @InsertData;
END;
GO

-- Example:
EXEC uspInsertDataIntoTables
    @TableName = 'Faculties'
go

select *
from Tables
go

--Procedure to add data in the table Views
create or alter procedure uspInsertDataIntoViews
	@ViewName nvarchar(100)
as
	begin
		declare @InsertData nvarchar(max)
		set @InsertData = 'insert into Views (Name) values(' + 'N''' + @ViewName + ''')';

		exec sp_executesql @InsertData;
	end
go

--Example:
create view ViewForFaculties
as
select *
from Faculties
go

exec uspInsertDataIntoViews
	@ViewName = 'ViewForFaculties'
go

select *
from Views
go

--Procedure to add data in the table Tests
create or alter procedure uspInsertDataIntoTests
	@TestName nvarchar(100)
as
	begin
	declare @InsertData nvarchar(max)
	set @InsertData = 'insert into Tests (Name) values(' + 'N''' + @TestName + ''')';

	exec sp_executesql @InsertData;
	end
go

exec uspInsertDataIntoTests
	@TestName = 'TestForFacultiesTables'
go

select *
from Tests
go

--Procedure to add data in the table TestTables
create or alter procedure uspInsertDataTestTables
	@TestID int,
	@TableID int,
	@NoOfRows int,
	@Position int
as
	begin
		declare @InsertData nvarchar(max)
		set @InsertData = 'insert into TestTables (TestID, TableID, NoOfRows, Position) values(' + 
		CONVERT(nvarchar, @TestID) + ', ' + CONVERT(nvarchar, @TableID) + ', ' +
		CONVERT(nvarchar, @NoOfRows) + ', ' + CONVERT(nvarchar, @Position) + ')';

		exec sp_executesql @InsertData
	end
go

exec uspInsertDataTestTables
	@TestID = 1,
	@TableID = 1,
	@NoOfRows = 10000,
	@Position = 1
go

select *
from TestTables
go

--Procedure to add data in the table TestViews
create or alter procedure uspInsertDataTestViews
	@TestID int,
	@ViewID int
as
	begin
		declare @InsertData nvarchar(max)
		set @InsertData = 'insert into TestViews (TestID, ViewID) values(' + 
		CONVERT(nvarchar, @TestID) + ', ' + CONVERT(nvarchar, @ViewID) + ')';

		exec sp_executesql @InsertData
	end
go

exec uspInsertDataTestViews
	@TestID = 1,
	@ViewID = 1
go

select *
from TestViews
go

select *
from Tables
go

select *
from Views
go

select *
from TestTables
go

select *
from TestViews
go

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--HERE I CONSIDERED THE FIRST COLUMN TO BE THE PK & OF TYPE INT
create or alter procedure uspInsertRandomData
	@TableName nvarchar(100),
	@NoOfRows int
as
	begin
		declare @Counter int
		set @Counter = 1

		declare @ColumnName nvarchar(100)
		declare @ColumnType nvarchar(100)

		while @Counter <= @NoOfRows
			begin
				declare @IsFirstColumn bit = 1
				--here I considered that the first column is the PK
				--and it is of type int

				declare columnCursor cursor for
				select COLUMN_NAME, DATA_TYPE
				from INFORMATION_SCHEMA.COLUMNS
				where TABLE_NAME = @TableName

				open columnCursor

				fetch next from columnCursor into @ColumnName, @ColumnType

				while @@FETCH_STATUS = 0
					begin
						declare @InsertStatement nvarchar(max)
						
						if @IsFirstColumn = 1
							begin
								set @IsFirstColumn = 0
								set @InsertStatement = 'insert into ' + QUOTENAME(@TableName) + ' (' + @ColumnName + ') values (' + CONVERT(nvarchar, @Counter) + ')'

								exec sp_executesql @InsertStatement

								fetch next from columnCursor into @ColumnName, @ColumnType
							end
						else
							begin
							
								declare @ValuesToInsert nvarchar(max)
								declare @CurrentDate datetime

								set @CurrentDate = GETDATE()

								if @ColumnType like 'VARCHAR'
									begin
										set @ValuesToInsert = QUOTENAME(@ColumnName) + ' ' + CONVERT(nvarchar, @CurrentDate)
										set @InsertStatement = 'insert into ' + QUOTENAME(@TableName) + ' (' + @ColumnName + ') values (' + @ValuesToInsert + ')'
										--print(@InsertStatement)

										exec sp_executesql @InsertStatement
									end

								if @ColumnType like 'INT'
									begin
										set @InsertStatement = 'insert into ' + QUOTENAME(@TableName) + ' (' + @ColumnName + ') values (' + CONVERT(nvarchar, @Counter) + ')'
								
										exec sp_executesql @InsertStatement
									end

								if @ColumnType like 'DATETIME'
									begin
										set @InsertStatement = 'insert into ' + QUOTENAME(@TableName) + ' (' + @ColumnName + ') values (' + CONVERT(nvarchar, @CurrentDate) + ')'
								
										exec sp_executesql @InsertStatement
									end
				
								fetch next from columnCursor into @ColumnName, @ColumnType
							end
					end
					
				close columnCursor
				deallocate columnCursor

				set @Counter = @Counter + 1
			end
	end
go

delete from Faculties

exec uspInsertRandomData
	@TableName = 'Faculties',
	@NoOfRows = 10
go

select *
from Faculties
go


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--HERE I USE 2 CURSORS

create or alter procedure uspInsertRandomData
	@TableName nvarchar(100),
	@NoOfRows int
as
	begin
		declare @Counter int
		set @Counter = 1

		declare @ColumnName nvarchar(100)
		declare @ColumnType nvarchar(100)

		declare @ColumnNameConstraint nvarchar(100)
		declare @ConstraintName nvarchar(max)
		--this is for the names of the columns that are FK

		while @Counter <= @NoOfRows
			begin
				
				--here I create a cursor for getting the names of the columns of the table
				--and their type

				declare columnCursor cursor for
				select COLUMN_NAME, DATA_TYPE
				from INFORMATION_SCHEMA.COLUMNS
				where TABLE_NAME = @TableName

				open columnCursor

				fetch next from columnCursor into @ColumnName, @ColumnType

				while @@FETCH_STATUS = 0
					begin

						declare @InsertStatement nvarchar(max)

						--here I create another cursor for getting the names of the columns that are FK
						--we take the constraint name because it contains the name of the table that this one references

						declare columnConstraint cursor for
						select COLUMN_NAME, CONSTRAINT_NAME
						from INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
						where TABLE_NAME = @TableName and CONSTRAINT_NAME like 'FK%'

						open columnConstraint

						fetch next from columnConstraint into @ColumnNameConstraint, @ConstraintName

						if @ColumnName = @ColumnNameConstraint
							begin
							--here I should insert the data from the referenced table
								set @InsertStatement = 'insert into ' + QUOTENAME(@TableName) + ' (' + @ColumnName + ') values ('  + ')'

								exec sp_executesql @InsertStatement

								fetch next from columnCursor into @ColumnName, @ColumnType
								fetch next from columnConstraint into @ColumnNameConstraint, @ConstraintName

							end
						else
							begin
							
								declare @ValuesToInsert nvarchar(max)
								declare @CurrentDate datetime

								set @CurrentDate = GETDATE()

								if @ColumnType like 'VARCHAR'
									begin
										set @ValuesToInsert = QUOTENAME(@ColumnName) + ' ' + CONVERT(nvarchar, @CurrentDate)
										set @InsertStatement = 'insert into ' + QUOTENAME(@TableName) + ' (' + @ColumnName + ') values (' + @ValuesToInsert + ')'
										--print(@InsertStatement)

										exec sp_executesql @InsertStatement
									end

								if @ColumnType like 'INT'
									begin
										--RAND()*100
										--I could use it for every column that is not a PK
										set @InsertStatement = 'insert into ' + QUOTENAME(@TableName) + ' (' + @ColumnName + ') values (' + CONVERT(nvarchar, @Counter) + ')'
								
										exec sp_executesql @InsertStatement
									end

								if @ColumnType like 'DATETIME'
									begin
										set @InsertStatement = 'insert into ' + QUOTENAME(@TableName) + ' (' + @ColumnName + ') values (' + CONVERT(nvarchar, @CurrentDate) + ')'
								
										exec sp_executesql @InsertStatement
									end
				
								fetch next from columnCursor into @ColumnName, @ColumnType
							end

							close columnConstraint
							deallocate columnConstraint
					end
					
				close columnCursor
				deallocate columnCursor

				set @Counter = @Counter + 1
			end 
	end
go

delete from Faculties

exec uspInsertRandomData
	@TableName = 'Faculties',
	@NoOfRows = 10
go

select *
from Faculties
go

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--HERE I USE 1 CURSOR

create or alter procedure uspInsertRandomData
	@TableName nvarchar(100),
	@NoOfRows int
as
	begin
		declare @Counter int
		set @Counter = 1

		declare @ColumnName nvarchar(100)
		declare @ColumnType nvarchar(100)

		while @Counter <= @NoOfRows
			begin
				
				--here I create a cursor for getting the names of the columns of the table
				--and their type

				declare columnCursor cursor for
				select COLUMN_NAME, DATA_TYPE
				from INFORMATION_SCHEMA.COLUMNS
				where TABLE_NAME = @TableName

				open columnCursor

				fetch next from columnCursor into @ColumnName, @ColumnType

				while @@FETCH_STATUS = 0
					begin

						declare @InsertStatement nvarchar(max)

						--I check if the column has a PK constraint

						if @ColumnName in(
							SELECT COLUMN_NAME
							FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
							WHERE CONSTRAINT_NAME LIKE 'PK%' AND TABLE_NAME = @TableName
						)
							begin
							--if the column is a PK I insert the value of the @Counter
								set @InsertStatement = 'insert into ' + QUOTENAME(@TableName) + ' (' + @ColumnName + ') values (' + CONVERT(nvarchar, @Counter) + ')'
								
								exec sp_executesql @InsertStatement

								print(@ColumnName)
								print('fetch next')
								fetch next from columnCursor into @ColumnName, @ColumnType
							end
						else
							begin

							--I check if the column has a FK constraint

							if @ColumnName in(
								SELECT ccu.COLUMN_NAME
								FROM
									INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
								JOIN
									INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc ON ccu.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
								JOIN
									INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE rcu ON rcu.CONSTRAINT_NAME = rc.UNIQUE_CONSTRAINT_NAME
								WHERE
									ccu.CONSTRAINT_NAME LIKE 'FK%' AND ccu.TABLE_NAME = @TableName
							)
								begin
								--here I should insert the data from the referenced table
									declare @FKTable nvarchar(max)
									set @FKTable = (
										SELECT ccu.TABLE_NAME
										FROM
											INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
										JOIN
											INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc ON ccu.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
										JOIN
											INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE rcu ON rcu.CONSTRAINT_NAME = rc.UNIQUE_CONSTRAINT_NAME
										WHERE
											ccu.CONSTRAINT_NAME LIKE 'FK%' AND ccu.TABLE_NAME = @TableName
									)

									declare @Script nvarchar(max)
									declare @Result nvarchar(max) = ''

									set @Script = 'select top 1 ' + QUOTENAME(@ColumnName) + ' from ' + QUOTENAME(@FKTable)
									exec sp_executesql @Script, N'@Result navarchar(max) output', @Result output

									set @InsertStatement = 'insert into ' + QUOTENAME(@TableName) + ' (' + @ColumnName + ') values ('  + @Result + ')'

									exec sp_executesql @InsertStatement

									print(@ColumnName)
									print('fetch next')
									fetch next from columnCursor into @ColumnName, @ColumnType
								end
							else
								begin
							
									declare @CurrentDate datetime

									set @CurrentDate = GETDATE()

									if @ColumnType like '%VARCHAR%'
										begin
											
											print(@ColumnName)
											print(@ColumnType)

											set @InsertStatement = 'insert into ' + QUOTENAME(@TableName) + ' (' + @ColumnName + ') values (''' + @ColumnName + ' ' + CONVERT(nvarchar, @CurrentDate) + ''')'

											print(@InsertStatement)

											exec sp_executesql @InsertStatement
										end

									if @ColumnType like '%INT%'
										begin
											print(@ColumnName)
											print(@ColumnType)

											set @InsertStatement = 'insert into ' + QUOTENAME(@TableName) + ' (' + @ColumnName + ') values (' + CONVERT(nvarchar, CAST(RAND()*100 as int)) + ')'

											print(@InsertStatement)
								
											exec sp_executesql @InsertStatement
										end

									if @ColumnType like '%DATETIME%'
										begin
											print(@ColumnName)
											print(@ColumnType)

											set @InsertStatement = 'insert into ' + QUOTENAME(@TableName) + ' (' + @ColumnName + ') values (''' + CONVERT(nvarchar, @CurrentDate) + ''')'

											print(@InsertStatement)
								
											exec sp_executesql @InsertStatement
										end

									if @ColumnType like '%DATE%'
										begin
											print(@ColumnName)
											print(@ColumnType)

											set @InsertStatement = 'insert into ' + QUOTENAME(@TableName) + ' (' + @ColumnName + ') values (''' + CONVERT(nvarchar, convert(date, @CurrentDate)) + ''')'

											print(@InsertStatement)
								
											exec sp_executesql @InsertStatement
										end

										print(@ColumnName)
										print('fetch next')
				
									fetch next from columnCursor into @ColumnName, @ColumnType
								end
						end
							
					end
					
				close columnCursor
				deallocate columnCursor

				set @Counter = @Counter + 1
			end 
	end
go


delete from Faculties

exec uspInsertRandomData
	@TableName = 'Faculties',
	@NoOfRows = 10
go

select *
from Faculties
go


--Procedure that runs a test
create or alter procedure uspRunTest
	@TestID int,
	@TestDescription nvarchar(100)
as
	begin
		
		set NOCOUNT ON;
	
		declare @TestRunID int

		declare @StartAtForTables datetime2
		declare @StartAtForViews datetime2
		declare @EndAtForTables datetime2
		declare @EndAtForViews datetime2

		declare @StartAt datetime2
		declare @EndAt datetime2

		set @StartAt = SYSDATETIME()

		--the TestRuns, TestRunTables and TestRunViews should be updated in the end

		insert into TestRuns(Description, StartAt, EndAt) values(@TestDescription + ' Test ID: ' + CONVERT(nvarchar,@TestID), @StartAt, @StartAt)

		set @TestRunId = SCOPE_IDENTITY();
		--Retrieves the identifier (TestRunId) of the recently inserted record using SCOPE_IDENTITY() 
		--function and assigns it to the variable @TestRunId

		--here should be the part where we delete everything from the tables
		declare @TableName nvarchar(100)

		--we get the names of the tables that take part in the test
		--with the TestID being @TestID
		--Position represents the insertion order

		declare table_cursor cursor for
		select Tables.Name
		from Tables
		inner join TestTables on TestTables.TableID = Tables.TableID
		where TestTables.TestID = @TestID
		order by TestTables.Position desc

		open table_cursor
		fetch next from table_cursor into @TableName

		while @@FETCH_STATUS = 0
			begin
				exec('DELETE FROM ' + @TableName)
				fetch next from table_cursor into @TableName
			end

		close table_cursor
		deallocate table_cursor

		--and here we should run the procedure which inserts the random data in the tables

		declare @TableNameInsert nvarchar(100)
		declare @TableID int

		declare @Rows int

		declare tableCursorInsert cursor for
		select Tables.Name, Tables.TableID
		from Tables
		inner join TestTables on TestTables.TableID = Tables.TableID
		where TestTables.TestID = @TestID 
		order by TestTables.Position

		open tableCursorInsert
		fetch next from tableCursorInsert into @TableNameInsert, @TableID

		declare NoOfRowsCursor cursor for
		select TestTables.NoOfRows
		from TestTables
		order by TestTables.Position

		open NoOfRowsCursor
		fetch next from NoOfRowsCursor into @Rows

		while @@FETCH_STATUS = 0
			begin
				--here the procedure to insert the random data in the table should be called
				set @StartAtForTables = SYSDATETIME()

				exec uspInsertRandomData
					@TableName = @TableName,
					@NoOfRows = @Rows

				set @EndAtForTables = SYSDATETIME()

				insert into TestRunTables(TestRunID, TableID, StartAt, EndAt) values (@TestRunID,@TableID,@StartAtForTables,@EndAtForTables)

				fetch next from tableCursorInsert into @TableNameInsert, @TableID
				fetch next from NoOfRowsCursor into @Rows
			end

		close tableCursorInsert
		deallocate tableCursorInsert


		--evaluation of the views
		
		declare @ViewName nvarchar(100)
		declare @ViewID int

		declare view_cursor cursor for
		select distinct Views.Name, Views.ViewID
		from Views
		inner join TestViews on TestViews.ViewID = Views.ViewID
		where TestViews.TestID = @TestID

		open view_cursor
		fetch next from view_cursor into @ViewName, @ViewID

		while @@FETCH_STATUS = 0
			begin
				set @StartAtForViews = SYSDATETIME()
				exec('select * from ' + @ViewName)
				set @EndAtForViews = SYSDATETIME()

				insert into TestRunViews(TestRunID, ViewID, StartAt, EndAt) values(@TestRunID,@ViewID,@StartAtForViews,@EndAtForViews)

				fetch next from view_cursor into @ViewName, @ViewID
			end

		close view_cursor
		deallocate view_cursor

		set @EndAt = SYSDATETIME()

		--update the EndAt from the TestRuns
		update TestRuns
		set EndAt = @EndAt
		where TestRunID = @TestRunID
	end
go

exec uspRunTest
	@TestID = 1,
	@TestDescription = 'Test for the Faculties tables and views'
go

select *
from TestRuns

select *
from TestRunTables

select *
from TestRunViews

delete from TestRuns
delete from TestRunTables
delete from TestRunViews

go

