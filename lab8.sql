--ex-2.1
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname,indexdef
FROM pg_indexes
WHERE tablename='employees'

--Question:: How many indexes exist on the employees table? (Hint: PRIMARY KEY creates an automatic index)
--Answer:Automatically created index for the primary key emp_id,manually created index emp_salary_idx on the salary column,totally:2 indexes.

--ex-2.2
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT * FROM employees WHERE dept_id = 101;

--Question: Why is it beneficial to index foreign key columns?
--Answer:Indexing foreign key columns provides significant benefits for database performance and integrity.

--ex-2.3
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename,indexname;

--Question: List all the indexes you see. Which ones were created automatically?
--Answer:employees_pkey (automatic), emp_salary_idx (manual), emp_dept_idx (manual). Automatic indexes are created for PRIMARY KEY and UNIQUE constraints.

--PART 3
--ex-3.1
CREATE INDEX emp_dept_salary_idx ON employees(dept_id,salary);

SELECT emp_name,salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;

--Question: Would this index be useful for a query that only filters by salary (without dept_id)? Why or why not?
--Answer:No. The multicolumn index (dept_id, salary) works best when filtering starts with the leftmost column (dept_id).

--ex-3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

-- Query 1: Filters by dept_id first
SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;

-- Query 2: Filters by salary first
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;
--Question: Does the order of columns in a multicolumn index matter? Explain.
--Answer:From my point of view a multicolumn index doesn`t matter.Because as you can see on the table no difference between two queries.

--PART4
--ex-4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);

 UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
 UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
 UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
 UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
 UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

 CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

-- This should fail with a unique violation error
 INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
 VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

-- Question: What error message did you receive
--Answer:There is error like repeating keys break constrtaint unique for 'emp_email_unique_idx'

--4.2

ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';

--Question: Did PostgreSQL automatically create an index? What type of index?
--Answer:Yes, PostgreSQL automatically created a unique B-tree index when adding the UNIQUE constraint.

--PART 5
--5.1
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;
--Question: How does this index help with ORDER BY queries?
--Answer:This index helps ORDER BY queries by storing data pre-sorted in descending order

--5.2
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

SELECT project_name, budget
FROM projects
ORDER BY budget NULLS FIRST;

--PART 6
--6.1
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

-- This query can use the expression index
 SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';
--Question: Without this index, how would PostgreSQL search for names case-insensitively?

--6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;

 UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
 UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
 UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
 UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
 UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

--PART 7
--7.1
ALTER INDEX emp_salary_idx RENAME TO emp_salary_index;

SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

--7.2
DROP INDEX emp_dept_salary_idx ;
--Answer: You might want to drop an index to:
-- Reduce overhead on INSERT/UPDATE/DELETE operations
-- Free up disk space
-- Remove redundant or unused indexes

--7.3
REINDEX INDEX employees_salary_index;

--PART 8
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

-- Index for the WHERE clause
 CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;

 --8.2
  CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 80000;

SELECT project_name, budget
FROM projects
WHERE budget > 80000;

--answer:The advantage of a partial index is that it's smaller, faster, and has less maintenance overhead since it only indexes a subset of rows.

--8.3
EXPLAIN SELECT * FROM employees WHERE salary > 52000;
--answer:The output shows either:
-- Index Scan if using an index (efficient for selective queries)
-- Seq Scan if doing a sequential scan (better when retrieving large portions of the table)

--PART 9
 CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);

 SELECT * FROM departments WHERE dept_name = 'IT';
--answer:Use HASH indexes only for simple equality comparisons where you'll only use the = operator. B-tree is more versatile as it supports ranges, sorting, and prefix matching.


--9.2
-- B-tree index
 CREATE INDEX proj_name_btree_idx ON projects(project_name);

-- Hash index
 CREATE INDEX proj_name_hash_idx ON projects USING HASH (project_name);

-- Equality search (both can be used)
 SELECT * FROM projects WHERE project_name = 'Website Redesign';
-- Range search (only B-tree can be used)
 SELECT * FROM projects WHERE project_name > 'Database';

--PART 10
 SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
 FROM pg_indexes
 WHERE schemaname = 'public'
 ORDER BY tablename, indexname;

--answer:The largest index is typically the one on columns with the largest data types or the most rows. In our case, indexes on salary (DECIMAL) or expression indexes might be larger.

--10.2
-- Drop the duplicate expression indexes
 DROP INDEX IF EXISTS proj_name_hash_idx;

 --10.3
 CREATE VIEW index_documentation AS
 SELECT
    tablename,
    indexname,
    indexdef,
 'Improves salary-based queries' as purpose
 FROM pg_indexes
 WHERE schemaname = 'public'
AND indexname LIKE '%salary%';
 SELECT * FROM index_documentation;

--additional challenges
-- 1. Index for employees hired in specific month
CREATE INDEX emp_hire_month_idx ON employees(EXTRACT(MONTH FROM hire_date));

-- 2. Composite unique index
CREATE UNIQUE INDEX emp_dept_email_unique_idx ON employees(dept_id, email);

-- 3. Compare performance with EXPLAIN ANALYZE
EXPLAIN ANALYZE SELECT * FROM employees WHERE salary > 50000;

-- 4. Covering index
CREATE INDEX emp_covering_idx ON employees(dept_id, salary) INCLUDE (emp_name, email);