CREATE OR REPLACE FUNCTION tests.test_gen_get_three_points_angle()
 RETURNS TABLE(name character varying, result boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN

  RETURN QUERY (
    SELECT 'm1.gen_get_three_points_angle - E -> N (left)'::varchar AS name, 
      degrees(m1.gen_get_three_points_angle(
        'POINT(0 0)'::geometry,
        'POINT(10 0)'::geometry,
        'POINT(10 10)'::geometry,
        'l'
      )) = 90 AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_get_three_points_angle - E -> N (right)'::varchar AS name, 
      degrees(m1.gen_get_three_points_angle(
        'POINT(0 0)'::geometry,
        'POINT(10 0)'::geometry,
        'POINT(10 10)'::geometry,
        'r'
      )) = 270 AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_get_three_points_angle - W -> N (left)'::varchar AS name, 
      degrees(m1.gen_get_three_points_angle(
        'POINT(0 0)'::geometry,
        'POINT(-10 0)'::geometry,
        'POINT(-10 10)'::geometry,
        'l'
      )) = 270 AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_get_three_points_angle - W -> N (right)'::varchar AS name, 
      degrees(m1.gen_get_three_points_angle(
        'POINT(0 0)'::geometry,
        'POINT(-10 0)'::geometry,
        'POINT(-10 10)'::geometry,
        'r'
      )) = 90 AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_get_three_points_angle - N -> N (left)'::varchar AS name, 
      degrees(m1.gen_get_three_points_angle(
        'POINT(0 0)'::geometry,
        'POINT(0 10)'::geometry,
        'POINT(0 20)'::geometry,
        'l'
      )) = 180 AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_get_three_points_angle - N -> N (right)'::varchar AS name, 
      degrees(m1.gen_get_three_points_angle(
        'POINT(0 0)'::geometry,
        'POINT(0 10)'::geometry,
        'POINT(0 20)'::geometry,
        'r'
      )) = 180 AS result
  );  

  RETURN QUERY (
    SELECT 'm1.gen_get_three_points_angle - N -> S (left)'::varchar AS name, 
      degrees(m1.gen_get_three_points_angle(
        'POINT(0 0)'::geometry,
        'POINT(0 10)'::geometry,
        'POINT(0 0)'::geometry,
        'l'
      )) = 0 AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_get_three_points_angle - N -> S (right)'::varchar AS name, 
      degrees(m1.gen_get_three_points_angle(
        'POINT(0 0)'::geometry,
        'POINT(0 10)'::geometry,
        'POINT(0 0)'::geometry,
        'r'
      )) = 0 AS result
  );  

  RETURN QUERY (
    SELECT 'm1.gen_get_three_points_angle - NE -> SE (left)'::varchar AS name, 
      degrees(m1.gen_get_three_points_angle(
        'POINT(0 0)'::geometry,
        'POINT(5 5)'::geometry,
        'POINT(10 0)'::geometry,
        'l'
      )) = 270 AS result
  );      

  RETURN QUERY (
    SELECT 'm1.gen_get_three_points_angle - NE -> SE (right)'::varchar AS name, 
      degrees(m1.gen_get_three_points_angle(
        'POINT(0 0)'::geometry,
        'POINT(5 5)'::geometry,
        'POINT(10 0)'::geometry,
        'r'
      )) = 90 AS result
  );    
END;
$function$
;