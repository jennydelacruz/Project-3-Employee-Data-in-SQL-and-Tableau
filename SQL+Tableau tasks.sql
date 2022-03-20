/* Task 1: Create a visualization that provides a breakdown between the male and female employees 
working in the company each year, starting from 1990.*/

SELECT YEAR(d.from_date) as calendar_year, e.gender, COUNT(e.gender) as Total_count
FROM t_employees e
JOIN t_dept_emp d
ON e.emp_no = d.emp_no
GROUP BY calendar_year, gender
HAVING calendar_year >=1990
ORDER BY calendar_year;

/*Task 2: Compare the number of male managers to the number of female managers from different departments
for each year, starting from 1990.*/

/*To complete this exercise, we needed to know which employee was the active manager for each year of the requested date range. In this case, this is from 1990 until 2000, which is the date range contained in the data base.
I have joined data from three tables, namely employees, dept_manager and departments */
 
SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    /*Because I have used a cross join to obtain all possible combinations of managers by year, I needed to add a CASE clause to identify within which year a manager was an acting, active manager. 
    The condition is that the year of the final date of the manager's contract, needs to be equal to or greater than the year in which they were hired, And the initial date of the same managerial contract, needs to be equal to or smaller than their hire year. 
     If this is true, Active is 1, otherwise is 0. */
    CASE
        WHEN YEAR(dm.to_date) >= e.calendar_year AND YEAR(dm.from_date) <= e.calendar_year THEN 1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
       JOIN 
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no, calendar_year;

/*Task 3: Compare the average salary of female versus male employees in the entire company until year 2002, and add a filter allowing 
you to see that per each department.*/

SELECT 
	e.gender, 
	ROUND(AVG(s.salary),0) as Avg_salary, 
    YEAR(s.from_date) as calendar_year, 
    d.dept_name
FROM 
	t_employees e
	JOIN 
    t_salaries s ON e.emp_no = s.emp_no
	JOIN 
    t_dept_emp de ON s.emp_no = de.emp_no
	JOIN 
    t_departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_no, calendar_year, e.gender
HAVING calendar_year <= '2002'
ORDER BY d.dept_no;

/*Task 4: Create an SQL stored procedure that will allow you to obtain the average male and female salary per department within a certain salary range. 
Let this range be defined by two values the user can insert when calling the procedure.

In this task, we were told to assume our manager would have told us that most employees do not get paid under $50,000
nor above $90,000. Therefore, we should exclude figures outside this range. */

DROP PROCEDURE IF EXISTS filter_salary;

DELIMITER $$
CREATE PROCEDURE filter_salary(IN p_min_salary FLOAT, IN p_max_salary FLOAT)
BEGIN
	SELECT 
    ROUND(AVG(s.salary),0) as salary,
    e.gender,
    d.dept_name
    FROM 
	t_employees e
	JOIN 
    t_salaries s ON e.emp_no = s.emp_no
	JOIN 
    t_dept_emp de ON s.emp_no = de.emp_no
	JOIN 
    t_departments d ON de.dept_no = d.dept_no
    WHERE
    s.salary BETWEEN p_min_salary AND p_max_salary
	GROUP BY de.dept_no, e.gender;
END$$
DELIMITER ;

CALL filter_salary(50000, 90000);

SELECT count(emp_no)
FROM t_employees;


