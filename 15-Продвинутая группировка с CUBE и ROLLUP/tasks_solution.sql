--- Задание "Продвинутые группировки". Решение ---

-- 1
SELECT
    EXTRACT(YEAR FROM o.order_date) AS order_year,
	s.company_name AS shipper,
	SUM(o.freight) AS total_freight 
FROM orders o
JOIN shippers s ON o.ship_via = s.shipper_id
GROUP BY 
	GROUPING SETS (
		(EXTRACT(YEAR FROM o.order_date), s.company_name),
		(EXTRACT(YEAR FROM o.order_date)),
		(s.company_name),
		()
	)
ORDER BY order_year, shipper;

-- 2
SELECT 
	EXTRACT(YEAR FROM hire_date) AS hire_year,
	EXTRACT(QUARTER FROM hire_date) AS hire_quarter,
	COUNT(*) AS employee_count 
FROM employees
GROUP BY 
	ROLLUP(hire_year, hire_quarter)
ORDER BY hire_year, hire_quarter;

-- 3
SELECT category_name, ship_country, 
	SUM(order_details.unit_price * quantity)::numeric(10,2) AS total_amount
FROM orders 
JOIN order_details USING(order_id)
JOIN products USING(product_id)
JOIN categories USING(category_id)
GROUP BY 
	CUBE(category_name, ship_country)
ORDER BY category_name, ship_country






	
	
	


	