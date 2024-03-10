CREATE TABLE Faculty (
    faculty_id INT primary key,
	faculty_name VARCHAR(100),
	faculty_address VARCHAR(300),
	faculty_date_of_construction DATE,
	faculty_specialization_name VARCHAR(100),
)

CREATE TABLE Department (
    department_id INT primary key,
	department_name VARCHAR(50),
	department_description VARCHAR(500),
	department_motto VARCHAR(100) unique,
)


CREATE TABLE Volunteer (
    volunteer_id INT primary key,
	volunteer_name VARCHAR(50),
	volunteer_Faculty_id INT foreign key references Faculties(faculty_id),
	volunteer_BirthDate DATE,
	volunteer_department_id INT foreign key references Departments(department_id),

)

CREATE TABLE DepartmentOfficial (
    department_id INT foreign key references Departments(department_id),
	volunteer_id INT foreign key references Volunteers(volunteer_id),
	departmentOfficial_id int,
	departmentOfficial_BC int,
	--the no of volunteers in BC
	constraint PK_DepartmentOfficial primary key(departmentOfficial_id, departmentOfficial_BC)
)

create table Sponsor(
	sponsor_id INT primary key,
	sponsor_name VARCHAR(100),
	sponsor_registration_number INT,
	sponsor_CUI VARCHAR(100),
	type_of_sponsorization VARCHAR(100)
)

create table Project(
	project_id INT primary key,
	project_name VARCHAR(100),
	project_start_of_implementation DATE,
	project_end_of_implementation DATE,
	project_description VARCHAR(100),
	project_responsible INT foreign key references Volunteers(volunteer_id),
	project_location VARCHAR(100),
)

create table SponsorProject(
	project_id INT foreign key references Projects(project_id),
	sponsor_id INT foreign key references Sponsors(sponsor_id),
	sponsorProject_id int,
	sponsorProject_BigPrize int,
	start_of_collaboration DATE,
	end_of_colaboration DATE,
	list_of_materials_provided VARCHAR(500),
	constraint PK_SponsorProject primary key(sponsorProject_id, sponsorProject_BigPrize)
)

go
create view ViewVolunteer
as
select *
from Volunteer
go

create view ViewSponsors
as
select *
from Sponsor
go

create view ViewVolunteerInDepartment1
as
select *
from Volunteer
inner join Department on Volunteer.volunteer_department_id = Department.department_id and Department.department_id = 1
go

create view ViewProjectsSponsored
as
select Project.project_name
from Project
inner join SponsorProject on Project.project_id = SponsorProject.project_id
go

create view ViewGroupByAge
as
select Volunteer.volunteer_BirthDate
from Volunteer
inner join Department on Volunteer.volunteer_department_id = Department.department_id
group by Volunteer.volunteer_BirthDate
go

create view ViewGroupByLocation
as
select Project.project_location
from Project
inner join SponsorProject on Project.project_id = SponsorProject.project_id
group by Project.project_location
go

delete from Tables
delete from Views
delete from Tests
delete from TestTables
delete from TestViews
delete from TestRuns
delete from TestRunTables
delete from TestRunViews

EXEC uspInsertDataIntoTables
    @TableName = 'Faculty'
go
EXEC uspInsertDataIntoTables
    @TableName = 'Department'
go
EXEC uspInsertDataIntoTables
    @TableName = 'Volunteer'
go
EXEC uspInsertDataIntoTables
    @TableName = 'DepartmentOfficial'
go
EXEC uspInsertDataIntoTables
    @TableName = 'Sponsor'
go
EXEC uspInsertDataIntoTables
    @TableName = 'Project'
go
EXEC uspInsertDataIntoTables
    @TableName = 'SponsorProject'
go

select *
from Tables
go

exec uspInsertDataIntoViews
	@ViewName = 'ViewVolunteer'
go
exec uspInsertDataIntoViews
	@ViewName = 'ViewSponsors'
go
exec uspInsertDataIntoViews
	@ViewName = 'ViewVolunteerInDepartment1'
go
exec uspInsertDataIntoViews
	@ViewName = 'ViewProjectsSponsored'
go
exec uspInsertDataIntoViews
	@ViewName = 'ViewGroupByAge'
go
exec uspInsertDataIntoViews
	@ViewName = 'ViewGroupByLocation'
go

select *
from Views
go

exec uspInsertDataIntoTests
	@TestName = 'Test1'
go

exec uspInsertDataIntoTests
	@TestName = 'Test2'
go

select *
from Tests
go

exec uspInsertDataTestTables
	@TestID = 2,
	@TableID = 2,
	@NoOfRows = 1000,
	@Position = 1
go
exec uspInsertDataTestTables
	@TestID = 2,
	@TableID = 3,
	@NoOfRows = 1000,
	@Position = 2
go
exec uspInsertDataTestTables
	@TestID = 2,
	@TableID = 4,
	@NoOfRows = 1000,
	@Position = 3
go
exec uspInsertDataTestTables
	@TestID = 2,
	@TableID = 8,
	@NoOfRows = 1000,
	@Position = 4
go
exec uspInsertDataTestTables
	@TestID = 3,
	@TableID = 5,
	@NoOfRows = 1000,
	@Position = 1
go
exec uspInsertDataTestTables
	@TestID = 3,
	@TableID = 6,
	@NoOfRows = 1000,
	@Position = 2
go
exec uspInsertDataTestTables
	@TestID = 3,
	@TableID = 7,
	@NoOfRows = 1000,
	@Position = 3
go

select *
from TestTables
go

exec uspInsertDataTestViews
	@TestID = 2,
	@ViewID = 2
go
exec uspInsertDataTestViews
	@TestID = 2,
	@ViewID = 3
go
exec uspInsertDataTestViews
	@TestID = 2,
	@ViewID = 4
go
exec uspInsertDataTestViews
	@TestID = 3,
	@ViewID = 5
go
exec uspInsertDataTestViews
	@TestID = 3,
	@ViewID = 6
go
exec uspInsertDataTestViews
	@TestID = 3,
	@ViewID = 7
go

select *
from TestViews
go

exec uspRunTest
	@TestID = 2,
	@TestDescription = 'Test for the Faculty, Volunteer, Department and DepartmentOfficial'
go

exec uspRunTest
	@TestID = 3,
	@TestDescription = 'Test for the Project, Sponsor and SponsorProject'
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