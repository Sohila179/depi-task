create database Company_t1
use Company_t1
create table Employee(
SSN int primary key,
birth_date date ,
gender varchar(2),
fname varchar(20),
lname varchar(20),
 supervisor int,
 foreign key (supervisor) references  employee(ssn)
);
ALTER TABLE Employee ADD CONSTRAINT ch_gender CHECK (gender IN ('M', 'F'));

create  table departments(
Dnum int primary key,
Dname varchar(50) ,
Essn int,
 foreign key (Essn) references  employee(ssn)
);
alter table employee add  Dnum int 
foreign key (Dnum) references departments(Dnum); 

create table dept_location(
dnum int,
foreign key (Dnum) references departments(Dnum),
location varchar(50),
primary key (dnum,location)
);
create table project(
pnumber int primary key,
pname varchar(20),
location varchar(50),
city varchar(30),
dnum int,
foreign key (Dnum) references departments(Dnum),
);
create table dependents(
dssn int,
foreign key (dssn) references  employee(ssn),
dname varchar(50) ,
primary key (dname,dssn),
birth_date date ,
gender varchar(2)
); 
ALTER TABLE dependents ADD CONSTRAINT fk_dssn FOREIGN KEY (dssn) REFERENCES employee(ssn) ON DELETE CASCADE;
create table work_for(
wssn int,
foreign key (wssn) references  employee(ssn),
wpnum int ,
foreign key (wpnum) references  project(pnumber),
primary key (wssn,wpnum),
working_hours int
);

INSERT INTO Departments(Dnum, Dname)
VALUES 
(1, 'Human Resources'),
(2, 'Information Technology'),
(3, 'Finance');
INSERT INTO Employee (SSN, fname, lname, birth_date, gender, supervisor, Dnum)
VALUES 
(1001, 'Ali',    'Hassan',   '1990-05-01', 'M', NULL, 1),
(1002, 'Sara',   'Mohamed',  '1988-08-14', 'F', 1001, 1),
(1003, 'Omar',   'Saeed',    '1992-11-23', 'M', 1001, 2),
(1004, 'Laila',  'Adel',     '1985-03-10', 'F', 1002, 2),
(1005, 'Mona',   'Youssef',  '1993-07-19', 'F', 1003, 3);
 
 select *from departments
 UPDATE Departments SET Essn = 1001 WHERE Dnum = 1;
UPDATE Departments SET Essn = 1003 WHERE Dnum = 2;
UPDATE Departments SET Essn = 1005 WHERE Dnum = 3;
 select *from dependents

 INSERT INTO dependents (dSSN, dname, birth_date, gender)
VALUES 
(1001, 'hamza',   '2020-05-01', 'M')

delete dependents where dssn=1001
SELECT e.*
FROM Employee e
WHERE dnum=2;


INSERT INTO Project (pnumber, pname, location, city, dnum)
VALUES 
(1, 'PayrollSys', 'Building A', 'Cairo', 1),       
(2, 'WebsiteRevamp', 'Building B', 'Giza', 2),     
(3, 'BudgetTool', 'Building C', 'Alexandria', 3);  


INSERT INTO work_for (wssn, wpnum, working_hours)
VALUES 
(1001, 1, 20),
(1002, 1, 15),
(1003, 2, 30),
(1004, 2, 25),
(1005, 3, 10);


 select fname ,pname,working_hours from Employee ,project,work_for where ssn=wssn and pnumber=wpnum

