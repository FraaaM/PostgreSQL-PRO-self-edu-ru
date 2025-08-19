-- 1
CREATE OR REPLACE VIEW orders_customers_epmployees AS
SELECT order_date, required_date, shipped_date, 
ship_postal_code, company_name, contact_name, 
phone, last_name, first_name, title
FROM orders
JOIN customers USING(customer_id)
JOIN employees USING(employee_id);

SELECT * FROM orders_customers_epmployees
WHERE order_date > '1997-01-01'

-- 2
ALTER VIEW orders_customers_epmployees RENAME TO oce_old;

CREATE OR REPLACE VIEW orders_customers_epmployees AS
SELECT order_date, required_date, shipped_date, 
ship_postal_code, company_name, contact_name, 
phone, last_name, first_name, title, 
ship_country, customers.postal_code, reports_to
FROM orders
JOIN customers USING(customer_id)
JOIN employees USING(employee_id);

SELECT * FROM orders_customers_epmployees
ORDER BY ship_country;

DROP VIEW IF EXISTS oce_old;

-- 3
CREATE OR REPLACE VIEW not_discontinued_products AS
SELECT * FROM products
WHERE discontinued <> 1
WITH LOCAL CHECK OPTION;

INSERT INTO not_discontinued_products
VALUES(78, 'abc', 1, 1, 'abc', 1, 1, 1, 1, 1);