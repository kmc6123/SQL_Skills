#Using built-in functions: Retrieving all employees who have worked at the company for over 30 years
USE employees;

SELECT 
    *
FROM
    employees
WHERE
    hire_date <= (SELECT DATE_SUB(CURRENT_DATE, INTERVAL 30 YEAR))
ORDER BY hire_date;   

#Inner join: Retrieving all employees who work in the "Finance" or "Marketing" departments and the names of the departments they work in 
SELECT 
    e.emp_no, e.first_name, e.last_name, d.dept_name
FROM
    employees e
        JOIN
    dept_emp de ON e.emp_no = de.emp_no
        JOIN
    departments d ON de.dept_no = d.dept_no
WHERE
    d.dept_name IN ('Marketing' , 'Finance'); 

#Aggregate functions and subqueries: What is the average salary for employees in the "Customer Service" department and are NOT managers 
SELECT 
    ROUND(AVG(s.salary),2) AS AvgSalary
FROM
    salaries s
        JOIN
    employees e ON s.emp_no = e.emp_no
WHERE
    e.emp_no NOT IN 
    (
	SELECT 
            e.emp_no
        FROM
            employees e
                JOIN
            dept_manager m ON e.emp_no = m.emp_no
    )    
    AND (e.emp_no , s.from_date) IN 
    (
        SELECT 
	    de.emp_no, MAX(de.from_date)
        FROM
            dept_emp de
                JOIN
            departments d ON de.dept_no = d.dept_no
        WHERE
            d.dept_name IN ('Customer Service')
        GROUP BY de.emp_no
     );  

#View: Department managers table with their full name and the name of the department they manage
DROP VIEW IF EXISTS v_dept_manager_details;

CREATE VIEW v_dept_manager_details AS
    SELECT 
        e.emp_no, e.first_name, e.last_name, d.dept_name
    FROM
        employees e
            JOIN
        dept_manager dm ON e.emp_no = dm.emp_no
            JOIN
        departments d ON dm.dept_no = d.dept_no;
        
SELECT * FROM v_dept_manager_details;
    
#Stored procedure: User provides a department name and procedure returns all employees working in that department
DROP PROCEDURE IF EXISTS emps_by_dept; 

DELIMITER $$
CREATE PROCEDURE emps_by_dept(IN p_dept_name VARCHAR(40))
BEGIN
SELECT 
    e.emp_no, e.first_name, e.last_name, d.dept_name
FROM
    employees e
        JOIN
    dept_emp de ON e.emp_no = de.emp_no
        JOIN
    departments d ON de.dept_no = d.dept_no
WHERE
    d.dept_name = p_dept_name; 
END $$
DELIMITER ;

CALL emps_by_dept("sales");

#Scalar UDF: Converting annual salary to hourly wage 
DROP FUNCTION IF EXISTS to_hourly_wage;

CREATE FUNCTION to_hourly_wage(p_salary INT) 
RETURNS DECIMAL(6,2) DETERMINISTIC
RETURN ((p_salary / 52) / 40);

SELECT to_hourly_wage(100000) as HourlyWage;

#Trigger (for data validation): Before record insertion, capitalize first letter of "first_name" and "last_name", as well as the "gender" character
DROP TRIGGER IF EXISTS tr_insert_emps;
 
CREATE TRIGGER tr_insert_emps 
BEFORE INSERT ON employees
FOR EACH ROW 
SET
    NEW.first_name = CONCAT(UPPER(SUBSTRING(NEW.first_name,1,1)),LOWER(SUBSTRING(NEW.first_name,2))),     
    NEW.last_name = CONCAT(UPPER(SUBSTRING(NEW.last_name,1,1)),LOWER(SUBSTRING(NEW.last_name,2))), 
    NEW.gender = UPPER(NEW.gender);     

DELETE FROM employees
WHERE emp_no = 500000;

INSERT INTO employees (emp_no, birth_date, first_name, last_name, gender, hire_date)
VALUES (500000, "1990-10-03", "alice", "smith", "f", CURRENT_DATE);
 
SELECT * FROM employees
WHERE emp_no = 500000;
