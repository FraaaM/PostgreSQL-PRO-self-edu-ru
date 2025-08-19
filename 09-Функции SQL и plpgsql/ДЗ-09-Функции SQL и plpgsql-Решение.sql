-- 1
CREATE OR REPLACE FUNCTION backup_customers() RETURNS void AS $$
DROP TABLE IF EXISTS backedup_customers;

--SELECT * INTO backedup_customers FROM customers;
CREATE TABLE backedup_customers AS 
SELECT * FROM customers
$$ LANGUAGE SQL; 
SELECT * FROM backedup_customers;

-- 2
CREATE OR REPLACE FUNCTION get_avg_freight() RETURNS float8 AS $$
SELECT AVG(freight) FROM orders
$$ LANGUAGE SQL;
SELECT get_avg_freight() AS avg_freight;

-- 3
CREATE OR REPLACE FUNCTION random_between(low int, high int) RETURNS int AS $$
BEGIN
	RETURN floor(random() * (high - low + 1) + low);
END
$$ LANGUAGE plpgsql;
SELECT random_between(1, 11) FROM generate_series(1, 5);

-- 4
CREATE OR REPLACE FUNCTION get_salary_bounds_by_city(IN emp_city text, OUT min_salary numeric, OUT max_salary numeric) AS $$
SELECT MIN(salary), MAX(salary) FROM employees
WHERE emp_city = employees.city
$$ LANGUAGE SQL;
SELECT * FROM get_salary_bounds_by_city('London');

-- 5	
CREATE OR REPLACE FUNCTION correct_salary(upper_boundary numeric DEFAULT 70, correction_rate numeric DEFAULT 0.12)
RETURNS void AS 
$$
UPDATE employees
SET salary = salary * (1 + correction_rate)
WHERE salary <= upper_boundary
$$ LANGUAGE SQL;

-- 6	 
CREATE OR REPLACE FUNCTION correct_salary(upper_boundary numeric DEFAULT 70, correction_rate numeric DEFAULT 0.12)
RETURNS SETOF employees AS 
$$
UPDATE employees
SET salary = salary * (1 + correction_rate)
WHERE salary <= upper_boundary
RETURNING *; 
--SELECT * FROM employees WHERE salary <= upper_boundary
$$ LANGUAGE SQL;

-- 7
CREATE OR REPLACE FUNCTION correct_salary(upper_boundary numeric DEFAULT 70, correction_rate numeric DEFAULT 0.12)
RETURNS TABLE(last_name text, first_name text, title text, salary numeric) AS 
$$
UPDATE employees
SET salary = salary * (1 + correction_rate)
WHERE salary <= upper_boundary
RETURNING last_name, first_name, title, salary; 
$$ LANGUAGE SQL;

-- 8
CREATE OR REPLACE FUNCTION get_orders_by_shipping(IN ship_method int) RETURNS SETOF orders AS $$
DECLARE
	maximum numeric;
	average numeric;
	middle numeric;
BEGIN
	SELECT MAX(freight) INTO maximum
	FROM orders
	WHERE ship_via = ship_method;
	maximum := maximum - (maximum * 0.3);
	
	SELECT AVG(freight) INTO average
	FROM orders
	WHERE ship_via = ship_method;
	middle := (maximum + average) / 2;

	RETURN QUERY SELECT *
	FROM orders
	WHERE freight < middle;
END
$$ LANGUAGE plpgsql
SELECT COUNT(*) FROM get_orders_by_shipping(1)

-- 9
CREATE OR REPLACE FUNCTION salary_increase(
	cur_salary numeric,
	max_salary numeric DEFAULT 80,
	min_salary numeric DEFAULT 30,
	increase_rate numeric DEFAULT 0.2
) RETURNS bool AS $$
BEGIN
	IF cur_salary >= min_salary THEN 
		RETURN False;
	ELSEIF cur_salary < min_salary THEN
		cur_salary := cur_salary * (1 + increase_rate);
		IF cur_salary > max_salary THEN
			RETURN False;
		ELSE RETURN True;
		END IF; 
	END IF;
END
$$ LANGUAGE plpgsql;
SELECT salary_increase(40,80,30);
SELECT salary_increase(79,81,80);
SELECT salary_increase(79,95,80);
