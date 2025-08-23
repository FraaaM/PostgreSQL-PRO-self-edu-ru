--- Задача 1: Создание DOMAIN ---
-- 1
CREATE DOMAIN email_address AS text 
	CHECK (VALUE LIKE '%@%')
	-- или ( VALUE ~ '.+@.+') 
	NOT NULL;
-- 2
CREATE DOMAIN sku_code AS TEXT
    CHECK (VALUE ~ '^PROD-\d{6}$')
    NOT NULL;
	
--- Задача 2: Управление статусами (ENUM) ---
CREATE TYPE delivery_status AS ENUM (
	'packaging',
	'in_transit',
	'delivered',
	'failed'
);

--- Задача 3: Моделирование получателя (COMPOSITE TYPE) ---
CREATE TYPE recipient_info AS (
	full_name TEXT,
	contact_email email_address,
	postal_code CHAR(5)
);

--- Задача 4: Проектирование основной таблицы и работа с JSONB ---
-- 1
CREATE TABLE deliveries (
	id SERIAL PRIMARY KEY,
	order_number INT,
	item_sku sku_code,
	status delivery_status,
	recipient recipient_info,
	metadata JSONB
);
-- 2. Заполнение данными
INSERT INTO deliveries (order_number, item_sku, status, recipient, metadata) VALUES
(101, 'PROD-543210', 'in_transit', ROW('Иван Петров', 'ivan@test.com', '12345'), '{"weight_kg": 2.5, "is_fragile": true}'),
(102, 'PROD-987654', 'packaging',  ROW('Мария Сидорова', 'maria@example.com', '67890'), '{"weight_kg": 0.5}'),
(103, 'PROD-112233', 'delivered',  ROW('Олег Смирнов', 'oleg@demo.net', '12345'), '{"weight_kg": 15, "courier_comment": "Клиент просил оставить у двери."}'),
(104, 'PROD-543210', 'in_transit', ROW('Анна Кузнецова', 'anna@web.dev', '54321'), '{"weight_kg": 2.5, "is_fragile": true}');

-- 3 Запросы
SELECT
    (recipient).full_name,
    (recipient).postal_code,
	metadata ->> 'weight_kg' AS baggage_kg
FROM deliveries
WHERE status = 'in_transit';

SELECT * FROM deliveries
WHERE metadata @> '{"is_fragile": true}';

SELECT status, COUNT(*) AS count_deliveries
FROM deliveries
GROUP BY status;
-- ORDER BY COUNT(*) DESC;

--- Задача 5: Эволюция схемы (ALTER TYPE) ---
-- 1. Добавляем новый статус в ENUM	
ALTER TYPE delivery_status ADD VALUE 'returning' AFTER 'failed';

-- 2. Добавляем поле в COMPOSITE TYPE
ALTER TYPE recipient_info ADD ATTRIBUTE phone_number varchar;
-- после выполнение команды для существующих записей новое поле будет NULL
ALTER TYPE recipient_info ALTER ATTRIBUTE phone_number TYPE text; -- ошибка

-- 3. Добавляем ограничение в DOMAIN
ALTER DOMAIN sku_code 
ADD CONSTRAINT non_zero_check CHECK (SUBSTRING(VALUE FROM 6)::INT != 0);
-- Проверим, что теперь нельзя вставить невалидный SKU
INSERT INTO deliveries (order_number, item_sku, recipient) 
VALUES (105, 'PROD-000000', ROW('Тест', 'test@test.com', '11111', '1234231'));
-- -> ERROR: значение домена sku_code нарушает ограничение-проверку "non_zero_check" 

-- 4 Добавление ключа в JSONB 
UPDATE deliveries
SET metadata = metadata || '{"is_fragile": false}'::jsonb
WHERE metadata ->> 'is_fragile' IS NULL;
--  Проверим
SELECT metadata FROM deliveries;

--- Задача 6: Оптимизация (`INDEX`) ---
-- 1. Индекс по полю внутри составного типа
CREATE INDEX idx_deliveries_recipient_postal_code ON deliveries (((recipient).postal_code));
EXPLAIN SELECT * FROM deliveries WHERE (recipient).postal_code = '12345';

-- 2. GIN-индекс для JSONB
CREATE INDEX idx_deliveries_metadata_gin ON deliveries USING GIN (metadata);
EXPLAIN SELECT * FROM deliveries WHERE metadata ? 'courier_comment';