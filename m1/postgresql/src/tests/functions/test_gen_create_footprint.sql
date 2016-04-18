CREATE OR REPLACE FUNCTION tests.test_gen_create_footprint()
 RETURNS TABLE(name character varying, result boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN

  RETURN QUERY (
    SELECT 'm1.gen_create_footprint - buffer (round)'::varchar AS name, 
    COALESCE(ST_Equals(
      m1.gen_create_footprint(
        'LINESTRING(0 0, 10 0)'::geometry, 
        '{"buffer": {"radius": 2, "cap": "round"}}'::jsonb
      ),
      ST_SnapToGrid(ST_Buffer('LINESTRING(0 0, 10 0)'::geometry, 2), 0.0001)
    ), false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_create_footprint - buffer (flat)'::varchar AS name, 
    COALESCE(ST_Equals(
      m1.gen_create_footprint(
        'LINESTRING(0 0, 10 0)'::geometry, 
        '{"buffer": {"radius": 2, "cap": "flat"}}'::jsonb
      ),
      ST_Buffer('LINESTRING(0 0, 10 0)'::geometry, 2, 'endcap=flat')
    ), false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_create_footprint - buffer (triangle)'::varchar AS name, 
    COALESCE(ST_Equals(
      m1.gen_create_footprint(
        'LINESTRING(0 0, 10 0)'::geometry, 
        '{"buffer": {"radius": 2, "cap": "triangle"}}'::jsonb
      ),
      'POLYGON((10 2,12 0,10 -2,0 -2,-2 0,0 2,10 2))'::geometry
    ), false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_create_footprint - buffer (square, flat)'::varchar AS name, 
    COALESCE(ST_Equals(
      m1.gen_create_footprint(
        'LINESTRING(0 0, 10 0)'::geometry, 
        '{"buffer": {"radius": 2, "cap": "flat", "capstart": "square"}}'::jsonb
      ),
      'POLYGON((0 -2,-2 -2,-2 2,0 2,10 2,10 -2,0 -2))'::geometry
    ), false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_create_footprint - buffer (square, triangle)'::varchar AS name, 
    COALESCE(ST_Equals(
      m1.gen_create_footprint(
        'LINESTRING(0 0, 10 0)'::geometry, 
        '{"buffer": {"radius": 2, "capstart": "square", "capend": "triangle"}}'::jsonb
      ),
      'POLYGON((0 -2,-2 -2,-2 2,0 2,10 2,12 0,10 -2,0 -2))'::geometry
    ), false) AS result
  );
  
  RETURN QUERY (
    SELECT 'm1.gen_create_footprint - geometry'::varchar AS name, 
    COALESCE(ST_Equals(
      m1.gen_create_footprint(
        'POINT(1 1)'::geometry, 
        '{"geometry": "POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))", "origin": [1, 0]}'::jsonb
      ),
      'POLYGON((0 1,1 1,1 2,0 2,0 1))'::geometry
    ), false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_create_footprint - geometry + buffer'::varchar AS name, 
    COALESCE(ST_Equals(
      m1.gen_create_footprint(
        'POINT(1 1)'::geometry, 
        '{"geometry": "POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))", "origin": [1, 0], "buffer": {"radius": 1}}'::jsonb
      ),
      ST_SnapToGrid(ST_Buffer('POLYGON((0 1,1 1,1 2,0 2,0 1))'::geometry, 1), 0.0001)
    ), false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_create_footprint - geometry + rotation'::varchar AS name, 
    COALESCE(ST_Equals(
      m1.gen_create_footprint(
        'POINT(0 0)'::geometry, 
        '{"geometry": "POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))", "origin": [0.5, 0.5], "rotation": 45}'::jsonb
      ),
      ST_Rotate(ST_Translate('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))'::geometry, -0.5, -0.5), pi() * 45::float / 180, 0, 0)
    ), false) AS result
  );

END;
$function$
;