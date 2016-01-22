CREATE OR REPLACE FUNCTION tests.run_tests(
    IN filter character varying DEFAULT '^test_'::character varying,
    IN schemafilter character varying DEFAULT '^tests$'::character varying)
  RETURNS TABLE(test character varying, name character varying, result boolean) AS
$BODY$
DECLARE
  r record;
  funcCall varchar;
BEGIN
  FOR r IN (
    SELECT p.proname, n.nspname
    FROM pg_proc p 
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
    WHERE 
      p.proname ~ filter 
      AND n.nspname ~ schemaFilter
      AND array_length(p.proargtypes, 1) = 0 
    ORDER BY p.proname
  ) LOOP
    funcCall := r.nspname || '.' || r.proname;
    funcCall := 'SELECT ''' || funcCall || '''::varchar AS test, * FROM ' || funcCall || '()';
    --RAISE NOTICE 'call: %', funcCall;
    RETURN QUERY EXECUTE funcCall;
  END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;