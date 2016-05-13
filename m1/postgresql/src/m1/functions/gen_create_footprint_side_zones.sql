CREATE OR REPLACE FUNCTION m1.gen_create_footprint_side_zones(geom geometry, params jsonb, zonedistance double precision, footprint geometry DEFAULT NULL::geometry)
 RETURNS TABLE(zone geometry, side character)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY 
  WITH data AS (
    SELECT 
      COALESCE(footprint, m1.gen_create_footprint(geom, params)) as footprint,
      COALESCE((params#>>'{buffer,radius}')::float, 0) as radius,
      CASE WHEN COALESCE(params#>>'{buffer,startcap}', params#>>'{buffer,cap}', 'round') = 'flat' THEN 0 ELSE 1 END as extstart,
      CASE WHEN COALESCE(params#>>'{buffer,endcap}', params#>>'{buffer,cap}', 'round') = 'flat' THEN 0 ELSE 1 END as extend
  )
  , buffs AS (
    SELECT 
      s as side, 
      m1.gen_create_buffer_one_side_flat(
        m1.gen_extend_line(geom, d.radius * d.extstart, d.radius * d.extend), 
        CASE s WHEN 'l' THEN -1 ELSE 1 END * zonedistance
      ) as buff
    FROM unnest(array['l', 'r']::bpchar[]) s, data d
  )
  SELECT
     ST_SnapToGrid(ST_Union(d.footprint, buff), 0.00001), b.side
     --ST_SnapToGrid(buff, 0.00001), b.side
  FROM data d, buffs b;  
END;
$function$
;