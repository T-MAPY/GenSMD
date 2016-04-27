CREATE OR REPLACE FUNCTION tests.test_gen_geom_line_expand_in_polygon()
 RETURNS TABLE(name character varying, result boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN

  RETURN QUERY (
    SELECT 'm1.gen_geom_line_expand_in_polygon - simple ->'::varchar AS name, 
    COALESCE(ST_AsText(
      m1.gen_geom_line_expand_in_polygon(
        'LINESTRING(0 0, 10 10)'::geometry, 
        ST_Buffer('LINESTRING(0 0, 10 10)'::geometry, 1, 'endcap=square')
      ))
      =
      'LINESTRING(-0.7071068 -0.7071068,0 0,10 10,10.7071068 10.7071068)'
    , false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_geom_line_expand_in_polygon - simple <-'::varchar AS name, 
    COALESCE(ST_AsText(
      m1.gen_geom_line_expand_in_polygon(
        'LINESTRING(10 10, 0 0)'::geometry, 
        ST_Buffer('LINESTRING(0 0, 10 10)'::geometry, 1, 'endcap=square')
      ))
      =
      'LINESTRING(10.7071068 10.7071068,10 10,0 0,-0.7071068 -0.7071068)'
    , false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_geom_line_expand_in_polygon - simple <-'::varchar AS name, 
    COALESCE(ST_AsText(
      m1.gen_geom_line_expand_in_polygon(
        'LINESTRING(0 0,5 0,5 1.2,-1 1.2)'::geometry, 
        ST_Buffer('LINESTRING(0 0,5 0,5 1.2,-1 1.2)'::geometry, 1, 'endcap=square')
      ))
      =
      'LINESTRING(-1 0,0 0,5 0,5 1.2,-1 1.2,-2 1.2)'
    , false) AS result
  );
  

END;
$function$
;