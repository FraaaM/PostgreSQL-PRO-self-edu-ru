-- ЗАДАНИЕ 1
\copy (SELECT product_id, product_name, supplier_id, category_id, quantity_per_unit, unit_price, units_in_stock, units_on_order, reorder_level FROM products) TO 'products_export.csv' WITH (FORMAT CSV, HEADER, DELIMITER ';', NULL '(not set)');

CREATE TABLE products_copy (LIKE products INCLUDING ALL);

\copy products_copy FROM 'products_export.csv' WITH (FORMAT CSV, HEADER, DELIMITER ';', NULL '(not set)');

SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM products_copy;

-- ЗАДАНИЕ 2
\copy (SELECT o.order_id, o.order_date, p.product_name, od.quantity, od.unit_price 
FROM orders o 
JOIN order_details od ON o.order_id = od.order_id 
JOIN products p ON od.product_id = p.product_id 
WHERE EXTRACT(YEAR FROM o.order_date) = 1997) 
TO 'sales_report_1997.csv' WITH (FORMAT CSV, HEADER);

-- ЗАДАНИЕ 3
CREATE TEMP TABLE suppliers_staging (
    supplier_name TEXT,
    contact_name TEXT,
    city TEXT,
    country TEXT,
    phone TEXT
);

\copy suppliers_staging FROM 'new_suppliers.csv' WITH (FORMAT CSV);

INSERT INTO suppliers (company_name, contact_name, city, country, phone)
SELECT
    supplier_name,
    NULLIF(contact_name, ''),
    city,
    country,
    NULLIF(phone, '')
FROM
    suppliers_staging
WHERE
    country <> '??';

SELECT * FROM suppliers 
ORDER BY supplier_id 
DESC LIMIT 3;

-- ЗАДАНИЕ 4 (выполняется в терминале, не в SQL)
-- pg_dump -U your_user -Fc -f northwind.dump northwind
-- createdb -U your_user northwind_partial_restore
-- pg_restore -U your_user -d northwind_partial_restore -t employees -t customers northwind.dump