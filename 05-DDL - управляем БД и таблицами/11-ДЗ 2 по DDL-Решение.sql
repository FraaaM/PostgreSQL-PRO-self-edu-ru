DROP TABLE IF EXISTS exam;
-- 1 
CREATE TABLE exam (
	exam_id serial UNIQUE NOT NULL,
	exam_name varchar(64),
	exam_date date
); 	

-- 2
ALTER TABLE person
DROP CONSTRAINT exam_exam_id_key;

-- 3
ALTER TABLE exam
ADD CONSTRAINT pk_exam_exam_id_key PRIMARY KEY(exam_id);

-- 4
CREATE TABLE person (
	person_id int PRIMARY KEY,
	firts_name varchar,
	last_name varchar
 -- CONSTRAINT pk_person_person_id PRIMARY KEY(person_id)
);
-- 5
CREATE TABLE pasport (
	pasport_id int PRIMARY KEY,
	pasport_code int NOT NULL,
	registration varchar NOT NULL,
	person_id int REFERENCES person(person_id)
 -- CONSTRAINT fk_pasport_person_id FOREIGN KEY (person_id) REFERENCES person(person_id)
);
-- 6
ALTER TABLE book
ADD COLUMN book_weight smallint CHECK (100 > book_weight AND book_weight > 0);
-- ADD COLUMN book_weight smallint CONSTRAINT CHK_book_weight CHECK (100 > book_weight AND book_weight > 0)

-- 7
INSERT INTO book
VALUES
(1, 'title', 'isbn', 1, 120.5, 120);

-- 8
CREATE TABLE student (
	student_id int GENERATED ALWAYS AS IDENTITY NOT NULL,
	full_name varchar,
	grade smallint DEFAULT 1
)
-- 9
INSERT INTO student (full_name)
VALUES ('name1')
RETURNING *;

-- 10
ALTER TABLE student
ALTER COLUMN grade DROP DEFAULT

-- 11
ALTER TABLE products
ADD CONSTRAINT CHK_products_price CHECK(unit_price > 0);

-- 12
SELECT MAX(product_id) FROM products;
CREATE SEQUENCE IF NOT EXISTS products_product_id_seq
START WITH 78 OWNED BY products.product_id;

-- 13
ALTER TABLE products
ALTER COLUMN product_id SET DEFAULT nextval('products_product_id_seq');
INSERT INTO products(product_name, supplier_id, category_id, quantity_per_unit, 
					 unit_price, units_in_stock, units_on_order, reorder_level, discontinued)
VALUES ('prod', 1, 1, 10, 20, 20, 10, 1, 0)
RETURNING product_id;

DELETE FROM products WHERE product_id = 78;
SELECT * FROM products ORDER BY product_id DESC;