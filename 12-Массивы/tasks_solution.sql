-- ДЗ "Массивы" --
--- Задача 1: Регионы обслуживания ---

-- 1. Добавляем колонку
ALTER TABLE suppliers ADD COLUMN shipping_cities text[]
COMMENT ON COLUMN suppliers.shipping_cities IS 'Города, в которые поставщик осуществляет доставку';

-- 2. Заполняем данные для поставщика 1
UPDATE suppliers
SET shipping_cities = ARRAY['London', 'Berlin', 'Madrid']
WHERE supplier_id = 1;

-- 3. Заполняем данные для поставщика 2
UPDATE suppliers
SET shipping_cities = '{"New Orleans", "Chicago"}' -- Используем синтаксис с фигурными скобками для разнообразия
WHERE supplier_id = 2;

-- 4. Заполняем данные для поставщика 3
UPDATE suppliers
SET shipping_cities = ARRAY['Ann Arbor', 'Chicago', 'Detroit']
WHERE supplier_id = 3;
-- Проверим 
SELECT supplier_id, company_name, shipping_cities FROM suppliers WHERE supplier_id IN (1, 2, 3);


--- Задача 2: Анализ поставок ---
-- 1. Найти всех поставщиков, которые доставляют в 'Chicago'
SELECT supplier_id, company_name, shipping_cities
FROM suppliers
WHERE 'Chicago' = ANY(shipping_cities)
-- Результат: New Orleans Cajun Delights, Grandma Kelly's Homestead

-- 2. Найти всех поставщиков, которые доставляют и в 'London', и в 'Berlin'
SELECT supplier_id, company_name, shipping_cities 
FROM suppliers
WHERE ARRAY['London','Berlin' ] <@ shipping_cities
Результат: Exotic Liquids

-- 3. Найти поставщиков с 'Detroit', но без 'New Orleans'
SELECT supplier_id, company_name, shipping_cities FROM suppliers
WHERE 'Detroit' = ANY(shipping_cities) AND  'New Orleans' <> ALL(shipping_cities);
-- или ... AND NOT ('New Orleans' = ANY(shipping_cities));

-- 4. Добавить 'Paris' поставщику 1
UPDATE suppliers
SET shipping_cities = shipping_cities || 'Paris'::text
-- или SET shipping_cities = shipping_cities || ARRAY ['Paris']
WHERE supplier_id = 1;

SELECT shipping_cities FROM suppliers WHERE supplier_id = 1;
-- Результат: {"London","Berlin","Madrid","Paris"}


-- ДЗ "Циклы" --
--- Задача 1: Функция для пакетного обновления цен (с использованием Массивов) ---
CREATE OR REPLACE FUNCTION ApplyDiscountByProductList(
    product_ids_to_update INT[],
    discount_percentage NUMERIC
)
RETURNS TABLE (
    p_id INT,
    p_name VARCHAR,
    old_price NUMERIC,
    new_price NUMERIC
) AS $$
DECLARE
    current_product_id INT;
    product_record RECORD;
    calculated_price NUMERIC;
BEGIN
    IF discount_percentage <= 0.0 OR discount_percentage > 90.0 THEN
        RAISE EXCEPTION 'Процент скидки должен быть в диапазоне (0, 90]';
    END IF;

    FOREACH current_product_id IN ARRAY product_ids_to_update
    LOOP
        SELECT product_id, product_name, unit_price
        INTO product_record
        FROM products
        WHERE product_id = current_product_id;

        CONTINUE WHEN product_record IS NULL;

        calculated_price := product_record.unit_price * (1 - discount_percentage / 100.0);

        UPDATE products
        SET unit_price = calculated_price
        WHERE product_id = product_record.product_id;

        -- Заполняем переменные для возвращаемой таблицы
        p_id      := product_record.product_id;
        p_name    := product_record.product_name;
        old_price := product_record.unit_price;
        new_price := calculated_price;

        RETURN NEXT;

    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM ApplyDiscountByProductList(ARRAY[1, 14, 36, 999], 20.0);

-- ДОП. ЗАДАЧА -- 
--- Задача 2: Функция для уценки товаров (без массивов) ---
CREATE OR REPLACE FUNCTION ApplyDiscountForSlowMovingProducts(max_quantity_sold int, discount_percentage numeric)
RETURNS TABLE (
	p_id int, 
	p_name varchar, 
	old_price numeric, 
	new_price numeric
) AS $$
DECLARE
product_record record;
calculated_price numeric;
BEGIN
	IF discount_percentage > 50.0 OR  discount_percentage <= 0.0 THEN
        RAISE EXCEPTION 'Процент скидки должен быть в диапазоне (0, 50]';
    END IF;

	FOR product_record IN 
		SELECT p.product_id, p.product_name, p.unit_price
		FROM products p
		LEFT JOIN ( -- джойним подзапрос 
			SELECT od.product_id, SUM(od.quantity) as total_sold
			FROM order_details od
			GROUP BY od.product_id
		) AS sales ON p.product_id = sales.product_id
        WHERE COALESCE(sales.total_sold, 0) <= max_quantity_sold
	 -- или WHERE sales.total_sold <= max_quantity_sold OR total_sold IS NULL
	LOOP
		calculated_price := product_record.unit_price * (1 - discount_percentage / 100.0);

		UPDATE products
		SET unit_price = calculated_price
		WHERE product_id = product_record.product_id;

		p_id := product_record.product_id;
		p_name := product_record.product_name;
		old_price := product_record.unit_price;
		new_price := calculated_price;

		RETURN NEXT;
	END LOOP;
	
END;
$$ LANGUAGE plpgsql;

SELECT * FROM ApplyDiscountForSlowMovingProducts(200, 15.0);

DROP FUNCTION ApplyDiscountForSlowMovingProducts;



