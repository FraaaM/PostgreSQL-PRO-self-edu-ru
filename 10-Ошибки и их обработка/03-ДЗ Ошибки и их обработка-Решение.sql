CREATE OR REPLACE FUNCTION salary_increase(
	cur_salary numeric,
	max_salary numeric DEFAULT 80,
	min_salary numeric DEFAULT 30,
	increase_rate numeric DEFAULT 0.2
) RETURNS bool AS $$
BEGIN
	IF min_salary > max_salary THEN
		RAISE EXCEPTION 'min_salary > max_salary. Min is %, Max is %', min_salary, max_salary USING HINT='Must: min_salary <= max_salary';
	ELSEIF min_salary < 0 THEN
		RAISE EXCEPTION 'Invalid min_salary. You passed: (%)', min_salary USING HINT='Must: min_salary >= 0';
	ELSEIF max_salary < 0 THEN
		RAISE EXCEPTION 'Invalid max_salary. You passed: (%)', max_salary USING HINT='Must: max_salary >= 0';
	ELSEIF increase_rate < 0.05 THEN
		RAISE EXCEPTION 'Invalid increase_rate. You passed: (%)', increase_rate USING HINT='Must: increase_rate > 0.05';
	END IF;
	
	IF cur_salary >= min_salary THEN 
		RETURN False;
	ELSEIF cur_salary < min_salary THEN
		cur_salary := cur_salary * (1 + increase_rate);
		IF cur_salary > max_salary THEN
			RETURN False;
		ELSE RETURN True;
		END IF; 
	END IF;
END
$$ LANGUAGE plpgsql;
SELECT salary_increase(70, 10, 80, 0.2);
SELECT salary_increase(79, 10, -1, 0.2);
SELECT salary_increase(79, 10, 10, 0.04);