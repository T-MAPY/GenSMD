CREATE OR REPLACE FUNCTION tests.gen_create_footprint_side_lines()
 RETURNS TABLE(name character varying, result boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN

  RETURN QUERY (
    SELECT 'm1.gen_create_footprint_side_lines - square'::varchar AS name, 
    COALESCE(
      (SELECT 
        array_agg(side || ':' || ST_AsText(line) ORDER BY side)
        FROM m1.gen_create_footprint_side_lines(
         'LINESTRING(0 0,10 0)'::geometry, 
         '{"buffer":{"radius":1,"cap":"square"}}'::jsonb
        )
      ) = '{"l:LINESTRING(-1 0,-1 1,0 1,10 1,11 1,11 0)","r:LINESTRING(-1 0,-1 -1,0 -1,10 -1,11 -1,11 0)"}',
      false
    ) AS result
  );
  
  RETURN QUERY (
    SELECT 'm1.gen_create_footprint_side_lines - square, flat'::varchar AS name, 
    COALESCE(
      (SELECT 
        array_agg(side || ':' || ST_AsText(line) ORDER BY side)
        FROM m1.gen_create_footprint_side_lines(
         'LINESTRING(0 0,10 0)'::geometry, 
         '{"buffer":{"radius":1,"capstart":"square", "capend":"flat"}}'::jsonb
        )
      ) = '{"l:LINESTRING(-1 0,-1 1,0 1,10 1,10 0)","r:LINESTRING(-1 0,-1 -1,0 -1,10 -1,10 0)"}',
      false
    ) AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_create_footprint_side_lines - triangle, flat'::varchar AS name, 
    COALESCE(
      (SELECT 
        array_agg(side || ':' || ST_AsText(line) ORDER BY side)
        FROM m1.gen_create_footprint_side_lines(
         'LINESTRING(0 0,10 0)'::geometry, 
         '{"buffer":{"radius":1,"cap":"triangle", "capend":"flat"}}'::jsonb
        )
      ) = '{"l:LINESTRING(-1 0,0 1,10 1,10 0)","r:LINESTRING(-1 0,0 -1,10 -1,10 0)"}',
      false
    ) AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_create_footprint_side_lines - triangle'::varchar AS name, 
    COALESCE(
      (SELECT 
        array_agg(side || ':' || ST_AsText(line) ORDER BY side)
        FROM m1.gen_create_footprint_side_lines(
         'LINESTRING(0 0,10 0)'::geometry, 
         '{"buffer":{"radius":1,"cap":"triangle"}}'::jsonb
        )
      ) = '{"l:LINESTRING(-1 0,0 1,10 1,11 0)","r:LINESTRING(-1 0,0 -1,10 -1,11 0)"}',
      false
    ) AS result
  );

  RETURN QUERY (
    SELECT 'm1.gen_create_footprint_side_lines - touched'::varchar AS name, 
    COALESCE(
      (SELECT 
        array_agg(side || ':' || ST_AsText(line) ORDER BY side)
        FROM m1.gen_create_footprint_side_lines(
         'LINESTRING(0 0,10 0,10 10,0 10,0 2)'::geometry, 
         '{"buffer":{"radius":1,"cap":"square","join":"mitre"}}'::jsonb
        )
      ) = '{"l:MULTILINESTRING((1 1,0.99 1,0 1),(1 1,9 1,9 9,1 9,1 2,1 1))","r:LINESTRING(-1 0,-1 -1,0 -1,11 -1,11 11,-1 11,-1 2,-1 1,0 1)"}',
      false
    ) AS result
  );  

  RETURN QUERY (
    SELECT 'm1.gen_create_footprint_side_lines - closed line'::varchar AS name, 
    COALESCE(
      (SELECT 
        array_agg(side || ':' || ST_AsText(line) ORDER BY side)
        FROM m1.gen_create_footprint_side_lines(
         'LINESTRING(0 0,10 0,10 10,0 10,0 0)'::geometry, 
         '{"buffer":{"radius":1,"cap":"square","join":"mitre"}}'::jsonb
        )
      ) = '{"l:LINESTRING(1 1,9 1,9 9,1 9,1 1)","r:LINESTRING(-1 -1,0 -1,1 -1,11 -1,11 11,-1 11,-1 1,-1 0,-1 -1)"}',
      false
    ) AS result
  );  
    
  RETURN QUERY (
    SELECT 'm1.gen_create_footprint_side_lines - closed line in the middle'::varchar AS name, 
    COALESCE(
      (SELECT 
        array_agg(side || ':' || ST_AsText(line) ORDER BY side)
        FROM m1.gen_create_footprint_side_lines(
         'LINESTRING(0 0,10 0,10 10,0 10,0 -5)'::geometry, 
         '{"buffer":{"radius":1,"cap":"square","join":"mitre"}}'::jsonb
        )
      ) = '{"l:MULTILINESTRING((1 -1,1 -5,1 -6,0 -6),(1 1,9 1,9 9,1 9,1 1))","r:LINESTRING(0 -6,-1 -6,-1 -5,-1 11,11 11,11 -1,1 -1)"}',
      false
    ) AS result
  );  
  
  RETURN QUERY (
    SELECT 'm1.gen_create_footprint_side_lines - self crosses'::varchar AS name, 
    COALESCE(
      (SELECT 
        array_agg(side || ':' || ST_AsText(line) ORDER BY side)
        FROM m1.gen_create_footprint_side_lines(
         'LINESTRING(-5 0,10 0,10 10,0 10,0 -5)'::geometry, 
         '{"buffer":{"radius":1,"cap":"square","join":"mitre"}}'::jsonb
        )
      ) = '{"l:MULTILINESTRING((-6 0,-6 1,-5 1,-1 1),(1 -1,1 -5,1 -6,0 -6),(1 1,9 1,9 9,1 9,1 1))","r:MULTILINESTRING((-6 0,-6 -1,-5 -1,-1 -1,-1 -5,-1 -6,0 -6),(1 -1,11 -1,11 11,-1 11,-1 1))"}',
      false
    ) AS result
  );  

END;
$function$
;