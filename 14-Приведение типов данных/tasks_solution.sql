-- Задача 1
SELECT '2012-12-12'::date;
SELECT CAST('2012-12-12' AS date);

-- Задача 2
SELECT to_jsonb(ROW('Иван Петров', 'ivan@test.com', '12345'));
-- Или 
SELECT to_json(ROW('Иван Петров', 'ivan@test.com', '12345'))::JSONB;

-- Задача 3
CREATE OR REPLACE FUNCTION safe_cast_to_numeric(text_val varchar, default_val numeric(10,2) DEFAULT NULL)
	RETURNS numeric(10,2) AS $$
BEGIN
	RETURN text_val::numeric(10,2);
	EXCEPTION
		WHEN others THEN
			RETURN default_val;
END;
$$ LANGUAGE plpgsql;

SELECT safe_cast_to_numeric('10.20');
SELECT safe_cast_to_numeric('10O.20');

-- Обновление таблицы с обработкой ошибок
ALTER TABLE products ADD COLUMN numeric_price NUMERIC(10,2);

UPDATE products 
SET numeric_price = safe_cast_to_numeric(price, 0)
WHERE safe_cast_to_numeric(price) IS NOT NULL;

-- Доп. решение : Использование регулярных выражений для валидации
SELECT 
    price,
    CASE
        WHEN price ~ '^[0-9]+(\.[0-9]+)?$' THEN price::NUMERIC(10,2)
        ELSE NULL 
    END as numeric_price
FROM products;