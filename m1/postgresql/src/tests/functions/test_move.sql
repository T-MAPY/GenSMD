CREATE OR REPLACE FUNCTION tests.test_move()
  RETURNS TABLE(name character varying, result boolean) AS
$BODY$
BEGIN
  RETURN QUERY (SELECT 'test move 1'::varchar AS name, true AS result);
  RETURN QUERY (SELECT 'test move 2'::varchar AS name, false AS result);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;