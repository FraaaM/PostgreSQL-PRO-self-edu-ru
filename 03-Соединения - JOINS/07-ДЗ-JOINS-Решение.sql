-- 1
SELECT customers.company_name, CONCAT(last_name, ' ', first_name) AS employee_name
FROM orders
JOIN customers ON orders.customer_id = customers.customer_id -- USING(customer_id)
JOIN employees USING(employee_id)
JOIN shippers ON orders.ship_via = shippers.shipper_id
WHERE employees.city = 'London' AND customers.city = 'London'
	  AND shippers.company_name = 'Speedy Express';

-- 2
SELECT product_name, units_in_stock, phone AS supplier_phone, contact_name
FROM products
JOIN suppliers USING(supplier_id)
JOIN categories USING(category_id)
WHERE discontinued <> 1 AND category_name IN ('Beverages', 'Seafood')
	  AND units_in_stock < 20
ORDER BY units_in_stock DESC;

-- 3
SELECT contact_name, order_id
FROM customers
LEFT JOIN orders USING(customer_id) 
WHERE order_id IS NULL;

-- 4
SELECT contact_name, order_id
FROM orders
RIGHT JOIN customers USING(customer_id) 
WHERE order_id IS NULL


