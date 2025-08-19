SELECT customer_id, company_name, contact_name
FROM customers
WHERE EXISTS (SELECT customer_id FROM orders
				  WHERE customer_id = customers.customer_id
				  AND order_date BETWEEN '1995-02-01' AND '1996-07-15');

SELECT product_id, product_name FROM products
WHERE NOT EXISTS (SELECT order_id FROM orders
			  	  JOIN order_details USING(order_id)
				  WHERE order_details.product_id = products.product_id
				  AND order_date BETWEEN '1995-01-01' AND '1995-01-15')
ORDER BY product_id DESC;

SELECT company_name -- DISTINCT company_name не нужен
FROM customers
WHERE customer_id = ANY(SELECT customer_id FROM orders
					   JOIN order_details USING(order_id)
					   WHERE quantity > 40);

SELECT product_id, product_name
FROM products
WHERE product_id > (SELECT AVG(units_in_stock) FROM products);

