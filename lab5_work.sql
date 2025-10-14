--LAB 5 WORK
--SAGYNBEK ALINUR | Stud Id:24B031984


CREATE DATABASE Constraints
    OWNER = postgres
    TEMPLATE = template0
    ENCODING = 'UTF8';

--TASK 1.1 : CHECK
CREATE TABLE employees(
    employee_id INT,
    first_name TEXT,
    last_name TEXT,
    age INT CHECK ( age >= 18 AND age <= 65 ),
    salary NUMERIC CHECK ( salary > 0 )
);

INSERT INTO employees VALUES (1 , 'Abdu' ,'Nurik',21 ,30000),
                             (2, 'Alikhan' ,'Sagat' , 18 , 50000);

--TASK 1.2
CREATE TABLE products_catalog(
    product_id INT,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount
                             CHECK ( regular_price > 0 AND discount_price > 0 AND discount_price < regular_price )
);

INSERT INTO products_catalog VALUES (1,'Display' ,15000,10000),
                                    (2,'Processor',20000,18000);

--TASK 1.3
CREATE TABLE bookings(
    booking_id INT,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INT CHECK ( num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

INSERT INTO bookings VALUES (1 , '2025-09-15','2025-10-03',6),
                            (2,'2025-08-13','2025-08-21',5);

--TASK 2.1 : NOT NULL
CREATE TABLE customers(
    customer_id INT NOT NULL ,
    email TEXT NOT NULL ,
    phone TEXT ,
    registration_date DATE NOT NULL
);

INSERT INTO customers VALUES (1,'alinur@gmail.com','+7 776 555 3993','2022-04-21'),
                             (2,'alikhan01@gmail.com','+7 775 999 12 32' , '2021-12-31');

--TASK 2.2
CREATE TABLE inventory(
    item_id INT NOT NULL ,
    item_name TEXT NOT NULL ,
    quantity INT NOT NULL CHECK ( quantity > 0 ),
    unit_price NUMERIC NOT NULL CHECK ( unit_price > 0 ),
    last_updated TIMESTAMP NOT NULL
);

--TASK 2.3
INSERT INTO inventory VALUES (1,'Keyboard',12,19.99,NOW()),
                             (2,'lamp',8,3.99,NOW());

--TASK 3.1 :UNIQUE
CREATE TABLE users(
    user_id INT,
    username TEXT UNIQUE ,
    email TEXT UNIQUE ,
    created_at TIMESTAMP
);
INSERT INTO users VALUES(1,'Maksat','maks102@gmail.com',NOW()),
                        (2,'Alinur','sagynbek00@gmail.com',NOW());

--TASK 3.2
CREATE TABLE course_enrollments(
    enrollment_id INT,
    student_id INT,
    course_code TEXT,
    semester TEXT,
    UNIQUE (student_id,course_code,semester)
);

--TASK 3.3
DROP TABLE IF EXISTS users;

CREATE TABLE users(
    user_id INT,
    user_name TEXT,
    email TEXT,
    created_at TIMESTAMP,
    CONSTRAINT unique_username UNIQUE (username),
    CONSTRAINT unique_email UNIQUE (email)
);

INSERT INTO users VALUES (1,'maloy_001','kemenger009@gmail.com',NOW()),
                        (2,'Sary','Sapargali@gmail.com',NOW());

--TASK 4.1 : PRIMARY KEY
CREATE TABLE departments(
    dept_id INT PRIMARY KEY ,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES (1,'SITE','KBTU'),
                               (2,'SGPE','KBTU');

--TASK 4.2
CREATE TABLE student_courses(
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id,course_id)
);

INSERT INTO student_courses VALUES (101,201,'2024-09-01','A+'),
                                   (101,202,'2024-09-01','B')
--TASK 4.3
--1)About the difference between UNIQUE and PRIMARY KEY.Primary Key can`t allow NULL values,while UNIQUE allows them - one NULL,unless the column is defined as NOT NULL.
--A table can have only one PRIMARY KEY,but multiple UNIQUE constraints.
--2)We use Single-column PRIMARY KEY when you have a natural or surrogate identifier for example:user ID,order number.
--Composite PRIMARY KEY when the uniqueness of a row is determined by a combination of several columns example:student + course in an enrollments table
--3)Because,PRIMARY KEY uniquely identifies a row.If there were multiple,the system wouldn`t know which one is the main id.
--This is a standard of the relational data model.

--TASK 5.1
CREATE TABLE employees_dept(
   emp_id INT PRIMARY KEY,
   emp_name TEXT NOT NULL,
   dept_id INT REFERENCES departments(dept_id),
   hire_date DATE
);

--TESTING
INSERT INTO employees_dept VALUES (1,'Alinur',1,'2021-01-15'),
                                  (2,'Abdu',2,'2022-03-22');

--TASK 5.2
CREATE TABLE authors(
      author_id INT PRIMARY KEY ,
      author_name TEXT NOT NULL,
      country TEXT
);

CREATE TABLE publishers(
    publisher_id INT PRIMARY KEY ,
    publisher_name TEXT NOT NULL ,
    city TEXT
);

CREATE TABLE books(
    book_id INT PRIMARY KEY ,
    title TEXT NOT NULL ,
    author_id INT REFERENCES authors(author_id),
    publication_year INT ,
    isbn TEXT UNIQUE
);

INSERT INTO authors VALUES (1,'J.Rowling','UK'),
                           (2,'George.R.R.Martin','USA');

INSERT INTO publishers VALUES (1,'Bloomsbury','London'),
                              (2,'Bantam Books','New York');

INSERT INTO books VALUES (1,'Harry Potter and the Philosopher',1,1,1997,'978-123241'),
                         (2,'Game of Thrones',2,2,1996,'2913912391');

--TASK 5.3
CREATE TABLE categories (
   category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk,
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO categories VALUES (2, 'Books');

INSERT INTO products_fk VALUES (1, 'Smartphone', 1);
INSERT INTO products_fk VALUES (2, 'Novel', 2);

INSERT INTO orders VALUES (101, '2023-09-25');
INSERT INTO orders VALUES (102, '2023-09-26');

INSERT INTO order_items VALUES (1, 101, 1, 1);
INSERT INTO order_items VALUES (2, 101, 2, 2);
INSERT INTO order_items VALUES (3, 102, 1, 1);

--TASK 6.1
CREATE TABLE ecommerce_customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE, -- UNIQUE constraint
    phone TEXT,
    registration_date DATE NOT NULL
);
CREATE TABLE ecommerce_products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0), -- CHECK constraint
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0) -- CHECK constraint
);
CREATE TABLE ecommerce_orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES ecom_customers ON DELETE SET NULL, -- FOREIGN KEY
    order_date DATE NOT NULL,
    total_amount NUMERIC CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')) -- CHECK constraint
);

CREATE TABLE ecommerce_order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES ecom_orders ON DELETE CASCADE, -- FOREIGN KEY with CASCADE
    product_id INTEGER REFERENCES ecom_products ON DELETE RESTRICT, -- FOREIGN KEY with RESTRICT
    quantity INTEGER NOT NULL CHECK (quantity > 0), -- CHECK constraint
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0) -- CHECK constraint
);

INSERT INTO ecommerce_customers VALUES
(1, 'Alice Johnson', 'alice.j@example.com', '123-456-7890', '2023-01-15'),
(2, 'Bob Brown', 'bob.brown@example.com', '123-456-7891', '2023-02-01'),
(3, 'Carol Davis', 'carol.d@example.com', NULL, '2023-02-20'),
(4, 'David Wilson', 'david.w@example.com', '123-456-7893', '2023-03-10'),
(5, 'Eva Miller', 'eva.m@example.com', '123-456-7894', '2023-04-05');

INSERT INTO ecommerce_products VALUES
(1, 'Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 100),
(2, 'Mechanical Keyboard', 'RGB mechanical keyboard', 89.99, 50),
(3, 'Monitor 24"', 'Full HD 24-inch monitor', 199.99, 30),
(4, 'Laptop Stand', 'Aluminum laptop stand', 49.99, 75),
(5, 'Webcam', '1080p HD webcam', 69.99, 40);

INSERT INTO ecommerce_orders VALUES
(101, 1, '2023-09-25', 119.98, 'delivered'),
(102, 2, '2023-09-26', 89.99, 'processing'),
(103, 3, '2023-09-26', 269.98, 'pending'),
(104, 1, '2023-09-27', 49.99, 'shipped'),
(105, 4, '2023-09-28', 199.99, 'delivered');

INSERT INTO ecommerce_order_details VALUES
(1, 101, 1, 2, 29.99),
(2, 101, 4, 1, 49.99),
(3, 102, 2, 1, 89.99),
(4, 103, 3, 1, 199.99),
(5, 103, 5, 1, 69.99),
(6, 104, 4, 1, 49.99),
(7, 105, 3, 1, 199.99);

-- 1. Testing UNIQUE email constraint
-- INSERT INTO ecom_customers VALUES (6, 'Duplicate', 'alice.j@example.com', NULL, '2023-10-01'); -- Should FAIL

-- 2. Testing CHECK price constraint
-- INSERT INTO ecom_products VALUES (6, 'Bad Product', 'Test', -10, 5); -- Should FAIL

-- 3. Testing CHECK order status constraint
-- INSERT INTO ecom_orders VALUES (106, 1, '2023-10-01', 100, 'invalid_status'); -- Should FAIL

-- 4. Testing FOREIGN KEY constraint in ecom_orders
-- INSERT INTO ecom_orders VALUES (107, 999, '2023-10-01', 100, 'pending'); -- Should FAIL (non-existent customer_id)

-- 5. Testing ON DELETE CASCADE in ecom_order_details
-- SELECT count(*) FROM ecom_order_details WHERE order_id = 101; -- Should return 2
-- DELETE FROM ecom_orders WHERE order_id = 101;
-- SELECT count(*) FROM ecom_order_details WHERE order_id = 101; -- Should return 0 (cascaded delete)

-- 6. Testing ON DELETE RESTRICT in ecom_order_details
-- DELETE FROM ecom_products WHERE product_id = 1; -- Should FAIL (existing references in order_details)