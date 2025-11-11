--PART 1
CREATE  DATABASE SETUP
    OWNER = postgres
    ENCODING = 'UTF8';

DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
--1.1
-- Create table: employees
 CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
 );-- Create table: departments
 CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
 );-- Create table: projects
 CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
 );

--1.2
-- Insert data into employees
 INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
 (1, 'John Smith', 101, 50000),
 (2, 'Jane Doe', 102, 60000),
 (3, 'Mike Johnson', 101, 55000),
 (4, 'Sarah Williams', 103, 65000),
 (5, 'Tom Brown', NULL, 45000);-- Insert data into departments
 INSERT INTO departments (dept_id, dept_name, location) VALUES
 (101, 'IT', 'Building A'),
 (102, 'HR', 'Building B'),
 (103, 'Finance', 'Building C'),
 (104, 'Marketing', 'Building D');-- Insert data into projects
 INSERT INTO projects (project_id, project_name, dept_id,
budget) VALUES
 (1, 'Website Redesign', 101, 100000),
 (2, 'Employee Training', 102, 50000),
 (3, 'Budget Analysis', 103, 75000),
 (4, 'Cloud Migration', 101, 150000),
 (5, 'AI Research', NULL, 200000);

--PART 2
SELECT e.emp_name, d.dept_name
 FROM employees e CROSS JOIN departments d;

--2.1
--a)Comma notation
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;
--b)INNER JOIN with TRUE condition
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON TRUE;

--2.2
SELECT e.emp_name, p.project_name
FROM employees e CROSS JOIN projects p;

--PART 3
--INNER JOIN with ON
--How many rows are returned?Why is Tom Brown not included?
--Answer:4 rows returned.Tom Brown not included because his dept_id is NULL (no department match)
SELECT e.emp_name,d.dept_name,d.location
FROM employees e
INNER JOIN departments d ON e.dept_id=d.dept_id;

--3.2 INNER JOIN with USING
--What's the difference in output columns compared to the ON version?
--Answer:USING automatically handles join column - no need for table aliases on dept_id
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);

--3.3 NATURAL INNER JOIN
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;

--3.4 Multi-table INNER JOIN
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;

--PART 4
-- Basic LEFT JOIN
--How is Tom Brown represented in the results?
--Answer:Tom Brown appears with NULL values for department columns.
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

--4.2 LEFT JOIN with USING
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d USING (dept_id);

--4.3 Find Unmatched Records
SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

--4.4 LEFT JOIN with Aggregation
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

--PART 5
--Basic RIGHT JOIN
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

--5.2 Convert to LEFT JOIN
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;

--5.3 Find Departments Without Employees
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

--Part6
-- Basic FULL JOIN
--Which records have NULL values on the left side?Which have NULL on the right side?
--Answer:NULL on left: Marketing department (no employees). NULL on right: Tom Brown (no department)
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;

--6.2 FULL JOIN with Projects
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;

--6.3 Find Orphaned Records
SELECT
    CASE
    WHEN e.emp_id IS NULL THEN 'Department without employees'
    WHEN d.dept_id IS NULL THEN 'Employee without department'
    ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

--PART 7
-- Filtering in ON Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

--7.2 Filtering in WHERE Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

--7.3 ON vs WHERE with INNER JOIN
--Question: Is there any difference in results? Why or why not?
--Answer: No difference. INNER JOIN excludes non-matches anyway, so both produce same result
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

--PART 8
-- Multiple Joins with Different Types
SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

--8.2 Self Join
--Add manager_id column
ALTER TABLE employees ADD COLUMN manager_id INT;

--Update with sample data
UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

--Self join query
SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

--8.3 Join with Subquery
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;


--Additional challenges
--Challenge 1: Simulate FULL OUTER JOIN using UNION
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

--Challenge 2: Employees in Departments with Multiple Projects
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN (
    SELECT dept_id, COUNT(*) as project_count
    FROM projects
    GROUP BY dept_id
    HAVING COUNT(*) > 1
) dept_projects ON d.dept_id = dept_projects.dept_id;

--Challenge 3: Hierarchical Organizational Structure
SELECT
    e1.emp_name AS employee,
    e2.emp_name AS manager,
    e3.emp_name AS managers_manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.emp_id
LEFT JOIN employees e3 ON e2.manager_id = e3.emp_id;

--Challenge 4: Employee Pairs in Same Department
SELECT
    e1.emp_name AS employee1,
    e2.emp_name AS employee2,
    d.dept_name
FROM employees e1
INNER JOIN employees e2 ON e1.dept_id = e2.dept_id AND e1.emp_id < e2.emp_id
INNER JOIN departments d ON e1.dept_id = d.dept_id;

--Questions
--1.What is the difference between INNER JOIN and LEFT JOIN?
--Answer: INNER JOIN returns only matching rows from both tables.
--LEFT JOIN returns all rows from left table + matching rows from right table (NULLs for no matches).

--2.When would you use CROSS JOIN in a practical scenario?
--Answer: Use for creating combinations - scheduling matrices, test data generation, availability charts.

--3.Explain why the position of a filter condition (ON vs WHERE) matters for outer joins but not for inner joins.
--Answer: For OUTER JOINs: ON filters before join (preserves left rows), WHERE filters after join.
--For INNER JOINs: Both produce same results since non-matches are excluded anyway.

--4.What is the result of: SELECT COUNT(*) FROM table1 CROSS JOIN table2 if table1 has 5 rows and table2 has 10 rows?
--Answer: 50 rows (5 × 10). CROSS JOIN creates Cartesian product.

--5.How does NATURAL JOIN determine which columns to join on?
--Answer: Automatically joins on all columns with identical names in both tables.

--6.What are the potential risks of using NATURAL JOIN?
--Answer: Schema changes break queries, unintended column matches, implicit behavior hard to debug.

--7.Convert this LEFT JOIN to a RIGHT JOIN: SELECT * FROM A LEFT JOIN B ON A.id = B.id
--Answer: SELECT * FROM B RIGHT JOIN A ON B.id = A.id

--8.When should you use FULL OUTER JOIN instead of other join types?
--Answer: When you need all records from both tables + identify unmatched records on both sides.