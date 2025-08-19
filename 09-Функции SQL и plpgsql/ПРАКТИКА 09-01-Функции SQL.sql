	select *
into tmp_customers
from customers;

update tmp_customers
set region = 'unknown'
where region is null

-- scalar_func
CREATE OR REPLACE FUNCTION sum_units_in_sctock() RETURNS int AS $$
	SELECT SUM(units_in_stock) FROM products
$$ LANGUAGE SQL;
SELECT sum_units_in_sctock() AS total_number_of_goods;
-- RETURNS void -- if there is nothing to return
CREATE OR REPLACE FUNCTION get_avg_price() RETURNS float8 AS $$
	SELECT AVG(unit_price) FROM products
$$ LANGUAGE SQL;
SELECT get_avg_price() AS avg_price;

-- with arguments
CREATE OR REPLACE FUNCTION get_employee_name_by_id(empl_id int) RETURNS varchar AS $$
	SELECT CONCAT(last_name, ' ', first_name) FROM employees
	WHERE employees.employee_id = empl_id 
$$ LANGUAGE SQL;
SELECT get_employee_name_by_id(1);

-- with IN, OUT, DEFAULT
CREATE OR REPLACE FUNCTION get_price_boundaries(IN is_disct int DEFAULT 1, OUT max_price real, OUT min_price real) AS $$
	SELECT MAX(unit_price), MIN(unit_price) FROM products
	WHERE is_disct = discontinued
$$ LANGUAGE SQL;
SELECT * FROM get_price_boundaries()

-- SETOF 1
CREATE OR REPLACE FUNCTION get_avg_prices()
		RETURNS SETOF float8 AS $$
	SELECT AVG(unit_price) FROM products
	GROUP BY product_id 
$$ LANGUAGE SQL;
SELECT * FROM get_avg_prices() AS avg_prices

-- SETOF record
CREATE OR REPLACE FUNCTION get_avg_prices_by_category(OUT avg_price real, OUT sum_price real)
		RETURNS SETOF record AS $$
	SELECT AVG(unit_price), SUM(unit_price) FROM products
	GROUP BY category_id 
$$ LANGUAGE SQL;
SELECT * FROM get_avg_prices_by_category()

-- SETOF table_name
CREATE OR REPLACE FUNCTION get_customers_by_country(IN customer_country varchar)
		RETURNS SETOF customers AS $$
	-- won`t work SELECT customer_id, company_name
	SELECT * FROM customers -- must use *
	WHERE customer_country = country
$$ LANGUAGE SQL;
SELECT customer_id, company_name FROM get_customers_by_country('USA')

-- SETOF TABLE(...)
CREATE OR REPLACE FUNCTION get_customers_by_country_2(IN customer_country varchar)
		RETURNS TABLE(id_code varchar, company_name varchar) AS $$
	SELECT customer_id, company_name FROM customers
	WHERE customer_country = country
$$ LANGUAGE SQL;
SELECT * FROM get_customers_by_country_2('USA')

-- RETURN in plpgsql 
CREATE OR REPLACE FUNCTION get_total_number_of_goods() RETURNS bigint AS $$
BEGIN
	RETURN sum(units_in_stock)
	FROM products;
END;
$$ LANGUAGE plpgsql;	

SELECT get_total_number_of_goods();

CREATE OR REPLACE FUNCTION get_price_boundaries_2(OUT min_price real, OUT max_price real) AS $$
BEGIN
	-- max_price := MAX(unit_price) FROM products;
	-- min_price := MIN(unit_price) FROM products;
	--	--	--	--	--	OR --	--	--	--	--
	SELECT MAX(unit_price), MIN(unit_price)
	INTO max_price, min_price
	FROM products;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM get_price_boundaries_2();