-- 1
SELECT contact_name, city, country 
FROM customers
ORDER BY contact_name, (
	CASE WHEN city IS NULL THEN country
	ELSE city
	END );		 

-- 2
SELECT product_name, unit_price,
	CASE WHEN unit_price >= 100 THEN 'too expensive'
		 WHEN unit_price >= 50 AND unit_price < 100 THEN 'average'
		 ELSE 'low price'
	END AS amount
FROM products

-- 3
SELECT contact_name, COALESCE(order_id::text, 'no orders') AS order_id
FROM customers
LEFT JOIN orders USING(customer_id)
WHERE order_id IS NULL

-- 4
SELECT CONCAT(last_name, ' ', first_name) AS full_name, 
	COALESCE(NULLIF(title, 'Sales Representative'), 'Sales Stuff') AS title
FROM employees 
