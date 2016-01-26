CREATE OR REPLACE FUNCTION m1.geom_buffer_one_side(geometry, double precision)
 RETURNS geometry
 LANGUAGE sql
 STRICT
AS $function$
  WITH data AS ( 
    SELECT
      $1 as geom,
      ST_Buffer($1, abs($2), 'endcap=flat') as geom_buffer,
      ST_OffsetCurve(ST_GeometryN(ST_Multi($1), 1), $2) as geom_offset
  )
  SELECT geom_part
  FROM (
    SELECT (ST_Dump(ST_Split(ST_Snap(geom_buffer, geom, 0.001), $1))).geom as geom_part, geom_offset FROM data
  ) t
  WHERE ST_Intersects(t.geom_part, geom_offset);
$function$
;