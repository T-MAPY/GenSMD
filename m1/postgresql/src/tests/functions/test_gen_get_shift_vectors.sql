CREATE OR REPLACE FUNCTION tests.test_gen_get_shift_vectors()
 RETURNS TABLE(name character varying, result boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN

  RETURN QUERY (
    SELECT 'm1.gen_get_shift_vectors - parallel'::varchar AS name, 
    COALESCE(
      (SELECT 
        array_agg(ST_AsText(vector))
        FROM m1.gen_get_shift_vectors(
         'LINESTRING(0 0,10 0)'::geometry, 
         'l', 
         'LINESTRING(-10 -1, 15 -1)'::geometry
        )
      ) = '{"LINESTRING(0 -1,0 0)","LINESTRING(10 -1,10 0)"}',
      false
    ) AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_get_shift_vectors - intersect left'::varchar AS name, 
    COALESCE(
      (SELECT 
        array_agg(ST_AsText(vector))
        FROM m1.gen_get_shift_vectors(
         'LINESTRING(0 0,10 0)'::geometry, 
         'l', 
         'LINESTRING(0 -1,5 1,10 -1)'::geometry
        )
      ) = '{"LINESTRING(0 -1,0 0)","LINESTRING(10 -1,10 0)"}',
      false
    ) AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_get_shift_vectors - intersect right'::varchar AS name, 
    COALESCE(
      (SELECT 
        array_agg(ST_AsText(vector))
        FROM m1.gen_get_shift_vectors(
         'LINESTRING(0 0,10 0)'::geometry, 
         'r', 
         'LINESTRING(0 -1,5 1,10 -1)'::geometry
        )
      ) = '{"LINESTRING(5 1,5 0)"}',
      false
    ) AS result
  );  

  RETURN QUERY (
    SELECT 'm1.gen_get_shift_vectors - perpendicular'::varchar AS name, 
    COALESCE(
      (SELECT 
        array_agg(ST_AsText(vector))
        FROM m1.gen_get_shift_vectors(
         'LINESTRING(0 0,10 0)'::geometry, 
         'l', 
         'LINESTRING(5 5,5 -5)'::geometry
        )
      ) = '{"LINESTRING(5 -5,5 0)"}',
      false
    ) AS result
  );    
END;
$function$
;