CREATE OR REPLACE FUNCTION tests.test_gen_get_geometry_relationship_side()
 RETURNS TABLE(name character varying, result boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN

  RETURN QUERY (
    SELECT 'm1.gen_get_geometry_relationship_side - left'::varchar AS name, 
    COALESCE(m1.gen_get_geometry_relationship_side(
      'LINESTRING(0 0,10 0)'::geometry,
      'LINESTRING(0 1,10 1)'::geometry,
      2
    ), 'n') = 'l' AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_get_geometry_relationship_side - right'::varchar AS name, 
    COALESCE(m1.gen_get_geometry_relationship_side(
      'LINESTRING(0 0,10 0)'::geometry,
      'LINESTRING(0 -1,10 -1)'::geometry,
      2
    ), 'n') = 'r' AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_get_geometry_relationship_side - cross'::varchar AS name, 
    COALESCE(m1.gen_get_geometry_relationship_side(
      'LINESTRING(0 0,10 0)'::geometry,
      'LINESTRING(0 -1,5 1,10 -1)'::geometry,
      1
    ), 'n') = 'b' AS result
  );
    
  RETURN QUERY (
    SELECT 'm1.gen_get_geometry_relationship_side - identical'::varchar AS name, 
    COALESCE(m1.gen_get_geometry_relationship_side(
      'LINESTRING(0 0,10 0)'::geometry,
      'LINESTRING(0 0,10 0)'::geometry,
      1
    ), 'n') = 'n' AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_get_geometry_relationship_side - over dist'::varchar AS name, 
    COALESCE(m1.gen_get_geometry_relationship_side(
      'LINESTRING(0 0,10 0)'::geometry,
      'LINESTRING(0 1,10 1)'::geometry,
      0.1
    ), 'n') = 'n' AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_get_geometry_relationship_side - point left'::varchar AS name, 
    COALESCE(m1.gen_get_geometry_relationship_side(
      'LINESTRING(0 0,10 0)'::geometry,
      'POINT(1 1)'::geometry,
      2
    ), 'n') = 'l' AS result
  );  
END;
$function$
;