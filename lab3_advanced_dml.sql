CREATE DATABASE advanced_Lab;

CREATE TABLE employees(
    emp_id SERIAL PRIMARY KEY ,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE'
);

CREATE TABLE departments(
    dept_id SERIAL PRIMARY KEY ,
    dept_name VARCHAR(50),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects(
    project_id SERIAL PRIMARY KEY ,
    project_name VARCHAR(50),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

INSERT INTO employees(emp_id,first_name,last_name,department)
VALUES(100,'Era','Rakhan','SITE'),
      (101,'Abu','Debara','ISE'),
      (102,'Alihan','Sarkyt','SEPI');

INSERT INTO employees(first_name, last_name, department, salary,status)
VALUES('Magripa','Bakhyt','Marketing',DEFAULT,DEFAULT);

INSERT INTO departments(dept_name,budget,manager_id)
VALUES('SITE',10000,201),
      ('ISE',500000,202),
      ('SEPI',80000,203);

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES
    ('Arman', 'Parasat', 'IT', 50000 * 1.1, CURRENT_DATE );

CREATE TEMPORARY TABLE temp_employees AS
SELECT * FROM employees WHERE 1=0;

INSERT INTO temp_employees
SELECT* FROM employees WHERE department = 'IT';

UPDATE employees
SET salary = salary * 1.10;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01' ;

UPDATE employees
SET department =
    CASE
        WHEN salary > 80000 THEN 'Management'
        WHEN salary BETWEEN  50000 AND 80000 THEN 'Senior'
        ELSE 'Junior'
    END;

ALTER TABLE employees
ALTER COLUMN department SET DEFAULT 'General';

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments d
SET budget = (
    SELECT AVG(salary) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
);

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

DELETE FROM employees
WHERE status = 'Terminated';


DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;


DELETE FROM departments
WHERE dept_id NOT IN (
    SELECT DISTINCT dept_id
    FROM employees
    WHERE department IS NOT NULL
);


CREATE TEMPORARY TABLE deleted_projects AS
SELECT * FROM projects
WHERE end_date < '2023-01-01';


DELETE FROM projects
WHERE end_date < '2023-01-01';

SELECT * FROM deleted_projects;


INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Make', 'Bakha', NULL, NULL);


UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;


DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('Robert', 'Johnson', 'IT', 60000);

SELECT emp_id, CONCAT(first_name, ' ', last_name) AS full_name
FROM employees
WHERE emp_id = LAST_INSERT_ID();

CREATE TEMPORARY TABLE salary_updates AS
SELECT emp_id, salary AS old_salary, (salary + 5000) AS new_salary
FROM employees
WHERE department = 'IT';

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT';

SELECT * FROM salary_updates;

CREATE TEMPORARY TABLE deleted_employees AS
SELECT * FROM employees
WHERE hire_date < '2020-01-01';

DELETE FROM employees
WHERE hire_date < '2020-01-01';

SELECT * FROM deleted_employees;

INSERT INTO employees(first_name, last_name, department, salary)
SELECT 'Arman', 'Parasat', 'IT', 50000 * 1.1
FROM employees
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE first_name = 'John' AND last_name = 'Doe')

UPDATE employees e
SET salary =
    CASE
        WHEN (SELECT budget FROM departments d WHERE d.dept_name = e.department) > 100000
        THEN salary * 1.10
        ELSE salary * 1.05
    END;


INSERT INTO employees (first_name, last_name, department, salary) VALUES
('Aruzhan', 'Temir', 'Engineering', 65000),
('Bakhyt', 'Nurlan', 'Marketing', 48000),
('Camila', 'Zhan', 'Finance', 72000),
('Dias', 'Oral', 'HR', 42000),
('Emina', 'Kairat', 'Engineering', 68000);

UPDATE employees
SET salary = salary * 1.10
WHERE first_name IN ('Aruzhan', 'Bakhyt', 'Camila', 'Dias', 'Emina');

CREATE TABLE employee_archive AS
SELECT * FROM employees WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

UPDATE projects p
SET end_date = DATE_ADD(end_date, INTERVAL 30 DAY)
WHERE p.budget > 50000
AND (SELECT COUNT(*) FROM employees e WHERE e.department = p.dept_name) > 3;