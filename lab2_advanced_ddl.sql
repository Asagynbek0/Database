CREATE DATABASE university_main
    OWNER = postgres
    TEMPLATE = template0
    ENCODING = 'UTF8';

CREATE DATABASE university_archive
    CONNECTION LIMIT = 50
    TEMPLATE = template0;

CREATE DATABASE university_test
    IS_TEMPLATE  = true
    CONNECTION LIMIT = 10
    TEMPLATE = template0;



CREATE TABLESPACE student_data
    LOCATION 'C:/data/students';

CREATE TABLESPACE course_data
    LOCATION 'C:/data/courses' ;

CREATE DATABASE university_distributed
    TABLESPACE = student_data
    ENCODING = 'UTF8';

\c university_main;

CREATE TABLE students(
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa NUMERIC(4,2),
    is_active BOOLEAN DEFAULT TRUE,
    graduation_year SMALLINT
)

CREATE TABLE professors(
    professor_id SERIAL PRIMARY KEY ,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    office_number VARCHAR(20),
    hire_date DATE ,
    salary NUMERIC(12,2),
    is_tenured BOOLEAN DEFAULT FALSE,
    years_experience INTEGER
)

CREATE TABLE courses(
    course_id SERIAL PRIMARY KEY ,
    course_code CHAR(8) UNIQUE NOT NULL ,
    course_title VARCHAR(100) NOT NULL ,
    description TEXT,
    credits SMALLINT,
    max_enrollment INTEGER,
    course_fee NUMERIC(10,2),
    is_online BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

CREATE TABLE class_schedule(
    schedule_id SERIAL PRIMARY KEY ,
    course_id INTEGER REFERENCES courses(course_id),
    professor_id INTEGER REFERENCES professors(professor_id),
    classroom VARCHAR(20)  ,
    class_date DATE,
    start_time TIME,
    end_time TIME ,
    duration INTERVAL
)

CREATE TABLE student_records(
    record_id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(student_id),
    course_id INTEGER REFERENCES courses(course_id),
    semester VARCHAR(20),
    year INTEGER ,
    grade CHAR(2),
    attendance_percentage NUMERIC(5,1),
    submission_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
)

--Students table ALTER 3.1
ALTER TABLE students
ADD COLUMN middle_name VARCHAR(30);

ALTER TABLE students
ADD COLUMN students_status VARCHAR(20) DEFAULT 'ACTIVE';

ALTER TABLE students
ALTER COLUMN phone TYPE VARCHAR(20);

ALTER TABLE students
ALTER COLUMN gpa SET DEFAULT 0.00;

--Professors table
ALTER TABLE professors
ADD COLUMN department_code CHAR(5);

ALTER TABLE professors
ADD COLUMN research_area TEXT;

ALTER TABLE professors
ALTER COLUMN years_experience TYPE SMALLINT;

ALTER TABLE professors
ALTER COLUMN is_tenured SET DEFAULT FALSE;

ALTER TABLE professors
ADD COLUMN last_promotion_date DATE;

--Courses table
ALTER TABLE courses
ADD COLUMN prerequisite_course_id INTEGER;

ALTER TABLE courses
ADD COLUMN difficulty_level SMALLINT;

ALTER TABLE courses
ALTER COLUMN course_code TYPE VARCHAR(10);

ALTER TABLE courses
ALTER COLUMN credits SET DEFAULT 3;

ALTER TABLE courses
ADD COLUMN lab_required BOOLEAN DEFAULT FALSE;

--TASK 3.2
--class-schedule
ALTER TABLE class_schedule
ADD COLUMN room_capacity INTEGER,
ADD COLUMN session_type VARCHAR(15),
ADD COLUMN equipment_needed TEXT,
DROP COLUMN duration,
ALTER COLUMN classroom TYPE VARCHAR(30);

--student_records
ALTER TABLE student_records
ADD COLUMN extra_credit_points DECIMAL(4,1) DEFAULT 0.0,
ADD COLUMN final_exam_date DATE,
ALTER COLUMN grade TYPE VARCHAR(5),
DROP COLUMN last_updated;

--TASK 4
--TASK 4.1
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    department_code CHAR(5) UNIQUE NOT NULL,
    building VARCHAR(50),
    phone VARCHAR(15),
    budget DECIMAL(12,2) CHECK (budget >= 0),
    established_year INTEGER CHECK (established_year > 1900 AND established_year <= EXTRACT(YEAR FROM CURRENT_DATE))
);

CREATE TABLE library_books (
    book_id SERIAL PRIMARY KEY,
    isbn CHAR(13) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    publisher VARCHAR(100),
    publication_date DATE CHECK (publication_date <= CURRENT_DATE),
    price DECIMAL(8,2) CHECK (price >= 0),
    is_available BOOLEAN DEFAULT TRUE,
    acquisition_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE student_book_loans (
    loan_id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(student_id),
    book_id INTEGER REFERENCES library_books(book_id),
    loan_date DATE DEFAULT CURRENT_DATE,
    due_date DATE CHECK (due_date >= loan_date),
    return_date DATE CHECK (return_date >= loan_date OR return_date IS NULL),
    fine_amount DECIMAL(8,2) DEFAULT 0.0 CHECK (fine_amount >= 0),
    loan_status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (loan_status IN ('ACTIVE', 'RETURNED', 'OVERDUE', 'LOST'))
);

ALTER TABLE professors ADD COLUMN department_id INTEGER;
ALTER TABLE students ADD COLUMN advisor_id INTEGER;
ALTER TABLE courses ADD COLUMN department_id INTEGER;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage NUMERIC(5,1),
    max_percentage NUMERIC(5,1),
    gpa_points NUMERIC(3,2)
);

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);

DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage NUMERIC(5,1),
    max_percentage NUMERIC(5,1),
    gpa_points NUMERIC(3,2),
    description TEXT
);

DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);

DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;

