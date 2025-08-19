SELECT product_name, company_name, units_in_stock FROM products
INNER JOIN suppliers ON products.supplier_id = suppliers.supplier_id
ORDER BY units_in_stock DESC LIMIT 7;

SELECT category_name, SUM(units_in_stock) FROM products
INNER JOIN categories ON products.category_id = categories.category_id
GROUP BY category_name
ORDER BY SUM(units_in_stock) DESC;

SELECT last_name, first_name, order_id FROM employees
LEFT JOIN orders ON employees.employee_id = orders.employee_id
WHERE order_id IS NULL;

SELECT category_name, SUM(units_in_stock * unit_price) AS total_price
FROM products
JOIN categories USING(category_id)
WHERE discontinued <> 1
GROUP BY category_name HAVING SUM(units_in_stock * unit_price) > 5230
ORDER BY total_price DESC







