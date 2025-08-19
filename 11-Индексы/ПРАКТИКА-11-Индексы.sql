EXPLAIN ANALYZE SELECT order_id FROM orders;
SELECT * FROM pg_statistic;

-- Preprocessing
CREATE TABLE perf_tests(
	id int,
	reason text COLLATE "C",
	annotation text COLLATE "C"
);
INSERT INTO perf_test
SELECT s.id, md5(random()::text), null
FROM generate_series(1,10000000) AS s(id)
ORDER BY random();

UPDATE perf_test	
SET annotation = UPPER(md5(random()::text));
-- (1)
EXPLAIN 
SELECT * FROM perf_test
WHERE id = 3700000

-- INDEX --
CREATE INDEX idx_perf_test_id ON perf_test(id) -- теперь (1) строиться по идексам
-- (2)
EXPLAIN -- ANALYZE
SELECT * FROM perf_test
WHERE reason LIKE 'bc%' AND annotation LIKE 'AB%'; 

CREATE INDEX idx_perf_text_reason_annotation ON perf_test(reason,annotation);
-- теперь (2) строится по идексам 

EXPLAIN -- (3)
SELECT * FROM perf_test 
WHERE annotation LIKE 'AB%';
-- НО (3) строится по Parallel Seq 
-- (т.к. используется 2-й стобец созданого индекса)
-- что бы использовать индексный поиск для второго столбца 
-- нужно создать для столбца annotation индекс
CREATE INDEX idx_perf_text_annotation ON perf_test(annotation)
-- теперь (3) использует индексный поиск

EXPLAIN -- (4)
SELECT * FROM perf_test 
WHERE LOWER(annotation) LIKE 'ab%';
-- НО для (4) используется Parallel Seq Scan т.к.
-- для выражений(если использ. фун.) нужно создавать отдельный индекс:
CREATE INDEX idx_perf_text_annotation_lower ON perf_test(LOWER(annotation))
-- теперь (4) исп. индексный поиск

-- GIN --
EXPLAIN -- (5)
SELECT * FROM perf_test
WHERE reason LIKE '%dfe%'
-- НО при '%dfe%' в (5) используется Seq Scan

CREATE EXTENSION pg_trgm;
CREATE INDEX trgm_idx_perf_test_reason ON perf_test USING gin (reason gin_trgm_ops);
-- теперь (5) ускорено