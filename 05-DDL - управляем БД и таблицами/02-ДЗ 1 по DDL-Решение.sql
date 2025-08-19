CREATE TABLE teacher (
	teacher_id serial,
	first_name varchar(64),
	last_name varchar(64),
	birthday date,
	phone varchar(64),
	title varchar
);

DROP TABLE teacher

ALTER TABLE teacher
ADD COLUMN middle_name varchar(64);

ALTER TABLE teacher
DROP COLUMN middle_name;

ALTER TABLE teacher
RENAME birthday TO birth_date;

ALTER TABLE teacher
ALTER COLUMN phone SET DATA TYPE varchar(32);

CREATE TABLE exam (
	exam_id serial,
	exam_name varchar(256),
	exam_date date
);

INSERT INTO exam (exam_name, exam_date)
VALUES
('rus','12-12-2023'),
('eng','12-1-2025'),
('math','12-1-2023')

SELECT * FROM exam

TRUNCATE TABLE exam RESTART IDENTITY