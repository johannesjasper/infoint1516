
-- function to loop over schema names

CREATE OR REPLACE FUNCTION COUNT_ALL() RETURNS int as $$
DECLARE 
	schema varchar;
	count int;
	result int;
BEGIN
	result := 0;
	FOR schema in
		SELECT * FROM (VALUES ('target_basketball.team'),('target_bundesliga.team'))V
	LOOP
		raise notice 'schema: %', schema;
		EXECUTE 'SELECT COUNT(*) FROM '|| schema  INTO count;
		result := result + count;
	END LOOP;
	RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT COUNT_ALL();