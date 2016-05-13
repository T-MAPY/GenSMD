CREATE OR REPLACE FUNCTION m1.gen_extend_line(geom geometry, extstart double precision, extend double precision)
 RETURNS geometry
 LANGUAGE plpgsql
AS $function$
DECLARE
  numpts integer := ST_NumPoints(geom);
  r record;
BEGIN
  FOR r IN 
    WITH data AS (
      SELECT 2 as p1, 1 as p2, 1 as pe, extstart as ext, 0 as pos
      UNION
      SELECT numpts - 1, numpts, numpts, extend as ext, -1 as pos
    )
    , azim AS (
      SELECT *, ST_Azimuth(ST_PointN(geom, p1), ST_PointN(geom, p2)) as az, ST_PointN(geom, pe) as pte FROM data WHERE ext > 0
    )
    SELECT ST_Translate(pte, sin(az) * ext, cos(az) * ext) as pt, pos FROM azim
  LOOP 
    geom := ST_AddPoint(geom, r.pt, r.pos);
  END LOOP;
  geom := ST_SnapToGrid(geom, 0.00001);
  RETURN geom;

  
END;
$function$
;